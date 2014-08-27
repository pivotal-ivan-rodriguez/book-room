//
//  BRHomeView.m
//  Book Room
//
//  Created by DX169-XL on 2014-05-05.
//  Copyright (c) 2014 Pivotal Labs. All rights reserved.
//

#import "BRHomeView.h"
#import "BRMainCollectionViewLayout.h"

@interface BRHomeView () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *eventTitleTextField;
@property (strong, nonatomic) IBOutlet UIButton *fromButton;
@property (strong, nonatomic) IBOutlet UIButton *toButton;
@property (strong, nonatomic) IBOutlet UITextField *guestsTextField;
@property (strong, nonatomic) IBOutlet UIButton *addGuestsButton;
@property (strong, nonatomic) IBOutlet UIButton *createEventButton;
@property (strong, nonatomic) IBOutlet UIButton *meetingRoomButton;

@property (strong, nonatomic) NSDateFormatter *formatter;

@end

@implementation BRHomeView

#pragma mark -
#pragma mark Getters

- (NSDateFormatter *)formatter {
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        _formatter.dateFormat = @"EEEEEE dd MMM ''YY @ HH:mm";
    }
    return _formatter;
}

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

- (IBAction)addButtonTapped:(UIButton *)sender {
    if (self.guestsTextField.text.length > 0) {
        if ([self.delegate conformsToProtocol:@protocol(BRHomeViewDelegate)]) {
            [self.delegate addGuest:self.guestsTextField.text];
        }

    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please select a Guest first." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)tapGestureRecognized:(UITapGestureRecognizer *)tap {
    if ([self.eventTitleTextField isFirstResponder]) {
        [self.eventTitleTextField resignFirstResponder];

    } else if ([self.guestsTextField isFirstResponder]) {
        [self.guestsTextField resignFirstResponder];

    } else {
        return;
    }

    if ([self.delegate conformsToProtocol:@protocol(BRHomeViewDelegate)]) {
        [self.delegate tapGestureRecognized:tap];
    }
}

- (void)pinchGestureRecognized:(UIPinchGestureRecognizer *)pinch {
}

#pragma mark -
#pragma mark Public Methods

- (void)configureSubViews {
    self.fromButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.fromButton.layer.borderWidth = 1;
    self.fromButton.layer.cornerRadius = 5;

    self.toButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.toButton.layer.borderWidth = 1;
    self.toButton.layer.cornerRadius = 5;

    self.addGuestsButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.addGuestsButton.layer.borderWidth = 1;
    self.addGuestsButton.layer.cornerRadius = 5;

    self.createEventButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.createEventButton.layer.borderWidth = 1;
    self.createEventButton.layer.cornerRadius = 5;

    self.meetingRoomButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.meetingRoomButton.layer.borderWidth = 1;
    self.meetingRoomButton.layer.cornerRadius = 5;

    self.eventTitleTextField.delegate = self;
    self.guestsTextField.delegate = self;

    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureRecognized:)];
    pinch.cancelsTouchesInView = NO;
    [self addGestureRecognizer:pinch];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
    [tap requireGestureRecognizerToFail:pinch];
    tap.cancelsTouchesInView = NO;
    [self addGestureRecognizer:tap];
}

- (void)setFromButtonTitleForDate:(NSDate *)date {
    [self.fromButton setTitle:[self.formatter stringFromDate:date] forState:UIControlStateNormal];
}

- (void)setToButtonTitleForDate:(NSDate *)date {
    [self.toButton setTitle:[self.formatter stringFromDate:date] forState:UIControlStateNormal];
}

- (void)setRoomButtonTitleForRoom:(NSDictionary *)room {
    [self.meetingRoomButton setTitle:room[kGoogleResourceNameKey] forState:UIControlStateNormal];
}

- (void)setTextForGuestsTextFiew:(NSString *)text {
    self.guestsTextField.text = text;
}

- (void)clearData {
    self.eventTitleTextField.text = nil;
    self.guestsTextField.text = nil;
}

#pragma mark -
#pragma mark UITextFieldDelegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == 1) {
        if ([self.delegate conformsToProtocol:@protocol(BRHomeViewDelegate)]) {
            [self.delegate searchForQuery:[textField.text stringByReplacingCharactersInRange:range withString:string]];
        }
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField.tag == 1) {
        if ([self.delegate conformsToProtocol:@protocol(BRHomeViewDelegate)]) {
            [self.delegate cancelSearch];
        }
    }
    return YES;
}

@end
