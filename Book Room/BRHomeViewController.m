//
//  BRViewController.m
//  Book Room
//
//  Created by DX169-XL on 2014-05-05.
//  Copyright (c) 2014 Pivotal Labs. All rights reserved.
//

#import "BRHomeViewController.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLCalendar.h"
#import "BRCalendarResourcesOperation.h"
#import "BRContactSearchOperation.h"
#import "BRMeetingRoomsCollectionViewController.h"
#import "BRContactListViewControllerCell.h"

static NSString * const kKeychainItemName = @"Book a Room";
static NSString * const kClientID = @"776916698629-jm882d2nnh738lo5qio3quqehej4i4a3.apps.googleusercontent.com";
static NSString * const kClientSecret = @"8hTo-W7xyeQhVO3domrWM7Ys";

@interface BRHomeViewController () <BRHomeViewDelegate, BRMeetingRoomsCollectionViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) BRMeetingRoomsCollectionViewController *meetingRoomsViewController;
@property (nonatomic, strong) GTLServiceCalendar *calendarService;
@property (nonatomic, strong) GTLCalendarCalendarListEntry *userCalendar;
@property (nonatomic, strong) NSArray *meetingRooms;
@property (nonatomic, strong) NSDictionary *meetingRoom;
@property (nonatomic, strong) NSMutableArray *contactsList;
@end

@implementation BRHomeViewController

#pragma mark -
#pragma mark Getters

- (GTLServiceCalendar *)calendarService {
    if (!_calendarService) {
        _calendarService = [[GTLServiceCalendar alloc] init];
        _calendarService.shouldFetchNextPages = YES;
        _calendarService.retryEnabled = YES;
    }
    return _calendarService;
}

- (NSMutableArray *)contactsList {
    if (!_contactsList) {
        _contactsList = [NSMutableArray array];
    }
    return _contactsList;
}

#pragma mark -
#pragma mark Private Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kModalMeetingRoomsCollectionViewControllerSegue]) {
        UINavigationController *navController = segue.destinationViewController;
        self.meetingRoomsViewController = (BRMeetingRoomsCollectionViewController *)navController.topViewController;
        self.meetingRoomsViewController.calendarService = self.calendarService;
        self.meetingRoomsViewController.delegate = self;
        self.meetingRoomsViewController.meetingRooms = self.meetingRooms;
        NSDate *now = [NSDate date];
        self.meetingRoomsViewController.minDate = [now dateByAddingTimeInterval:1*60*60];;
        self.meetingRoomsViewController.maxDate = [now dateByAddingTimeInterval:2*60*60];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.delegate = self;
    [self.view configureSubViews];

    GTMOAuth2Authentication *auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName clientID:kClientID clientSecret:kClientSecret];
    if ([auth canAuthorize]) {
        [self isAuthorizedWithAuthentication:auth];

    } else {
        [self showAuthLoginViewController];
    }

    self.view.collectionView.dataSource = self;
    self.view.collectionView.delegate = self;

    [self.view.collectionView registerNib:[UINib nibWithNibName:@"BRContactListViewControllerCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kContactsCollectionViewCellIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error {
    if (error) {
        NSLog(@"Auth failed %@",error);
    } else {
        [self isAuthorizedWithAuthentication:auth];
    }

    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showAuthLoginViewController {
    NSString *scope = [GTMOAuth2Authentication scopeWithStrings:kGTLAuthScopeCalendar,kGTLAuthScopeCalendarReadonly,@"https://apps-apis.google.com/a/feeds/calendar/resource/",@"https://www.google.com/m8/feeds/", nil];
    GTMOAuth2ViewControllerTouch *authViewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:scope clientID:kClientID clientSecret:kClientSecret keychainItemName:kKeychainItemName delegate:self finishedSelector:@selector(viewController:finishedWithAuth:error:)];

    [self.navigationController presentViewController:authViewController animated:YES completion:nil];
}

- (void)isAuthorizedWithAuthentication:(GTMOAuth2Authentication *)auth {
    [HTTPCRUDOperation setGoogleAuth:auth];
    [self.calendarService setAuthorizer:auth];
    [self loadDriveFiles];
}

- (void)loadDriveFiles {
    GTLQueryCalendar *query = [GTLQueryCalendar queryForCalendarListList];

    [self.calendarService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        if (!error && [object isKindOfClass:[GTLCalendarCalendarList class]]) {
            for (GTLCalendarCalendarListEntry *calendarEntry in ((GTLCalendarCalendarList *)object).items) {
                if ([calendarEntry.primary boolValue]) {
                    self.userCalendar = calendarEntry;
                    [self getCalendarResources];
                    break;
                }
            }

        } else {
            NSLog(@"Request failed %@",error);
        }
    }];
}

- (void)getCalendarResources {
    BRCalendarResourcesOperation *operation = [BRCalendarResourcesOperation new];
    operation.method = HTTPMethodGet;
    __block NSMutableArray *meetingRooms = [NSMutableArray array];
    [operation setCompletionBlock:^(HTTPCRUDOperation *__weak HTTPCRUDOperation) {
        if (HTTPCRUDOperation.state == HTTPCRUDOperationSuccessfulState) {
            NSArray *entries = HTTPCRUDOperation.returnedObject[kGoogleFeedKey][kGoogleEntryKey];
            NSMutableDictionary *entryData;

            for (NSDictionary *entry in entries) {
                NSArray *dataEntries = entry[kGooglePropertiesKey];
                entryData = [NSMutableDictionary dictionary];
                for (NSDictionary *data in dataEntries) {
                    if (data[kGoogleValueKey] && data[kGoogleNameKey]) {
                        [entryData setObject:data[kGoogleValueKey] forKey:data[kGoogleNameKey]];
                    }
                }
                if (entryData) [meetingRooms addObject:entryData];
            }

            self.meetingRooms = [meetingRooms copy];
        }
    }];
    [[HTTPCRUDOperation networkingQueue] addOperation:operation];
}

- (void)showSearchCollectionView {
    self.view.collectionView.alpha = 0;
    self.view.collectionView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.view.collectionView.alpha = 1.0;
    }];
}

- (void)hideSearchCollectionView {
    [UIView animateWithDuration:0.3 animations:^{
        self.view.collectionView.alpha = 0;

    } completion:^(BOOL finished) {
        self.view.collectionView.hidden = YES;
        self.view.collectionView.alpha = 1.0;
    }];
}

#pragma mark -
#pragma mark BRHomeViewDelegate Methods

- (void)createEventWithTitle:(NSString *)title {
    GTLCalendarEventDateTime *start = [GTLCalendarEventDateTime object];
    GTLCalendarEventDateTime *end = [GTLCalendarEventDateTime object];
    NSDate *now = [NSDate date];
    start.dateTime = [GTLDateTime dateTimeWithDate:now timeZone:[NSTimeZone systemTimeZone]];
    end.dateTime = [GTLDateTime dateTimeWithDate:[now dateByAddingTimeInterval:60*60] timeZone:[NSTimeZone systemTimeZone]];

    GTLCalendarEventAttendee *room = [GTLCalendarEventAttendee object];
    room.displayName = self.meetingRoom[kGoogleResourceNameKey];
    room.email = self.meetingRoom[kGoogleResourceEmailkey];

    GTLCalendarEvent *calEvent = [GTLCalendarEvent object];
    calEvent.summary = title;
    calEvent.start = start;
    calEvent.end = end;
    calEvent.attendees = @[room];
    calEvent.location = self.meetingRoom[kGoogleResourceNameKey];

    GTLQueryCalendar *query = [GTLQueryCalendar queryForEventsInsertWithObject:calEvent calendarId:self.userCalendar.identifier];
    [self.calendarService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        if (!error) {
            NSLog(@"response %@",object);

        } else {
            NSLog(@"Request failed %@",error);
        }
    }];
}

- (void)meetingRoomButtonTapped {
    [self performSegueWithIdentifier:kModalMeetingRoomsCollectionViewControllerSegue sender:self];
}

- (void)searchForQuery:(NSString *)query {
    if (query.length == 0) {
        [self cancelSearch];
        return;
    }

    if (self.view.collectionView.hidden) {
        [self showSearchCollectionView];
    }

    self.contactsList = nil;
    BRContactSearchOperation *operation = [BRContactSearchOperation new];
    operation.query = query;
    operation.method = HTTPMethodGet;
    [operation setCompletionBlock:^(HTTPCRUDOperation *__weak HTTPCRUDOperation) {
        if (HTTPCRUDOperation.state == HTTPCRUDOperationSuccessfulState) {
            NSArray *results = HTTPCRUDOperation.returnedObject[kGoogleFeedKey][kGoogleEntryKey];
            for (NSDictionary *result in results) {
                if (![result isKindOfClass:[NSDictionary class]]) continue;

                NSString *name = result[kGoogleContactResponseNameKey][kGoogleContactResponseFullNameKey][@"text"];
                NSString *email = result[kGoogleContactResponseEmailKey][@"address"];
                if (email) {
                    [self.contactsList addObject:@{kGoogleContactResponseNameKey:name?name:email,kGoogleContactResponseEmailKey:email}];
                }
            }
            [self.view.collectionView reloadData];
        } else {
            NSLog(@"Error searching: %@",HTTPCRUDOperation.returnedObject);
        }
    }];
    [[HTTPCRUDOperation networkingQueue] addOperation:operation];
}

- (void)cancelSearch {
    self.contactsList = nil;

    [self hideSearchCollectionView];
}

#pragma mark -
#pragma mark BRMeetingRoomsCollectionViewControllerDelegate Methods

- (void)dismissViewController {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSelectMeetingRoom:(NSDictionary *)meetingRoom {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    self.meetingRoom = meetingRoom;
}

#pragma mark -
#pragma mark UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.contactsList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BRContactListViewControllerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kContactsCollectionViewCellIdentifier forIndexPath:indexPath];

    [cell configureForContact:self.contactsList[indexPath.item]];

    return cell;
}

#pragma mark -
#pragma mark UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

}

@end
