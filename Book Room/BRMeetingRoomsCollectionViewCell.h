//
//  BRMeetingRoomsCollectionViewCell.h
//  Book Room
//
//  Created by DX169-XL on 2014-05-06.
//  Copyright (c) 2014 Pivotal Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRMeetingRoomsCollectionViewCell : UICollectionViewCell

- (void)configureForMeetingRoom:(NSDictionary *)room;
- (void)configureForNoMeetingRooms;

@end
