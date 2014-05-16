//
//  BRGuestCollectionViewControllerCell.h
//  Book Room
//
//  Created by DX169-XL on 2014-05-09.
//  Copyright (c) 2014 Pivotal Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BRGuest;

@interface BRGuestCollectionViewControllerCell : UICollectionViewCell

- (void)configureForGuest:(BRGuest *)guest;

@end
