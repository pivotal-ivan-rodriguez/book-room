//
//  BRConstants.m
//  Book Room
//
//  Created by DX169-XL on 2014-05-06.
//  Copyright (c) 2014 Pivotal Labs. All rights reserved.
//

#import "BRConstants.h"

@implementation BRConstants

NSString * const kGoogleAppsDomain = @"pivotallabs.com";

NSString * const kGoogleFeedKey = @"feed";
NSString * const kGoogleEntryKey = @"entry";
NSString * const kGooglePropertiesKey = @"apps:property";
NSString * const kGoogleNameKey = @"name";
NSString * const kGoogleValueKey = @"value";
NSString * const kGoogleResourceNameKey = @"resourceCommonName";
NSString * const kGoogleResourceEmailkey = @"resourceEmail";
NSString * const kGoogleFreeBusyResponseBusykey = @"busy";
NSString * const kGoogleFreeBusyResponseErrorkey = @"errors";
NSString * const kGoogleContactResponseNameKey = @"gd:name";
NSString * const kGoogleContactResponseFullNameKey = @"gd:fullName";
NSString * const kGoogleContactResponseEmailKey = @"gd:email";

NSString * const kModalMeetingRoomsCollectionViewControllerSegue = @"modalMeetingRoomsCollectionViewControllerSegue";

NSString * const kMeetingRoomsCollectionViewCellIdentifier = @"meetingRoomsCollectionViewCellIdentifier";
NSString * const kContactsCollectionViewCellIdentifier = @"contactsCollectionViewCellIdentifier";

NSString * const kLoadingMeetingRoomsText = @"Loading free rooms...";
NSString * const kNoMeetingRoomsText = @"Error: We couldn't load the meeting rooms. Please try again.";

@end
