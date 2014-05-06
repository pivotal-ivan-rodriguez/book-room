//
//  BRMeetingRoomsCollectionViewController.h
//  Book Room
//
//  Created by DX169-XL on 2014-05-06.
//  Copyright (c) 2014 Pivotal Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRMeetingRoomsCollectionViewControllerDelegate <NSObject>

- (void)dismissViewController;
- (void)didSelectMeetingRoom:(NSDictionary *)meetingRoom;

@end

@interface BRMeetingRoomsCollectionViewController : UICollectionViewController

@property (nonatomic, weak) id<BRMeetingRoomsCollectionViewControllerDelegate>delegate;
@property (nonatomic, strong) NSArray *meetingRooms;
@end
