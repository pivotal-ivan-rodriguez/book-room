//
//  BRHomeView.h
//  Book Room
//
//  Created by DX169-XL on 2014-05-05.
//  Copyright (c) 2014 Pivotal Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRHomeViewDelegate <NSObject>

- (void)createEventWithTitle:(NSString *)title;
- (void)meetingRoomButtonTapped;
- (void)searchForQuery:(NSString *)query;
- (void)cancelSearch;
- (void)addGuest:(NSString *)guest;
- (void)tapGestureRecognized:(UITapGestureRecognizer *)tap;

@end

@interface BRHomeView : UIView

@property (nonatomic, weak) id<BRHomeViewDelegate>delegate;

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UICollectionView *guestsCollectionView;

- (void)configureSubViews;
- (void)setFromButtonTitleForDate:(NSDate *)date;
- (void)setToButtonTitleForDate:(NSDate *)date;
- (void)setRoomButtonTitleForRoom:(NSDictionary *)room;
- (void)setTextForGuestsTextFiew:(NSString *)text;
- (void)clearData;

@end
