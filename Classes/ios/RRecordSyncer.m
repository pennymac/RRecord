//
//  RRecorcSyncer.m
//  PennyMac
//
//  Created by Christopher Parratto on 11/27/13.
//  Copyright (c) 2013 PennyMac. All rights reserved.
//

#import "RRecordSyncer.h"
#import "NSManagedObject+RRecord.h"
#import "AFHTTPRequestOperationManager.h"
#import "TKStateMachine.h"
#import "TKState.h"
#import "TKTransition.h"
#import "TKEvent.h"

@interface RRecordSyncer ()
    @property NSObject<RRecordSyncerProtocol> *object;

    //Network Operation Manager

    @property AFHTTPRequestOperationManager *networkOperationManager;

    //Machine

    @property TKStateMachine *syncStateMachine;

    //States

    @property TKState *noneState;
    @property TKState *syncedState;
    @property TKState *failureState;
    @property TKState *createState;
    @property TKState *pendingState;
    @property TKState *updateState;
    @property TKState *destroyState;

    //Events
    @property NSString *pendingSyncEvent;

    @property TKEvent *noneEvent;
    @property TKEvent *syncedEvent;
    @property TKEvent *failureEvent;
    @property TKEvent *createEvent;
    @property TKEvent *updateEvent;
    @property TKEvent *pendingEvent;
    @property TKEvent *destroyEvent;
@end

@implementation RRecordSyncer

-(id) initWithResourceURI:(NSString *)resourceURI andObject:(NSObject<RRecordSyncerProtocol> *)object {
    self = [super init];

    if (self) {
        self.object = object;
        _resourceURI = resourceURI;
        self.syncStateMachine = [TKStateMachine new];
        self.networkOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:resourceURI]];
        [self initStates];
        [self initEvents];
        [_syncStateMachine activate];
    }

    return self;
}

-(NSString *)state {
    NSString *strState = @"none";
    switch ([_object.syncedState integerValue]) {
        case kRRecordSyncerSYNCED:
            strState = @"synced";
            break;
        case kRRecordSyncerFAILURE:
            strState = @"failure";
            break;
        case kRRecordSyncerCREATE:
            strState = @"create";
            break;
        case kRRecordSyncerPENDING:
            strState = @"pending";
            break;
        case kRRecordSyncerUPDATE:
            strState = @"update";
            break;
        case kRRecordSyncerDESTROY:
            strState = @"destroy";
            break;
    }
    return strState;
}


-(void) initStates {
    __weak RRecordSyncer* weakSelf = self;

    self.noneState = [TKState stateWithName:@"none"];
    [_noneState setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
        [weakSelf markState:[NSNumber numberWithInteger:kRRecordSyncerNONE]];
        weakSelf.pendingSyncEvent = @"";
        [weakSelf sendFinishedNotification];
    }];

    self.syncedState = [TKState stateWithName:@"synced"];
    [_syncedState setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
        [weakSelf markState:[NSNumber numberWithInteger:kRRecordSyncerSYNCED]];
        weakSelf.pendingSyncEvent = @"";
        [weakSelf sendFinishedNotification];
    }];

    self.failureState = [TKState stateWithName:@"failure"];

    [_failureState setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
        [weakSelf markState:[NSNumber numberWithInteger:kRRecordSyncerFAILURE]];
        if ([weakSelf.pendingSyncEvent isEqualToString:@""]) {
            weakSelf.pendingSyncEvent = [transition.userInfo objectForKey:@"event"];
        }

        [weakSelf performSelector:@selector(pendEvent) withObject:nil afterDelay:10];
    }];

    TKState *create = [TKState stateWithName:@"create"];
    self.createState = create;

    [_createState setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
        [weakSelf markState:[NSNumber numberWithInteger:kRRecordSyncerCREATE]];
        [weakSelf sendStartNotification];
        NSDictionary *parameters = [weakSelf objectParams];
        NSString *URI = [NSString stringWithFormat: @"%@.json", weakSelf.resourceURI];

        [weakSelf.networkOperationManager POST:URI parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [operation cancel];
            NSDictionary *response = weakSelf.recordName ? [(NSDictionary *)responseObject objectForKey:weakSelf.recordName] : responseObject;

            weakSelf.object.remoteId = [NSString stringWithFormat:@"%@", [response objectForKey:weakSelf.remoteId]];
            [weakSelf.object save];

            [weakSelf.syncStateMachine fireEvent:@"pending" userInfo:@{@"event" : weakSelf.pendingSyncEvent} error:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([weakSelf.pendingSyncEvent isEqualToString:@"synced"]) {
                weakSelf.pendingSyncEvent = @"";
                [weakSelf.syncStateMachine fireEvent:@"failure" userInfo:@{@"event" : @"create"} error:nil];
            } else {
                [weakSelf.syncStateMachine fireEvent:@"failure" userInfo:@{@"event" : weakSelf.pendingSyncEvent} error:nil];
            }

            [weakSelf sendFailureNotificationWithError:error];
        }];
    }];

    self.pendingState = [TKState stateWithName:@"pending"];
    [_pendingState setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
        [weakSelf markState:[NSNumber numberWithInteger:kRRecordSyncerPENDING]];

        [weakSelf.networkOperationManager.operationQueue setSuspended:YES];
        NSString *nextEvent = [transition.userInfo objectForKey:@"event"];
        BOOL immediateTransition = [[weakSelf.networkOperationManager.operationQueue operations] count] == 0;

        if (immediateTransition) {
            if ([nextEvent isEqualToString:@"destroy"]) {
                weakSelf.pendingSyncEvent = @"none";
            } else {
                weakSelf.pendingSyncEvent = @"synced";
            }
            [weakSelf.syncStateMachine fireEvent:nextEvent userInfo:@{} error:nil];
        } else {
            weakSelf.pendingSyncEvent = nextEvent;
        }

        [weakSelf.networkOperationManager.operationQueue setSuspended:NO];
    }];

    self.updateState = [TKState stateWithName:@"update"];
    [_updateState setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
        [weakSelf markState:[NSNumber numberWithInteger:kRRecordSyncerUPDATE]];
        [weakSelf sendStartNotification];
        NSDictionary *parameters = [weakSelf objectParams];

        NSString *URI =[NSString stringWithFormat: @"%@/%@", weakSelf.resourceURI, weakSelf.object.remoteId];

        [weakSelf.networkOperationManager PUT:URI parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [weakSelf.syncStateMachine fireEvent:@"pending" userInfo:@{@"event" : weakSelf.pendingSyncEvent} error:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([weakSelf.pendingSyncEvent isEqualToString:@"synced"]) {
                weakSelf.pendingSyncEvent = @"";
                [weakSelf.syncStateMachine fireEvent:@"failure" userInfo:@{@"event" : @"update"} error:nil];
            } else {
                [weakSelf.syncStateMachine fireEvent:@"failure" userInfo:@{@"event" : weakSelf.pendingSyncEvent} error:nil];
            }

            [weakSelf sendFailureNotificationWithError:error];
        }];
    }];

    self.destroyState = [TKState stateWithName:@"destroy"];
    [_destroyState setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
        [weakSelf markState:[NSNumber numberWithInteger:kRRecordSyncerDESTROY]];
        [weakSelf sendStartNotification];
        NSString *URI =[NSString stringWithFormat: @"%@/%@", weakSelf.resourceURI, weakSelf.object.remoteId];

        [weakSelf.networkOperationManager DELETE:URI parameters: @{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [weakSelf.syncStateMachine fireEvent:@"pending" userInfo:@{@"event" : weakSelf.pendingSyncEvent} error:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([weakSelf.pendingSyncEvent isEqualToString:@"none"]) {
                weakSelf.pendingSyncEvent = @"";
                [weakSelf.syncStateMachine fireEvent:@"failure" userInfo:@{@"event" : @"destroy", @"error" : @""} error:nil];
            } else {
                [weakSelf.syncStateMachine fireEvent:@"failure" userInfo:@{@"event" : weakSelf.pendingSyncEvent} error:nil];
            }

            [weakSelf sendFailureNotificationWithError:error];
        }];
    }];

    [_syncStateMachine addStates:@[_noneState, _syncedState, _failureState, _createState, _pendingState, _updateState, _destroyState]];

    if (_object) {
        _syncStateMachine.initialState = [_syncStateMachine stateNamed:[self state]];
    } else {
        _syncStateMachine.initialState = _noneState;
    }
}

-(void)markState:(NSNumber *)state {
    if (_object) {
        _object.syncedState = state;
        if ([state integerValue] == kRRecordSyncerNONE) {
            _object.remoteId = @"";
        }
        [_object save];
    } else {
        //raise some execption here.
    }
}

-(void) initEvents {
    self.syncedEvent = [TKEvent eventWithName:@"synced" transitioningFromStates:@[_pendingState] toState: _syncedState];

    self.failureEvent = [TKEvent eventWithName:@"failure" transitioningFromStates:@[_createState, _updateState, _destroyState] toState: _failureState];

    self.createEvent = [TKEvent eventWithName:@"create" transitioningFromStates:@[_pendingState] toState: _createState];

    self.updateEvent = [TKEvent eventWithName:@"update" transitioningFromStates:@[_pendingState] toState: _updateState];

    self.pendingEvent = [TKEvent eventWithName:@"pending" transitioningFromStates:@[ _createState, _destroyState, _updateState, _syncedState, _failureState, _noneState, _pendingState] toState: _pendingState];

    self.destroyEvent = [TKEvent eventWithName:@"destroy" transitioningFromStates:@[_pendingState] toState: _destroyState];

    self.noneEvent = [TKEvent eventWithName:@"none" transitioningFromStates:@[_pendingState] toState: _noneState];

    [_syncStateMachine addEvents:@[_syncedEvent, _failureEvent, _createEvent, _destroyEvent, _updateEvent, _noneEvent, _pendingEvent]];
}

-(void)resume{
    switch ([_object.syncedState integerValue]) {
        case kRRecordSyncerCREATE:
            [self create];
            break;
        case kRRecordSyncerPENDING:
        case kRRecordSyncerFAILURE:
            if (![_object.remoteId isEqualToString:@""]) {
                [self update];
            } else {
                [self create];
            }
            break;
        case kRRecordSyncerUPDATE:
            [self update];
            break;
        case kRRecordSyncerDESTROY:
            [self destroy];
            break;
    }
}

-(void)pendEvent:(NSString *)event {
    [_syncStateMachine fireEvent:@"pending" userInfo:@{@"event" : event} error:nil];
}

-(void)pendEvent {
    [self pendEvent:_pendingSyncEvent];
}

-(void)create{
    if ([_syncStateMachine isInState:@"failure"])
        _pendingSyncEvent = @"create";
    else {
        [self pendEvent:@"create"];
    }
}

-(void)update {
    if ([_syncStateMachine isInState:@"failure"]) {
        _pendingSyncEvent = @"update";
    } else {
        [self pendEvent:@"update"];
    }
}

-(void)destroy{
    if ([_syncStateMachine isInState:@"failure"]) {
        _pendingSyncEvent = @"destroy";
    } else {
        [self pendEvent:@"destroy"];
    }
}

- (NSDictionary *)objectParams {
    NSMutableDictionary *objectParams = [[NSMutableDictionary alloc] init];

    if (_recordName) {
        [objectParams setObject:[[NSMutableDictionary alloc] init] forKey:_recordName];
    }

    NSMutableDictionary *attributeParams = ([objectParams objectForKey:_recordName]) ? [objectParams objectForKey:_recordName] : objectParams;

    for(NSString* attribute in _attributeMapping) {
        NSString *key = [_attributeMapping objectForKey:attribute];
        SEL attributeSelector = NSSelectorFromString(attribute);
        id value = [_object performSelector:attributeSelector];
        if (value) {
            [attributeParams setObject:value forKey:key];
        }
    }

    return objectParams;
}

- (BOOL)canUpdate {
    return ![_object.remoteId isEqualToString:@""];
}

- (void)sendStartNotification {
    if (_recordName && _object) {
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@SyncDidStart", _recordName]
                                                            object:nil
                                                          userInfo:@{@"record" : _object}];
    }
}

- (void)sendFinishedNotification {
    if (_recordName && _object) {
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@SyncDidEnd", _recordName]
                                                            object:nil
                                                          userInfo:@{@"record" : _object}];
    }
}

- (void)sendFailureNotificationWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@SyncDidFail", _recordName]
                                                        object:nil
                                                      userInfo:@{@"record" : _object, @"error" : error}];
}


@end
