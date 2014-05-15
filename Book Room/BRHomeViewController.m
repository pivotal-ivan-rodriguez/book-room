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
#import "UIImage+ImageEffects.h"
#import "BRDatePickerViewController.h"
#import "BRGuestCollectionViewControllerCell.h"
#import "BRRemoveGuestViewController.h"
#import "MBProgressHUD.h"

static NSString * const kKeychainItemName = @"Book a Room";
static NSString * const kClientID = @"776916698629-jm882d2nnh738lo5qio3quqehej4i4a3.apps.googleusercontent.com";
static NSString * const kClientSecret = @"8hTo-W7xyeQhVO3domrWM7Ys";

typedef enum {
    kNoGuestsAlert,
    kNoRoomAlert,
    kGuestNotInContactList
} AlertType;

@interface BRHomeViewController () <BRHomeViewDelegate, BRMeetingRoomsCollectionViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, BRDatePickerViewControllerDelegate, BRRemoveGuestViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) BRMeetingRoomsCollectionViewController *meetingRoomsViewController;
@property (nonatomic, weak) BRDatePickerViewController *fromDatePickerViewController;
@property (nonatomic, weak) BRDatePickerViewController *toDatePickerViewController;
@property (nonatomic, weak) BRRemoveGuestViewController *removeGuestViewController;

@property (nonatomic, strong) GTLServiceCalendar *calendarService;
@property (nonatomic, strong) GTLCalendarCalendarListEntry *userCalendar;
@property (nonatomic, strong) NSArray *meetingRooms;
@property (nonatomic, strong) NSDictionary *meetingRoom;
@property (nonatomic, strong) NSMutableArray *contactsList;
@property (nonatomic, strong) NSDate *fromDate;
@property (nonatomic, strong) NSDate *toDate;
@property (nonatomic, strong) NSMutableArray *guests;
@property (nonatomic, strong) NSDictionary *selectedGuest;
@property (nonatomic, strong) NSString *eventTitle;
@property (nonatomic, strong) MBProgressHUD *hud;

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

- (NSMutableArray *)guests {
    if (!_guests) {
        _guests = [NSMutableArray array];
    }
    return _guests;
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
        self.meetingRoomsViewController.minDate = self.fromDate;
        self.meetingRoomsViewController.maxDate = self.toDate;

    } else if ([segue.identifier isEqualToString:kModalFromDatePickerViewControllerSegue]) {
        self.fromDatePickerViewController = segue.destinationViewController;
        self.fromDatePickerViewController.delegate = self;
        self.fromDatePickerViewController.view.backgroundColor = [UIColor colorWithPatternImage:[self blurrImageForView:self.fromDatePickerViewController.view]];
        self.fromDatePickerViewController.type = kFromDatePicker;

    } else if ([segue.identifier isEqualToString:kModalToDatePickerViewControllerSegue]) {
        self.toDatePickerViewController = segue.destinationViewController;
        self.toDatePickerViewController.delegate = self;
        self.toDatePickerViewController.view.backgroundColor = [UIColor colorWithPatternImage:[self blurrImageForView:self.toDatePickerViewController.view]];
        self.toDatePickerViewController.type = kToDatePicker;

    } else if ([segue.identifier isEqualToString:kModalRemoveGuestViewControllerSegue]) {
        self.removeGuestViewController = segue.destinationViewController;
        self.removeGuestViewController.delegate = self;
        NSIndexPath *indexPath = sender;
        self.removeGuestViewController.guest = self.guests[indexPath.item];
        self.removeGuestViewController.view.backgroundColor = [UIColor colorWithPatternImage:[self blurrImageForView:self.removeGuestViewController.view]];
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
    self.view.guestsCollectionView.dataSource = self;
    self.view.guestsCollectionView.delegate = self;

    [self.view.collectionView registerNib:[UINib nibWithNibName:@"BRContactListViewControllerCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kContactsCollectionViewCellIdentifier];
    [self.view.guestsCollectionView registerNib:[UINib nibWithNibName:@"BRGuestCollectionViewControllerCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kGuestsCollectionViewCellIdentifier];
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
    self.view.collectionView.layer.cornerRadius = 5.0f;

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

- (UIImage *)blurrImageForView:(UIView *)view {
    CGRect initialFrame = [view convertRect:view.bounds toView:self.view];

    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, self.view.window.screen.scale);

    [self.view drawViewHierarchyInRect:CGRectMake(-initialFrame.origin.x, -initialFrame.origin.y, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) afterScreenUpdates:YES];

    UIImage *blurImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    blurImage = [blurImage applyLightEffect];

    return blurImage;
}

- (void)createEvent {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = @"Creating meeting...";

    GTLCalendarEventDateTime *start = [GTLCalendarEventDateTime object];
    GTLCalendarEventDateTime *end = [GTLCalendarEventDateTime object];
    start.dateTime = [GTLDateTime dateTimeWithDate:self.fromDate timeZone:[NSTimeZone systemTimeZone]];
    end.dateTime = [GTLDateTime dateTimeWithDate:self.toDate timeZone:[NSTimeZone systemTimeZone]];

    GTLCalendarEventAttendee *room = [GTLCalendarEventAttendee object];
    room.displayName = self.meetingRoom[kGoogleResourceNameKey];
    room.email = self.meetingRoom[kGoogleResourceEmailkey];

    NSMutableArray *attendees = [NSMutableArray array];
    [attendees addObject:room];
    for (NSDictionary *guest in self.guests) {
        GTLCalendarEventAttendee *g = [GTLCalendarEventAttendee object];
        g.displayName = guest[kGoogleContactResponseNameKey];
        g.email = guest[kGoogleContactResponseEmailKey];
        [attendees addObject:g];
    }

    GTLCalendarEvent *calEvent = [GTLCalendarEvent object];
    calEvent.summary = self.eventTitle;
    calEvent.start = start;
    calEvent.end = end;
    calEvent.attendees = attendees;
    calEvent.location = self.meetingRoom[kGoogleResourceNameKey];

    GTLQueryCalendar *query = [GTLQueryCalendar queryForEventsInsertWithObject:calEvent calendarId:self.userCalendar.identifier];
    [self.calendarService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        [self.hud hide:YES];

        if (!error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Pivotal Meetings" message:@"Meeting created successfully!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [self clearData];
            NSLog(@"response %@",object);

        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Pivotal Meetings" message:[NSString stringWithFormat:@"Error creating the meeting: %@",error] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (void)clearData {
    self.guests = nil;
    self.meetingRoom = nil;
    self.fromDate = nil;
    self.toDate = nil;
    [self.view clearData];
    [self.view.guestsCollectionView reloadData];
}

#pragma mark -
#pragma mark BRHomeViewDelegate Methods

- (void)createEventWithTitle:(NSString *)title {
    self.eventTitle = title;

    if (self.fromDate == nil || self.toDate == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please a start and finish date first" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;

    } else if (self.guests.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your guest list is empty, do you want to continue?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create",nil];
        alert.tag = kNoGuestsAlert;
        [alert show];
        return;

    } else if (self.meetingRoom == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You haven't selected a meeting room, do you want to continue?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create",nil];
        alert.tag = kNoRoomAlert;
        [alert show];
        return;
    }

    [self createEvent];
}

- (void)meetingRoomButtonTapped {
    BOOL shouldPerform = self.fromDate != nil && self.toDate != nil;
    if (!shouldPerform) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please select a start and finish date first." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];

    } else {
        [self performSegueWithIdentifier:kModalMeetingRoomsCollectionViewControllerSegue sender:self];
    }
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
    self.selectedGuest = nil;
    [self hideSearchCollectionView];
}

- (void)addGuest:(NSString *)guest {
    if (self.selectedGuest && ![self.guests containsObject:self.selectedGuest]) {
        [self.guests addObject:self.selectedGuest];
        [self.view.guestsCollectionView reloadData];
        [self.view setTextForGuestsTextFiew:nil];
        self.selectedGuest = nil;

    } else if (!self.selectedGuest && ![self.guests containsObject:guest]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Pivotal Rooms" message:[NSString stringWithFormat:@"The Guest '%@' is not in your contacts list, do you want to include him/her in your guests list?",guest] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Include",nil];
        alert.tag = kGuestNotInContactList;
        [alert show];
        self.selectedGuest = @{kGoogleContactResponseNameKey:guest,kGoogleContactResponseEmailKey:guest};
    }
}

- (void)tapGestureRecognized:(UITapGestureRecognizer *)tap {
    if (!self.view.collectionView.hidden && !CGRectContainsPoint(self.view.collectionView.frame, [tap locationInView:self.view])) {
        [self hideSearchCollectionView];
    }
}

#pragma mark -
#pragma mark BRMeetingRoomsCollectionViewControllerDelegate Methods

- (void)dismissViewController {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSelectMeetingRoom:(NSDictionary *)meetingRoom {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    self.meetingRoom = meetingRoom;
    [self.view setRoomButtonTitleForRoom:self.meetingRoom];
}

#pragma mark -
#pragma mark UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView.tag == 1) return self.guests.count;

    return self.contactsList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell;

    if (collectionView.tag == 0) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kContactsCollectionViewCellIdentifier forIndexPath:indexPath];
        [(BRContactListViewControllerCell *)cell configureForContact:self.contactsList[indexPath.item]];

    } else if (collectionView.tag == 1) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kGuestsCollectionViewCellIdentifier forIndexPath:indexPath];
        [(BRGuestCollectionViewControllerCell *)cell configureForGuest:self.guests[indexPath.item]];
    }

    return cell;
}

#pragma mark -
#pragma mark UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    if (collectionView.tag == 0) {
        if (indexPath.item >= self.contactsList.count) return;

        self.selectedGuest = self.contactsList[indexPath.item];
        [self.view setTextForGuestsTextFiew:self.selectedGuest[kGoogleContactResponseNameKey]];
        [self hideSearchCollectionView];

    } else if (collectionView.tag == 1) {
        [self performSegueWithIdentifier:kModalRemoveGuestViewControllerSegue sender:indexPath];
    }
}

#pragma mark -
#pragma mark BRDatePickerViewControllerDelegate Methods

- (void)didSelectDate:(NSDate *)date ofType:(DatePickerType)type {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    switch (type) {
        case kFromDatePicker:
            self.fromDate = date;
            [self.view setFromButtonTitleForDate:self.fromDate];
            break;
        case kToDatePicker:
            self.toDate = date;
            [self.view setToButtonTitleForDate:self.toDate];
            break;
        default:
            break;
    }
}

- (void)dismissPickerViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark BRRemoveGuestViewControllerDelegate Methods

- (void)dismissGuestViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)removeGuest:(NSDictionary *)guest {
    [self dismissViewControllerAnimated:YES completion:nil];

    [self.guests removeObject:guest];
    [self.view.guestsCollectionView reloadData];
}

#pragma mark -
#pragma mark UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kNoGuestsAlert) {
        if (buttonIndex == 1) {
            [self createEvent];
        }
    } else if (alertView.tag == kNoRoomAlert) {
        if (buttonIndex == 1) {
            [self createEvent];
        }
    } else if (alertView.tag == kGuestNotInContactList) {
        if (buttonIndex == 1) {
            [self.guests addObject:self.selectedGuest];
            [self.view.guestsCollectionView reloadData];
        }
        [self.view setTextForGuestsTextFiew:nil];
        self.selectedGuest = nil;
    }
}

@end
