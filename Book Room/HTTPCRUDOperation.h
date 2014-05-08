//
//  HTTPCRUDOperation.h
//  
//
//  Created by Adrian Kemp on 12/18/2013.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


#import <Foundation/Foundation.h>
#import "HTTPCRUDInterfaces.h"
#import "HTTPCRUDDefinitions.h"

@class HTTPCRUDOperation;
@class GTMOAuth2Authentication;
typedef void (^HTTPCRUDOperationCompletionBlock)(__weak HTTPCRUDOperation *HTTPCRUDOperation);

typedef enum {
    kHTTPCRUDOperationCalendar,
    kHTTPCRUDOperationContacts
} HTTPCRUDOperationType;

@interface HTTPCRUDOperation : NSOperation

#pragma mark - Callback Properties
@property (nonatomic, weak) id <HTTPCRUDOperationSyncDelegate> syncDelegate;

#pragma mark - Response Properties
@property (nonatomic, strong) NSHTTPURLResponse *HTTPResponse;
@property (nonatomic, assign) Class expectedReturnType;
@property (nonatomic, strong) id returnedObject;
@property (nonatomic, assign) HTTPCRUDOperationState state;

#pragma mark - Request Properties
@property (nonatomic, assign) HTTPCRUDOperationType type;
@property (nonatomic, assign) HTTPMethod method;
@property (nonatomic, strong) NSString *protocol;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSDictionary *additionalHeaders;
@property (nonatomic, readonly) NSMutableDictionary *queryParameters;
@property (nonatomic, strong) NSDictionary *bodyJSON;
@property (nonatomic, strong) NSDictionary *attachments;

+ (NSOperationQueue *)networkingQueue;
+ (GTMOAuth2Authentication *)googleAuth;
+ (void)setGoogleAuth:(GTMOAuth2Authentication *)newGoogleAuth;

- (void)configureForData:(id)collection;
- (void)success;
- (void)failure:(NSError *)error;
- (void)setCompletionBlock:(HTTPCRUDOperationCompletionBlock)completionBlock;
- (id)testResponse;

@end
