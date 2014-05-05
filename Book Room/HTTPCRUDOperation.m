//
//  HTTPCRUDOperation.m
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
//

#import "HTTPCRUDOperation.h"
#import <CoreData/CoreData.h>
#import <objc/runtime.h>

NSString * const HTTPMethodGetString = @"GET";
NSString * const HTTPMethodPutString = @"PUT";
NSString * const HTTPMethodPostString = @"POST";
NSString * const HTTPMethodDeleteString = @"DELETE";
NSString * const HTTPMethodPatchString = @"PATCH";

typedef void (^HTTPCRUDOperationInternalCompletionBlock)();

NSDictionary static *NSDictionaryRemoveNSNulls(NSDictionary **dictionary);
NSArray static *NSArrayRemoveNSNulls(NSArray **array);
id static NSCollectionRemoveNSNulls(id *collection);

@interface HTTPCRUDOperation ()

@property (nonatomic, assign) NSInteger networkActivityCount;
@property (nonatomic, copy) HTTPCRUDOperationInternalCompletionBlock internalCompletionBlock;
@property (nonatomic, readonly) HTTPCRUDOperationCompletionBlock userProvidedCompletionBlock;

@end


@implementation HTTPCRUDOperation

static NSURL *baseURL;
+ (NSURL *)baseURL {
    return baseURL;
}

+ (void)setBaseURL:(NSURL *)newBaseURL {
    baseURL = newBaseURL;
}

static NSOperationQueue *networkingQueue;
+ (NSOperationQueue *)networkingQueue {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkingQueue = [NSOperationQueue new];
    });
    return networkingQueue;
}

- (void)main {
    if (self.isCancelled) {
        return;
    }
    
    NSError *error;
    self.returnedObject = [self performJSONFetch:&error];
    
    if (self.isCancelled) {
        return;
    }
    
#ifdef OFFLINE_MODE
    [self success];
    return;
#endif
    
    if (self.HTTPResponse.statusCode >= 200 && self.HTTPResponse.statusCode <= 299) {
        [self success];
    } else {
        [self failure:error];
    }
    
}

- (void)setCompletionBlock:(HTTPCRUDOperationCompletionBlock)completionBlock {
    __weak HTTPCRUDOperation *weakSelf = self;
    _userProvidedCompletionBlock = completionBlock;
    [super setCompletionBlock:^{
        if([NSThread isMainThread]) {
            weakSelf.userProvidedCompletionBlock(weakSelf);
        } else {
            HTTPCRUDOperation *dispatchSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                dispatchSelf.userProvidedCompletionBlock(dispatchSelf);
            });
        }
    }];
}

- (void)configureForData:(id)collection {
    if ([collection isKindOfClass:[NSSet class]]) {
        [[NSException exceptionWithName:@"Invalid Collection Type" reason:@"You passed an unrecognized collection type" userInfo:nil] raise];
    } else if ([collection isKindOfClass:[NSArray class]]) {
        [[NSException exceptionWithName:@"Invalid Collection Type" reason:@"You passed an unrecognized collection type" userInfo:nil] raise];
    } else if ([collection isKindOfClass:[NSDictionary class]]) {
        self.bodyJSON = collection;
    } else {
        [[NSException exceptionWithName:@"Invalid Collection Type" reason:@"You passed an unrecognized collection type" userInfo:nil] raise];
    }
}

- (void)success {
    [self.syncDelegate operationSucceeded:self];
    return;
}

- (void)failure:(NSError *)error {
    [self.syncDelegate operationFailed:self withError:error];
    return;
}

- (id)testResponse {
    return nil;
}

- (void)setOrAddError:(NSError *)error toErrorRerence:(NSError **)errorRerence {
    if(!*errorRerence) {
        *errorRerence = error;
    } else {
        //Combine the errors
        *errorRerence = error;
    }
}

- (id)performJSONFetch:(NSError **)error {
#ifdef OFFLINE_MODE
    return [self testResponse];
#endif
    NSData *jsonObjectData;
    
    if (self.bodyJSON) {
        if (self.method == HTTPMethodGet) {
            NSError *badMethodError = [NSError errorWithDomain:@"Remote Operation"
                                                          code:0x01
                                                      userInfo:@{NSLocalizedFailureReasonErrorKey : @"You provided a body on a GET method"}];
            [self setOrAddError:badMethodError toErrorRerence:error];
        } else {
            if (self.attachments) {
                NSMutableData *multiPartFriendlyObjectData = [NSMutableData new];
                for (NSString *fullyQualifiedKey in self.bodyJSON) {
                    NSString *boundaryString = [NSString stringWithFormat:@"--Boundary+0xAbCdGbOuNdArY\r\nContent-Disposition: form-data; name=\"%@\";\r\nContent-Type:application/json\r\n\r\n", fullyQualifiedKey];
                    [multiPartFriendlyObjectData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
                    [multiPartFriendlyObjectData appendData:[self.bodyJSON[fullyQualifiedKey] dataUsingEncoding:NSUTF8StringEncoding]];
                    [multiPartFriendlyObjectData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                }
                jsonObjectData = [multiPartFriendlyObjectData copy];
                
            } else {
                jsonObjectData = [NSJSONSerialization dataWithJSONObject:self.bodyJSON
                                                                 options:NSJSONWritingPrettyPrinted error:error];
            }
        }
    }
    
    NSURL *requestURL = [self URLForPath:self.path withParameters:self.queryParameters];
    NSLog(@"requesting %@", requestURL);
    NSString *appVersion = [NSString stringWithFormat:@"%@-%@",
                            [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"],
                            [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"]];
    
    NSMutableURLRequest *jsonRequest = [NSMutableURLRequest requestWithURL:requestURL];
    [jsonRequest setHTTPMethod:[self stringFromOperationMethod:self.method]];
    [jsonRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [jsonRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    if (self.attachments) {
        [jsonRequest setValue:@"multipart/form-data; boundary=Boundary+0xAbCdGbOuNdArY" forHTTPHeaderField:@"Content-Type"];
    } else {
        [jsonRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    [jsonRequest setValue:appVersion forHTTPHeaderField:@"X-App-Version"];
    for (NSString *headerField in self.additionalHeaders) {
        [jsonRequest setValue:self.additionalHeaders[headerField] forHTTPHeaderField:headerField];
    }
    
    if (self.attachments) {
        NSMutableData *jsonObjectDataWithAttachements = [NSMutableData new];
        if (jsonObjectData.length) {
            [jsonObjectDataWithAttachements appendData:jsonObjectData];
        }
        
        NSInteger attachmentIndex = 0;
        for (NSString *key in self.attachments) {
            NSString *contentSeparator = [NSString stringWithFormat:@"--Boundary+0xAbCdGbOuNdArY\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"attachment.png\"\r\nContent-Type:image/png\r\nContent-Transfer-Encoding: binary\r\n\r\n", key];
            [jsonObjectDataWithAttachements appendData:[contentSeparator dataUsingEncoding:NSUTF8StringEncoding]];
            [jsonObjectDataWithAttachements appendData:UIImagePNGRepresentation(self.attachments[key])];
            [jsonObjectDataWithAttachements appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            attachmentIndex++;
        }
        [jsonObjectDataWithAttachements appendData:[@"--Boundary+0xAbCdGbOuNdArY--\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        jsonObjectData = [jsonObjectDataWithAttachements copy];
    }
    
    [jsonRequest setHTTPBody:jsonObjectData];
    
    NSHTTPURLResponse *jsonResponse = nil;
    
    [self pushNetworkActivityIndicator];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:jsonRequest returningResponse:&jsonResponse error:error];
    [self popNetworkActivityIndicator];
    NSString *connectionErrorString = nil;
    if ((*error)) {
        connectionErrorString = (*error).localizedDescription;
    }
    [NSHTTPCookie cookiesWithResponseHeaderFields:[jsonResponse allHeaderFields] forURL:[NSURL URLWithString:@"/"]];
    
    self.HTTPResponse = jsonResponse;
    if (self.HTTPResponse == nil) {
        NSError *nilResponseError = [NSError errorWithDomain:@"Remote Operation"
                                                        code:0x03
                                                    userInfo:@{NSLocalizedFailureReasonErrorKey : @"No response returned for operaiton"}];
        [self setOrAddError:nilResponseError toErrorRerence:error];
    }
    
    if (responseData.length > 0) {
        id returnedObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:error];
        self.returnedObject = NSCollectionRemoveNSNulls(&returnedObject);
    }
    if (connectionErrorString && !self.returnedObject[@"error"]) {
        self.returnedObject = @{@"error":connectionErrorString};
    }
    
    return self.returnedObject;
}

- (NSURL *)URLForPath:(NSString *)path withParameters:(NSDictionary *)parameters {
    if (parameters) {
        if (self.method == HTTPMethodGet || self.method == HTTPMethodDelete) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?%@",baseURL, path, [self encodeParameters:parameters]]];
            return url;
        }
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", baseURL, path]];
}

- (NSString *)encodeParameters:(NSDictionary *)parameters {
    NSMutableString *parametersString = [NSMutableString string];
    for (NSString *key in [parameters allKeys]) {
        NSString *p = parameters[key];
        [parametersString appendFormat:@"&%@=%@",key,p];
    }
    return parametersString;
}


#pragma mark - Enumeration Conversion Selectors
- (NSString *)stringFromOperationMethod:(HTTPMethod)method {
    switch (method) {
        case HTTPMethodGet:
            return HTTPMethodGetString;
        case HTTPMethodDelete:
            return HTTPMethodDeleteString;
        case HTTPMethodPost:
            return HTTPMethodPostString;
        case HTTPMethodPut:
            return HTTPMethodPutString;
        case HTTPMethodPatch:
            return HTTPMethodPatchString;
        default:
            return @"";
    }
}

- (HTTPMethod)operationMethodFromString:(NSString *)string {
    if ([string isEqualToString:HTTPMethodGetString]) {
        return HTTPMethodGet;
    } else if ([string isEqualToString:HTTPMethodPostString]) {
        return HTTPMethodPost;
    } else if ([string isEqualToString:HTTPMethodPutString]) {
        return HTTPMethodPut;
    } else if ([string isEqualToString:HTTPMethodDeleteString]) {
        return HTTPMethodDelete;
    } else if ([string isEqualToString:HTTPMethodPatchString]) {
        return HTTPMethodPatch;
    } else {
        [NSException raise:NSInternalInconsistencyException format:@"Invalid value passed for method"];
        return -1;
    }
}

#pragma mark - Network Activity Selectors
- (void)pushNetworkActivityIndicator {
    self.networkActivityCount++;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    });
}

- (void)popNetworkActivityIndicator {
    self.networkActivityCount--;
    
    if (self.networkActivityCount < 0) {
        NSLog(@"** Unbalanced calls to push/pop network activity **");
        self.networkActivityCount = 0;
    }
    
    if (self.networkActivityCount == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    }
}

@end

NSDictionary static *NSDictionaryRemoveNSNulls(NSDictionary **dictionary) {
    BOOL argumentWasMutable = NO;
    if([*dictionary isKindOfClass:[NSMutableDictionary class]]) {
        argumentWasMutable = YES;
    }
    NSMutableDictionary *returnDictioanry = [*dictionary mutableCopy];
    for (NSString *key in *dictionary) {
        NSNull *null = [*dictionary valueForKey:key];
        if([null isKindOfClass:[NSNull class]]) {
            [returnDictioanry removeObjectForKey:key];
        } else {
            [returnDictioanry setObject:NSCollectionRemoveNSNulls(&null) forKey:key];
        }
    }
    if(argumentWasMutable) {
        *dictionary = [returnDictioanry mutableCopy];
    } else {
        *dictionary = [returnDictioanry copy];
    }
    return *dictionary;
}

NSArray static *NSArrayRemoveNSNulls(NSArray **array) {
    BOOL argumentWasMutable = NO;
    if([*array isKindOfClass:[NSMutableArray class]]) {
        argumentWasMutable = YES;
    }
    NSMutableArray *returnArray = [*array mutableCopy];
    for (__autoreleasing NSNull *null in *array) {
        if([null isKindOfClass:[NSNull class]]) {
            [returnArray removeObject:null];
        } else {
            int index = [returnArray indexOfObject:null];
            [returnArray replaceObjectAtIndex:index withObject:NSCollectionRemoveNSNulls(&null)];
        }
    }
    if(argumentWasMutable) {
        *array = [returnArray mutableCopy];
    } else {
        *array = [returnArray copy];
    }
    return *array;
}

id static NSCollectionRemoveNSNulls(id *collection) {
    if ([*collection isKindOfClass:[NSDictionary class]]) {
        return NSDictionaryRemoveNSNulls(collection);
    } else if([*collection isKindOfClass:[NSArray class]]) {
        return NSArrayRemoveNSNulls(collection);
    } else {
        return *collection;
    }
}
