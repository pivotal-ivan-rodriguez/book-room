//
//  BRContactSearchOperation.m
//  Book Room
//
//  Created by DX169-XL on 2014-05-07.
//  Copyright (c) 2014 Pivotal Labs. All rights reserved.
//

#import "BRContactSearchOperation.h"

@implementation BRContactSearchOperation

- (NSString *)path {
    return [NSString stringWithFormat:@"default/full?q=%@",self.query];
}

- (NSMutableDictionary *)queryParameters {
    return nil;
}

- (void)success {
    self.state = HTTPCRUDOperationSuccessfulState;
}

- (void)failure:(NSError *)error {
    self.state = HTTPCRUDOperationFailState;

    NSLog(@"Calendar Resources Operation failed %@ (%@)",self.returnedObject,error);
}

- (HTTPCRUDOperationType)type {
    return kHTTPCRUDOperationContacts;
}

@end
