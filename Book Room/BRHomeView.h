//
//  BRHomeView.h
//  Book Room
//
//  Created by DX169-XL on 2014-05-05.
//  Copyright (c) 2014 Pivotal Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRHomeViewDelegate <NSObject>

- (void)createEventWithTitle:(NSString *)title;
- (void)meetingRoomButtonTapped;
@end

@interface BRHomeView : UIView

@property (nonatomic, weak) id<BRHomeViewDelegate>delegate;

- (void)configureSubViews;

@end
