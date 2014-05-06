//
//  BRMeetingRoomsCollectionViewCell.m
//  Book Room
//
//  Created by DX169-XL on 2014-05-06.
//  Copyright (c) 2014 Pivotal Labs. All rights reserved.
//

#import "BRMeetingRoomsCollectionViewCell.h"

@interface BRMeetingRoomsCollectionViewCell ()

@property (strong, nonatomic) IBOutlet UILabel *meetingRoomNameLabel;

@end

@implementation BRMeetingRoomsCollectionViewCell

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

- (void)configureForMeetingRoom:(NSDictionary *)room {
    self.meetingRoomNameLabel.text = room[kGoogleResourceNameKey];
}

@end
