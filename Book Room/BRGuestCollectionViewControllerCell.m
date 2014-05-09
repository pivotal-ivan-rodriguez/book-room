//
//  BRGuestCollectionViewControllerCell.m
//  Book Room
//
//  Created by DX169-XL on 2014-05-09.
//  Copyright (c) 2014 Pivotal Labs. All rights reserved.
//

#import "BRGuestCollectionViewControllerCell.h"

@interface BRGuestCollectionViewControllerCell ()

@property (nonatomic, weak) IBOutlet UILabel *guestLabel;

@end

@implementation BRGuestCollectionViewControllerCell

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
    self.guestLabel.text = [NSString stringWithFormat:@"%@ - %@",guest[kGoogleContactResponseNameKey],guest[kGoogleContactResponseEmailKey]];
}

@end
