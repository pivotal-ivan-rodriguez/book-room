//
//  BRRemoveGuestView.m
//  Book Room
//
//  Created by DX169-XL on 2014-05-09.
//  Copyright (c) 2014 Pivotal Labs. All rights reserved.
//

#import "BRRemoveGuestView.h"

@interface BRRemoveGuestView ()

@property (strong, nonatomic) IBOutlet UILabel *guestLabel;

@end

@implementation BRRemoveGuestView

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

- (void)configureForGuest:(NSDictionary *)guest {
    self.guestLabel.text = [NSString stringWithFormat:@"Remove %@ from the guest list?",guest[kGoogleContactResponseNameKey]];
}

#pragma mark -
#pragma mark IBActions

- (IBAction)cancelButtonTapped:(UIButton *)sender {
    if ([self.delegate conformsToProtocol:@protocol(BRRemoveGuestViewDelegate)]) {
        [self.delegate didCancel];
    }
}

- (IBAction)removeButtonTapped:(UIButton *)sender {
    if ([self.delegate conformsToProtocol:@protocol(BRRemoveGuestViewDelegate)]) {
        [self.delegate removeContact];
    }
}

@end
