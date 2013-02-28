//
//  Colors.h
//  KongroNews
//
//  Created by Kent Robin Haugen on 21.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface Colors : NSObject

+ (CAGradientLayer *)blueGradientWithFrame:(CGRect) rect;
+ (CAGradientLayer *)redGradientWithFrame:(CGRect) rect;
+ (CAGradientLayer *)greenGradientWithFrame:(CGRect) rect;

+ (UIColor *)lightBlue;
+ (UIColor *)orange;
+ (UIColor *)green;

@end
