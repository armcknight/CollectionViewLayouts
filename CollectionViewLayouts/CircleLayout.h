//
//  CircleLayout.h
//  CollectionViewLayouts
//
//  Created by Ramon Bartl on 25.05.13.
//  Copyright (c) 2013 Ramon Bartl. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CircleLayoutDelegate;

@interface CircleLayout : UICollectionViewLayout

@property (nonatomic, assign) CGPoint layoutCenter;
@property (nonatomic, assign) CGFloat layoutRadius;
@property (nonatomic, assign) NSInteger cellCount;

/**
 *  A CGFloat between 0.0 and 1.0 that affects how much a section's
 *  items will be clustered together. Values outside the range will be clipped to 
 *  the nearest bound. A value of 0.0 results in all cells being displayed
 *  equidistant on the circle, regardless of section membership.
 *
 *  @warning Values close to 1.0 may cause items to overlap if the value returned
 *  from @c diameterForItemAtIndexPath: is sufficiently large.
 */
@property (nonatomic, assign) CGFloat sectionClusteringFactor;

@property (nonatomic, weak) id<CircleLayoutDelegate> delegate;

@end

@protocol CircleLayoutDelegate <NSObject>

/**
 *  @return A CGFloat describing how wide an item should be. Provided to dynamically
 *  change cell sizes on a layout invalidation call.
 *
 *  @warning A sufficiently high value may cause items to overlap if @c sectionClusteringFactor
 *  is near 1.0.
 */
- (CGFloat)diameterForItemAtIndexPath:(NSIndexPath *)indexPath;

@end