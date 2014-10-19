//
//  CircleLayout.h
//  CollectionViewLayouts
//
//  Created by Ramon Bartl on 25.05.13.
//  Copyright (c) 2013 Ramon Bartl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleLayout : UICollectionViewLayout

@property (nonatomic, assign) CGPoint layoutCenter;
@property (nonatomic, assign) CGFloat layoutRadius;

/**
 *  A CGFloat describing how wide an item should be.
 *
 *  @warning A sufficiently high value may cause items to overlap if @c sectionClusteringFactor 
 *  is near 1.0.
 */
@property (nonatomic, assign) CGFloat itemDiameter;

/**
 *  A CGFloat between 0.0 and 1.0 that affects how much a section's
 *  items will be clustered together. Values outside the range will be clipped to 
 *  the nearest bound.
 *
 *  @warning Values close to 1.0 may cause items to overlap if @c itemDiameter is 
 *  sufficiently large.
 */
@property (nonatomic, assign) CGFloat sectionClusteringFactor;

@end