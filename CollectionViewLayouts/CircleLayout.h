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
 *  the nearest bound.
 *
 *  @warning Values close to 1.0 may cause items to overlap if the value returned
 *  from @c diameterForItemAtIndexPath: is sufficiently large.
 */
@property (nonatomic, assign) CGFloat sectionClusteringFactor;

@property (nonatomic, weak) id<CircleLayoutDelegate> delegate;

@end

@protocol CircleLayoutDelegate <NSObject>

/**
 *  @return The count of items in the given section.
 *
 *  @param section The section whose amount of items is needed.
 *
 *  @warning Do not call -[UICollectionView numberOfItemsInSection:] within the
 *  implementation to this method. This method is provided to avoid a crash when
 *  trying to query the UICollectionView data source during updates.
 */
- (NSUInteger)numberOfItemsInSection:(NSUInteger)section;

/**
 *  @return A CGFloat describing how wide an item should be.
 *
 *  @warning A sufficiently high value may cause items to overlap if @c sectionClusteringFactor
 *  is near 1.0.
 */
- (CGFloat)diameterForItemAtIndexPath:(NSIndexPath *)indexPath;

@end