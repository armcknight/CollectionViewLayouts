//
//  CircleLayout.m
//  CollectionViewLayouts
//
//  Created by Ramon Bartl on 25.05.13.
//  Copyright (c) 2013 Ramon Bartl. All rights reserved.
//

#import "CircleLayout.h"

/* Custom Layout need to implement the following methods

   collectionViewContentSize
   layoutAttributesForElementsInRect:
   layoutAttributesForItemAtIndexPath:
   layoutAttributesForSupplementaryViewOfKind:atIndexPath: (if your layout supports supplementary views)
   layoutAttributesForDecorationViewOfKind:atIndexPath: (if your layout supports decoration views)
   shouldInvalidateLayoutForBoundsChange:
 
 The core laout process is done in the following order:
 
   1. The `prepareLayout` method is your chance to do the up-front calculations needed to provide layout information.
   2. The `collectionViewContentSize` method is where you return the overall size of the entire content area based on your initial calculations.
   3. The `layoutAttributesForElementsInRect:` method returns the attributes for cells and views that are in the specified rectangle.
 */

@implementation CircleLayout {
    CGSize size;
    NSMutableArray *insertPaths, *deletePaths;
}


- (void)prepareLayout
{
    [super prepareLayout];
    NSLog(@"CircleLayout::prepareLayout");

    // content area is exactly our viewble area
    size = self.collectionView.frame.size;
}

- (CGSize)collectionViewContentSize
{
    NSLog(@"CircleLayout::collectionViewContentSize:size %.1fx%.1f", size.width, size.height);
    return size;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"CircleLayout::layoutAttributesForItemAtIndexPath:indexPath [%d, %d]", indexPath.section, indexPath.row);
    // instanciate the layout attributes object
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes
                                                    layoutAttributesForCellWithIndexPath:indexPath];

    attributes.size = CGSizeMake(self.itemDiameter, self.itemDiameter);
    
    CGPoint center;
    center = [self centerForItemAtIndexPath:indexPath];
    
    attributes.center = center;
    return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSLog(@"CircleLayout::layoutAttributesForElementsInRect");
    
    
    NSMutableArray *attributes = [NSMutableArray array];
    
    NSUInteger sections = [self.collectionView numberOfSections];
    for (NSUInteger section = 0; section < sections; section++) {
        NSUInteger items = [self.collectionView numberOfItemsInSection:section];
        for (NSUInteger item = 0; item < items; item++) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
        }
    }
    
    return attributes;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    NSLog(@"CircleLayout::prepareForCollectionViewUpdates: items=%@", updateItems);


    // remember inserted and deleted index paths for separate animations
    insertPaths = @[].mutableCopy;
    deletePaths = @[].mutableCopy;

    for (UICollectionViewUpdateItem *item in updateItems) {
        if (item.updateAction == UICollectionUpdateActionInsert) {
            [insertPaths addObject:item.indexPathAfterUpdate];
        } else if (item.updateAction == UICollectionUpdateActionDelete) {
            [deletePaths addObject:item.indexPathBeforeUpdate];
        }
    }

    NSLog(@"insertPaths=%@, deletePaths=%@", insertPaths, deletePaths);
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];

    // begin-transition attributes for inserted objects
    if ([insertPaths containsObject:itemIndexPath]) {
        attributes.alpha = 0.0;
        attributes.center = CGPointMake(_layoutCenter.x, _layoutCenter.y);
        attributes.size = CGSizeMake(self.itemDiameter * 2, self.itemDiameter * 2);
        NSLog(@"Appearing layout for **inserted** object [%ld, %ld] set", (long)itemIndexPath.section, (long)itemIndexPath.row);
    } else {
        // all other objects
      
        NSLog(@"Appearing layout for other object [%ld, %ld] set", (long)itemIndexPath.section, (long)itemIndexPath.row);
    }
    return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes * attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];

    // end-transition attributes for deleted objects
    if ([deletePaths containsObject:itemIndexPath]) {
        attributes.alpha = 0.0;
        attributes.center = CGPointMake(_layoutCenter.x, _layoutCenter.y);
        attributes.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0);
        NSLog(@"Disappearing layout for **deleted** object [%ld, %ld] set", (long)itemIndexPath.section, (long)itemIndexPath.row);
    } else {
        // all other objects
        NSLog(@"Disappearing layout for other object [%ld, %ld] set", (long)itemIndexPath.section, (long)itemIndexPath.row);
    }

    return attributes;
}


- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

#pragma mark - Setters

- (void)setSectionClusteringFactor:(CGFloat)sectionClusteringFactor
{
    if (sectionClusteringFactor > 1.0f) {
        _sectionClusteringFactor = 1.0f;
    } else if (sectionClusteringFactor < 0.0f) {
        _sectionClusteringFactor = 0.0f;
    } else {
        _sectionClusteringFactor = sectionClusteringFactor;
    }
}

#pragma mark - Private

/**
 *  Determine the center of an item, which falls on the circle of the overall layout.
 *  
 *  Sections' items will be slightly contracted towards their section's center, leaving
 *  sections appearing clustered. The degree to which they are clustered depends on the
 *  value of @c self.groupClusteringFactor, which is multiplied by the amount of radians between
 *  each item on the layout circle if they were spaced evenly, producing the unit amount of radians
 *  to adjust the item's position on the layout circle for section contraction. This unit
 *  amount is then multiplied by the index distance of the current item from the center of the
 *  section (# items / 2--as in x.5 for sections with an odd number of items and x.0 for even).
 *
 *  @param indexPath indexPath of the item to place on the circle.
 *
 *  @return A CGPoint representing the center of the item.
 */
- (CGPoint)centerForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger itemsInThisSection = [self.collectionView numberOfItemsInSection:indexPath.section];
    
    CGFloat distanceToCenter;
    if (itemsInThisSection <= 1) {
        distanceToCenter = 0.0f;
    } else if (itemsInThisSection == 2) {
        distanceToCenter = 0.5f * (indexPath.row == 0 ? 1.0f : -1.0f);
    } else {
        distanceToCenter = (itemsInThisSection - 1) / 2.0f - indexPath.row;
    }
    
    NSUInteger absoluteItemIndex = 0;
    for (NSUInteger section = 0; section < indexPath.section; section++) {
        absoluteItemIndex += [self.collectionView numberOfItemsInSection:section];
    }
    absoluteItemIndex += indexPath.row;
    
    CGFloat equallyDividedRadiansPerItem = 2.0f * M_PI / self.cellCount;
    CGFloat radianAdjustmentPerSectionItem = equallyDividedRadiansPerItem * self.sectionClusteringFactor;
    CGFloat adjustmentRadians = distanceToCenter * radianAdjustmentPerSectionItem;
    CGFloat finalRadians = absoluteItemIndex * equallyDividedRadiansPerItem + adjustmentRadians;
    
    CGPoint center = CGPointMake(self.layoutCenter.x - self.layoutRadius * cosf(finalRadians),
                                 self.layoutCenter.y - self.layoutRadius * sinf(finalRadians));
    return center;
}

@end