//
//  BRRemoveGuestView.h
//  Book Room
//
//  Created by DX169-XL on 2014-05-09.
//  Copyright (c) 2014 Pivotal Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRRemoveGuestViewDelegate <NSObject>

- (void)didCancel;
- (void)removeContact;

@end

@interface BRRemoveGuestView : UIView

@property (nonatomic, weak) id<BRRemoveGuestViewDelegate>delegate;

- (void)configureForGuest:(NSDictionary *)guest;

@end
