//
//  NetworkOperation.m
//  Conferences
//
//  Created by Egor Tolstoy on 02/09/15.
//  Copyright © 2015 Rambler&Co. All rights reserved.
//

#import "NetworkOperation.h"

#import "NetworkClient.h"

#import <CocoalumberJack/CocoaLumberjack.h>
#import <libextobjc/EXTScope.h>

static const int ddLogLevel = DDLogFlagVerbose;

@interface NetworkOperation ()

@property (strong, nonatomic) id<NetworkClient> networkClient;

@end

@implementation NetworkOperation

@synthesize delegate = _delegate;
@synthesize input = _input;
@synthesize output = _output;

#pragma mark - Initialization

- (instancetype)initWithNetworkClient:(id<NetworkClient>)networkClient {
    self = [super init];
    if (self) {
        _networkClient = networkClient;
    }
    return self;
}

+ (instancetype)operationWithNetworkClient:(id<NetworkClient>)networkClient {
    return [[[self class] alloc] initWithNetworkClient:networkClient];
}

#pragma mark - Operation execution

- (void)main {
    DDLogVerbose(@"The operation %@ is started", NSStringFromClass([self class]));
    NSURLRequest *inputData = [self.input obtainInputDataWithTypeValidationBlock:^BOOL(id data) {
        if ([data isKindOfClass:[NSURLRequest class]]) {
            DDLogVerbose(@"The input data for the operation %@ has passed the validation", NSStringFromClass([self class]));
            return YES;
        }
        DDLogVerbose(@"The input data for the operation %@ hasn't passed the validation. The input data type is: %@",
                     NSStringFromClass([self class]),
                     NSStringFromClass([data class]));
        return NO;
    }];
    
    DDLogVerbose(@"Start sending request to the remote server");
    @weakify(self);
    [self.networkClient sendRequest:inputData completionBlock:^(id data, NSError *error) {
        @strongify(self);
        if (error) {
            DDLogError(@"NetworkClient in operation %@ has produced an error: %@", NSStringFromClass([self class]), error);
        }
        if (data) {
            DDLogVerbose(@"Server returned data with length: %li", [(NSData *)data length]);
        }
        
        [self completeOperationWithData:data error:error];
    }];
}

- (void)completeOperationWithData:(id)data error:(NSError *)error {
    if (data) {
        [self.output didCompleteChainableOperationWithOutputData:data];
        DDLogVerbose(@"The operation %@ output data has been passed to the buffer", NSStringFromClass([self class]));
    }
    
    [self.delegate didCompleteChainableOperationWithError:error];
    DDLogVerbose(@"The operation %@ is over", NSStringFromClass([self class]));
    [self complete];
}

#pragma mark - Debug

- (NSString *)debugDescription {
    NSArray *additionalDebugInfo = @[
                                     [NSString stringWithFormat:@"Works with client: %@\n",
                                      [self.networkClient debugDescription]]
                                     ];
    return [OperationDebugDescriptionFormatter debugDescriptionForOperation:self
                                                         withAdditionalInfo:additionalDebugInfo];
}

@end