//
//  BRDatePickerViewController.m
//  Book Room
//
//  Created by DX169-XL on 2014-05-09.
//  Copyright (c) 2014 Pivotal Labs. All rights reserved.
//

#import "BRDatePickerViewController.h"

@interface BRDatePickerViewController () <BRDatePickerViewDelegate>

@end

@implementation BRDatePickerViewController

#pragma mark -
#pragma mark Private Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.delegate = self;
    [self.view configureSubViews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark BRDatePickerViewDelegate Methods

- (void)didCancelPicker {
    if ([self.delegate conformsToProtocol:@protocol(BRDatePickerViewControllerDelegate)]) {
        [self.delegate dismissPickerViewController];
    }
}

- (void)didSelectDate:(NSDate *)date {
    if ([self.delegate conformsToProtocol:@protocol(BRDatePickerViewControllerDelegate)]) {
        [self.delegate didSelectDate:date ofType:self.type];
    }
}

@end
