//
//  Colors.m
//  KongroNews
//
//  Created by Kent Robin Haugen on 21.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import "Colors.h"

@implementation Colors

#pragma mark - Gradients

+ (CAGradientLayer *)blueGradientWithFrame:(CGRect) rect
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = rect;
    gradient.colors = [NSArray arrayWithObjects:(id)[[Colors topBlue]CGColor], (id)[[Colors bottomBlue] CGColor], nil];
    gradient.startPoint = CGPointMake(0.0f, 0.0f);
    gradient.endPoint = CGPointMake(1.0f, 1.0f);
    
    return gradient;
}

+ (CAGradientLayer *)redGradientWithFrame:(CGRect) rect
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = rect;
    gradient.colors = [NSArray arrayWithObjects:(id)[[Colors topRed]CGColor], (id)[[Colors bottomRed] CGColor], nil];
    gradient.startPoint = CGPointMake(0.0f, 0.0f);
    gradient.endPoint = CGPointMake(1.0f, 1.0f);
    
    return gradient;
}

+ (CAGradientLayer *)greenGradientWithFrame:(CGRect) rect
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = rect;
    gradient.colors = [NSArray arrayWithObjects:(id)[[Colors topGreen]CGColor], (id)[[Colors bottomGreen] CGColor], nil];
    gradient.startPoint = CGPointMake(0.0f, 0.0f);
    gradient.endPoint = CGPointMake(1.0f, 1.0f);
    
    return gradient;
}

+ (CAGradientLayer *)purpleGradientWithFrame:(CGRect) rect
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = rect;
    gradient.colors = [NSArray arrayWithObjects:(id)[[Colors topPurple]CGColor], (id)[[Colors bottomPurple] CGColor], nil];
    gradient.startPoint = CGPointMake(0.0f, 0.0f);
    gradient.endPoint = CGPointMake(1.0f, 1.0f);
    
    return gradient;
}

+ (CAGradientLayer *)purpleGreenGradientWithFrame:(CGRect) rect
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = rect;
    gradient.colors = [NSArray arrayWithObjects:(id)[[Colors topPurpleGreen]CGColor], (id)[[Colors bottomPurpleGreen] CGColor], nil];
    gradient.startPoint = CGPointMake(0.0f, 0.0f);
    gradient.endPoint = CGPointMake(1.0f, 1.0f);
    
    return gradient;
}

#pragma mark - GradientColors

+ (UIColor *)bottomGreen
{
    return [UIColor colorWithRed:0.0f/255.0f green:153.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
}

+ (UIColor *)topGreen
{
    return [UIColor colorWithRed:0.0f/255.0f green:255.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
}

+ (UIColor *)bottomBlue
{
    return [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
}

+ (UIColor *)topBlue
{
    return [UIColor colorWithRed:255.0f/255.0f green:0.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
}

+ (UIColor *)bottomRed
{
    return [UIColor colorWithRed:204.0f/255.0f green:0.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
}

+ (UIColor *)topRed
{
    return [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
}

+ (UIColor *)bottomPurple
{
    return [UIColor colorWithRed:51.0f/255.0f green:0.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
}

+ (UIColor *)topPurple
{
    return [UIColor colorWithRed:51.0f/255.0f green:153.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
}

+ (UIColor *)bottomPurpleGreen
{
    return [UIColor colorWithRed:51.0f/255.0f green:0.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
}

+ (UIColor *)topPurpleGreen
{
    return [UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
}
#pragma mark - CategoryButtonColors

+ (UIColor *)lightBlue
{
    return [UIColor colorWithRed:0.0f/255.0f green:153.0f/255.0f blue:255.0f/255.0f alpha:0.5f];
}

+ (UIColor *)orange
{
    return [UIColor colorWithRed:255.0f/255.0f green:102.0f/255.0f blue:0.0f/255.0f alpha:0.5f];
}

+ (UIColor *)green
{
    return [UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:51.0f/255.0f alpha:0.5f];
}

+ (UIColor *)facebook
{
    return [UIColor colorWithRed:60.0f/255.0f green:90.0f/255.0f blue:152.0f/255.0f alpha:0.5f];
}

+ (UIColor *)twitter
{
    return [UIColor colorWithRed:49.0f/255.0f green:170.0f/255.0f blue:225.0f/255.0f alpha:0.5f];
}

+ (UIColor *)rate
{
    return [UIColor colorWithRed:157.0f/255.0f green:74.0f/255.0f blue:178.0f/255.0f alpha:0.5f];
}

+ (UIColor *)feedback
{
    return [UIColor colorWithRed:118.0f/255.0f green:18.0f/255.0f blue:144.0f/255.0f alpha:0.5f];
}
@end
