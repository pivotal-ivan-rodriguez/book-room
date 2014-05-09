//
//  BRDatePickerViewController.h
//  Book Room
//
//  Created by DX169-XL on 2014-05-09.
//  Copyright (c) 2014 Pivotal Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRDatePickerView.h"

typedef enum {
    kFromDatePicker,
    kToDatePicker
} DatePickerType;

@protocol BRDatePickerViewControllerDelegate <NSObject>

- (void)dismissPickerViewController;
- (void)didSelectDate:(NSDate *)date ofType:(DatePickerType)type;

@end

@interface BRDatePickerViewController : UIViewController

@property (nonatomic, strong) BRDatePickerView *view;
@property (nonatomic, weak) id<BRDatePickerViewControllerDelegate>delegate;

@property (nonatomic, assign) DatePickerType type;

@end
