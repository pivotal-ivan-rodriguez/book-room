//
//  BRDatePickerView.h
//  Book Room
//
//  Created by DX169-XL on 2014-05-09.
//  Copyright (c) 2014 Pivotal Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRDatePickerViewDelegate <NSObject>

- (void)didCancelPicker;
- (void)didSelectDate:(NSDate *)date;

@end

@interface BRDatePickerView : UIView

@property (nonatomic, weak) id<BRDatePickerViewDelegate>delegate;

- (void)configureSubViews;

@end
