//
//  UIView+PCAutolayoutConstraintExtensions.m
//  PCAutolayout
//
//  Created by Patrick Perini on 8/2/13.
//  Copyright (c) 2013 pcperini. All rights reserved.
//

#import "UIView+PCAutolayoutConstraintExtensions.h"
#import "NSLayoutConstraint+PCAutolayoutIdentifierExtensions.h"

@interface UIView (PCAutolayoutConstraintPrivateExtensions)

#pragma mark - Accessors
/*!
 *  Returns the primary layout constraint for the given layout attributes.
 *  @param attributes A pointer to a list of NSLayoutAttributes.
 *  @param count The number of NSLayoutAttributes in the given list.
 *  @result The primary layout constraint for the given layout attributes.
 *  @discussion The constraint might be applied to the view's superview.
 */
- (NSLayoutConstraint *)layoutConstraintForLayoutAttributes:(NSLayoutAttribute *)attributes count:(NSInteger)count;

@end

@implementation UIView (PCAutolayoutConstraintExtensions)

#pragma mark - Accessors
- (NSLayoutConstraint *)layoutConstraintForLayoutAttributes:(NSLayoutAttribute *)attributes count:(NSInteger)count
{
    NSMutableArray *constraints = [[self constraints] mutableCopy];
    [constraints addObjectsFromArray: [[self superview] constraints]];
    
    NSInteger highestConstraintPriority = FLT_MIN;
    NSLayoutConstraint *bestFittingConstraint = nil;
    for (NSLayoutConstraint *constraint in constraints)
    {
        NSLayoutAttribute layoutAttribute;
        if ([constraint firstItem] == self)
        {
            layoutAttribute = [constraint firstAttribute];
        }
        else if ([constraint secondItem] == self)
        {
            layoutAttribute = [constraint secondAttribute];
        }
        else // Constraint is not relevant
        {
            continue;
        }
        
        for (NSInteger attributeIndex = 0; attributeIndex < count; attributeIndex++)
        {
            NSLayoutConstraint *likelyBestFittingConstraint = nil;
            NSLayoutAttribute attribute = attributes[attributeIndex];
            if ((layoutAttribute == attribute) && ([constraint priority] > highestConstraintPriority))
            {
                likelyBestFittingConstraint = constraint;
            }
            
            if (!likelyBestFittingConstraint)
                continue;
            
            BOOL constraintItemIsSingleton = (![constraint firstItem] != ![constraint secondItem]); // firstItem xor secondItem
            BOOL bestFittingConstraintItemIsSingleton = (![bestFittingConstraint firstItem] != ![bestFittingConstraint secondItem]); // firstItem xor secondItem
            
            if (bestFittingConstraintItemIsSingleton && !constraintItemIsSingleton) // Prefer when items are singletons
                continue;
            
            bestFittingConstraint = likelyBestFittingConstraint;
            highestConstraintPriority = [constraint priority];
        }
    }
    
    return bestFittingConstraint;
}

- (NSLayoutConstraint *)horizontalOriginConstraint
{
    NSLayoutAttribute layoutAttributes[3] = {NSLayoutAttributeLeading, NSLayoutAttributeTrailing, NSLayoutAttributeCenterX};
    return [self layoutConstraintForLayoutAttributes: layoutAttributes
                                               count: 3];
}

- (NSLayoutConstraint *)verticalOriginConstraint
{
    NSLayoutAttribute layoutAttributes[3] = {NSLayoutAttributeTop, NSLayoutAttributeBottom, NSLayoutAttributeCenterY};
    return [self layoutConstraintForLayoutAttributes: layoutAttributes
                                               count: 3];
}

- (NSLayoutConstraint *)widthConstraint
{
    NSLayoutAttribute layoutAttributes[1] = {NSLayoutAttributeWidth};
    return [self layoutConstraintForLayoutAttributes: layoutAttributes
                                               count: 1];
}

- (NSLayoutConstraint *)heightConstraint
{
    NSLayoutAttribute layoutAttributes[1] = {NSLayoutAttributeHeight};
    return [self layoutConstraintForLayoutAttributes: layoutAttributes
                                               count: 1];
}

#pragma mark - Accessors
- (NSLayoutConstraint *)constraintWithIdentifier:(NSString *)identifier
{
    for (NSLayoutConstraint *constraint in [self constraints])
    {
        if ([[constraint identifier] isEqualToString: identifier])
            return constraint;
    }
    
    return nil;
}

#pragma mark - Mutators
- (void)addConstraint:(NSLayoutConstraint *)constraint withIdentifier:(NSString *)identifier
{
    [constraint setIdentifier: identifier];
    [self addConstraint: constraint];
}

@end
