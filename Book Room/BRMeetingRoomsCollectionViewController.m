//
//  BRMeetingRoomsCollectionViewController.m
//  Book Room
//
//  Created by DX169-XL on 2014-05-06.
//  Copyright (c) 2014 Pivotal Labs. All rights reserved.
//

#import "BRMeetingRoomsCollectionViewController.h"
#import "BRMeetingRoomsCollectionViewCell.h"
#import "GTLCalendar.h"
#import "MBProgressHUD.h"

static NSInteger const kMeetingRoomsFetchStep = 20;

@interface BRMeetingRoomsCollectionViewController ()

@property (nonatomic, strong) NSMutableArray *availableMeetingRooms;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation BRMeetingRoomsCollectionViewController

#pragma mark -
#pragma mark Getters

- (NSMutableArray *)availableMeetingRooms {
    if (!_availableMeetingRooms) {
        _availableMeetingRooms = [NSMutableArray array];
    }
    return _availableMeetingRooms;
}

#pragma mark -
#pragma mark Setters

- (void)setMeetingRooms:(NSArray *)meetingRooms {
    _meetingRooms = meetingRooms;

    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = @"Loading free rooms...";

    [self getMeetingRoomScheduleFromMeetingRooms:_meetingRooms forCount:0];
}

#pragma mark -
#pragma mark Private Methods

- (void)getMeetingRoomScheduleFromMeetingRooms:(NSArray *)meetingRooms forCount:(NSUInteger)count {

    if (count >= meetingRooms.count) {
        [self.collectionView reloadData];
        [self.hud hide:YES];
        return;
    }

    __block NSUInteger roomsCount = count;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray *rooms = [NSMutableArray array];

        for (int i=count;i<roomsCount+kMeetingRoomsFetchStep;i++) {
            if (i >= meetingRooms.count) break;

            NSDictionary *room = meetingRooms[i];
            if (room[kGoogleResourceEmailkey]) {
                GTLCalendarFreeBusyRequestItem *item = [GTLCalendarFreeBusyRequestItem object];
                item.identifier = room[kGoogleResourceEmailkey];
                [rooms addObject:item];
            }
        }

        GTLDateTime *min = [GTLDateTime dateTimeWithDate:self.minDate timeZone:[NSTimeZone systemTimeZone]];
        GTLDateTime *max = [GTLDateTime dateTimeWithDate:self.maxDate timeZone:[NSTimeZone systemTimeZone]];

        GTLQueryCalendar *query = [GTLQueryCalendar queryForFreebusyQuery];
        query.timeMin = min;
        query.timeMax = max;
        query.items = rooms;

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.calendarService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
                if (!error && [object isKindOfClass:[GTLCalendarFreeBusyResponse class]]) {

                    GTLCalendarFreeBusyResponse *response = object;
                    for (NSString *roomKey in response.calendars.additionalJSONKeys) {
                        NSError *error = response.calendars.JSON[roomKey][kGoogleFreeBusyResponseErrorkey];
                        NSArray *busyArray = response.calendars.JSON[roomKey][kGoogleFreeBusyResponseBusykey];

                        if (!error && !busyArray) {
                            [self.availableMeetingRooms addObject:[self getRoomForEmail:roomKey]];

                        } else if (!error && busyArray) {
                            [self addMeetingRoom:roomKey ifNoConflictingTime:busyArray];
                        }
                    }

                    [self getMeetingRoomScheduleFromMeetingRooms:meetingRooms forCount:roomsCount+=kMeetingRoomsFetchStep];
                }
            }];
        });
    });
}

- (id)getRoomForEmail:(NSString *)email {
    for (NSDictionary *room in self.meetingRooms) {
        if ([room[kGoogleResourceEmailkey] isEqualToString:email]) {
            return room;
        }
    }
    return [NSNull null];
}

- (void)addMeetingRoom:(NSString *)roomKey ifNoConflictingTime:(NSArray *)busy {
    NSLog(@"%@ - %@",[self getRoomForEmail:roomKey][kGoogleResourceNameKey], busy);
    for (NSDictionary *time in busy) {

        GTLDateTime *start = [GTLDateTime dateTimeWithRFC3339String:time[@"start"]];
        GTLDateTime *end = [GTLDateTime dateTimeWithRFC3339String:time[@"end"]];

        NSTimeInterval minTimeInterval = [self.minDate timeIntervalSince1970];
        NSTimeInterval maxTimeInterval = [self.maxDate timeIntervalSince1970];
        NSTimeInterval startTimeInterval = [start.date timeIntervalSince1970];
        NSTimeInterval endTimeInterval = [end.date timeIntervalSince1970];

        if (minTimeInterval <= startTimeInterval && startTimeInterval < maxTimeInterval) {
            break;
        } else if (startTimeInterval <= minTimeInterval && maxTimeInterval <= endTimeInterval) {
            break;
        } else if (minTimeInterval < endTimeInterval && endTimeInterval <= maxTimeInterval) {
            break;
        }

        [self.availableMeetingRooms addObject:[self getRoomForEmail:roomKey]];
    }
}

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

    [self.collectionView registerNib:[UINib nibWithNibName:@"BRMeetingRoomsCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kMeetingRoomsCollectionViewCellIdentifier];
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark IBActions

- (IBAction)closeButtonTapped:(UIBarButtonItem *)sender {
    if ([self.delegate conformsToProtocol:@protocol(BRMeetingRoomsCollectionViewControllerDelegate)]) {
        [self.delegate dismissViewController];
    }
}

#pragma mark -
#pragma mark UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.availableMeetingRooms.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BRMeetingRoomsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMeetingRoomsCollectionViewCellIdentifier forIndexPath:indexPath];
    [cell configureForMeetingRoom:self.availableMeetingRooms[indexPath.item]];
    return cell;
}

#pragma mark -
#pragma mark UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate conformsToProtocol:@protocol(BRMeetingRoomsCollectionViewControllerDelegate)]) {
        [self.delegate didSelectMeetingRoom:self.availableMeetingRooms[indexPath.item]];
    }
}

@end
