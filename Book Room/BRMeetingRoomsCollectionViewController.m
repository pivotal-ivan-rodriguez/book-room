//
//  BRMeetingRoomsCollectionViewController.m
//  Book Room
//
//  Created by DX169-XL on 2014-05-06.
//  Copyright (c) 2014 Pivotal Labs. All rights reserved.
//

#import "BRMeetingRoomsCollectionViewController.h"
#import "BRMeetingRoomsCollectionViewCell.h"

@interface BRMeetingRoomsCollectionViewController ()

@end

@implementation BRMeetingRoomsCollectionViewController

#pragma mark -
#pragma mark Setters

- (void)setMeetingRooms:(NSArray *)meetingRooms {
    _meetingRooms = meetingRooms;
    [self.collectionView reloadData];
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
    return self.meetingRooms.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BRMeetingRoomsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMeetingRoomsCollectionViewCellIdentifier forIndexPath:indexPath];
    [cell configureForMeetingRoom:self.meetingRooms[indexPath.item]];
    return cell;
}

#pragma mark -
#pragma mark UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate conformsToProtocol:@protocol(BRMeetingRoomsCollectionViewControllerDelegate)]) {
        [self.delegate didSelectMeetingRoom:self.meetingRooms[indexPath.item]];
    }
}

@end
