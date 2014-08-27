//
//  BRMainCollectionViewLayout.m
//  Book Room
//
//  Created by DX169-XL on 2014-05-22.
//  Copyright (c) 2014 Pivotal Labs. All rights reserved.
//

#import "BRMainCollectionViewLayout.h"

@implementation BRMainCollectionViewLayout

- (void)prepareLayout {
    
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes* attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    attributes.alpha = 0.0;

    CGSize size = [self collectionView].frame.size;
    attributes.center = CGPointMake(size.width / 2.0, size.height / 2.0);
    return attributes;
}

@end
