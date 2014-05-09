//
//  BRRemoveGuestViewController.m
//  Book Room
//
//  Created by DX169-XL on 2014-05-09.
//  Copyright (c) 2014 Pivotal Labs. All rights reserved.
//

#import "BRRemoveGuestViewController.h"

@interface BRRemoveGuestViewController () <BRRemoveGuestViewDelegate>

@end

@implementation BRRemoveGuestViewController

#pragma mark -
#pragma mark Setters

- (void)setGuest:(NSDictionary *)guest {
    _guest = guest;
    [self.view configureForGuest:_guest];
}

#pragma mark -
#pragma mark Private Methods

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

    self.view.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark BRRemoveGuestViewDelegate Methods

- (void)didCancel {
    if ([self.delegate conformsToProtocol:@protocol(BRRemoveGuestViewControllerDelegate)]) {
        [self.delegate dismissGuestViewController];
    }
}

- (void)removeContact {
    if ([self.delegate conformsToProtocol:@protocol(BRRemoveGuestViewControllerDelegate)]) {
        [self.delegate removeGuest:self.guest];
    }
}

@end
