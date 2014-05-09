//
//  BRDatePickerView.m
//  Book Room
//
//  Created by DX169-XL on 2014-05-09.
//  Copyright (c) 2014 Pivotal Labs. All rights reserved.
//

#import "BRDatePickerView.h"

@interface BRDatePickerView ()

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation BRDatePickerView

#pragma mark -
#pragma mark Private Methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark -
#pragma mark Public Methods

- (void)configureSubViews {
    NSDate *now = [NSDate date];
    NSInteger timeInterval = 30;

    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:now];
    NSInteger minutes = [components minute];

    NSInteger remainder = minutes % timeInterval;
    if(remainder) {
        minutes += timeInterval - remainder;
        [components setMinute:minutes];
        now = [calendar dateFromComponents:components];
    }

    self.datePicker.minimumDate = now;
    self.datePicker.minuteInterval = timeInterval;

    [self.datePicker setDate:now];
}

#pragma mark -
#pragma mark IBActions

- (IBAction)cancelButtonTapped:(UIButton *)sender {
    if ([self.delegate conformsToProtocol:@protocol(BRDatePickerViewDelegate)]) {
        [self.delegate didCancelPicker];
    }
}

- (IBAction)setDateButtonTapped:(UIButton *)sender {
    if ([self.delegate conformsToProtocol:@protocol(BRDatePickerViewDelegate)]) {
        [self.delegate didSelectDate:self.datePicker.date];
    }
}

@end
