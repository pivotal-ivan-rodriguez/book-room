//
//  BRHomeView.m
//  Book Room
//
//  Created by DX169-XL on 2014-05-05.
//  Copyright (c) 2014 Pivotal Labs. All rights reserved.
//

#import "BRHomeView.h"

@interface BRHomeView ()

@property (strong, nonatomic) IBOutlet UITextField *eventTitleTextField;
@property (strong, nonatomic) IBOutlet UIButton *createEventButton;
@property (strong, nonatomic) IBOutlet UIButton *meetingRoomButton;

@end

@implementation BRHomeView

#pragma mark -
#pragma mark Private Methods

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

#pragma mark -
#pragma mark IBActions

- (IBAction)createEventButtonTapped:(UIButton *)sender {
    if (self.eventTitleTextField.text.length > 0) {
        if ([self.delegate conformsToProtocol:@protocol(BRHomeViewDelegate)]) {
            [self.delegate createEventWithTitle:self.eventTitleTextField.text];
        }

    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter a Title for the Meeting" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)meetingRoomButtonTapped:(UIButton *)sender {
    if ([self.delegate conformsToProtocol:@protocol(BRHomeViewDelegate)]) {
        [self.delegate meetingRoomButtonTapped];
    }
}

#pragma mark -
#pragma mark Public Methods

- (void)configureSubViews {
    self.createEventButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.createEventButton.layer.borderWidth = 1;
    self.createEventButton.layer.cornerRadius = 5;

    self.meetingRoomButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.meetingRoomButton.layer.borderWidth = 1;
    self.meetingRoomButton.layer.cornerRadius = 5;
}

@end
