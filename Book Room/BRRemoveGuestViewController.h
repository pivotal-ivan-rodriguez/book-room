//
//  BRRemoveGuestViewController.h
//  Book Room
//
//  Created by DX169-XL on 2014-05-09.
//  Copyright (c) 2014 Pivotal Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRRemoveGuestView.h"

@class BRGuest;

@protocol BRRemoveGuestViewControllerDelegate <NSObject>

- (void)dismissGuestViewController;
- (void)removeGuest:(BRGuest *)guest;

@end

@interface BRRemoveGuestViewController : UIViewController

@property (nonatomic, strong) BRRemoveGuestView *view;
@property (nonatomic, strong) BRGuest *guest;
@property (nonatomic, weak) id<BRRemoveGuestViewControllerDelegate>delegate;

@end
