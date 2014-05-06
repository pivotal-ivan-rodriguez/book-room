//
//  BRCalendarResourcesOperation.m
//  Book Room
//
//  Created by DX169-XL on 2014-05-06.
//  Copyright (c) 2014 Pivotal Labs. All rights reserved.
//

#import "BRCalendarResourcesOperation.h"

@implementation BRCalendarResourcesOperation

- (NSString *)path {
    return @"resource/2.0/pivotallabs.com/";
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

@end
