//
//  BRContactSearchOperation.h
//  Book Room
//
//  Created by DX169-XL on 2014-05-07.
//  Copyright (c) 2014 Pivotal Labs. All rights reserved.
//

#import "HTTPCRUDOperation.h"

@interface BRContactSearchOperation : HTTPCRUDOperation

@property (nonatomic, strong) NSString *query;

@end
