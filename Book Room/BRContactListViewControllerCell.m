//
//  BRContactListViewControllerCell.m
//  Book Room
//
//  Created by DX169-XL on 2014-05-08.
//  Copyright (c) 2014 Pivotal Labs. All rights reserved.
//

#import "BRContactListViewControllerCell.h"

@interface BRContactListViewControllerCell ()

@property (strong, nonatomic) IBOutlet UILabel *contactLabel;

@end

@implementation BRContactListViewControllerCell

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

- (void)configureForContact:(NSDictionary *)contact {
    self.contactLabel.text = [NSString stringWithFormat:@"%@ - %@",contact[kGoogleContactResponseNameKey],contact[kGoogleContactResponseEmailKey]];
}

@end
