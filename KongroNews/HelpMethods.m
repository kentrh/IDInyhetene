//
//  HelpMethods.m
//  KongroNews
//
//  Created by Kent Robin Haugen on 27.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import "HelpMethods.h"
#import "Constants.h"

@implementation HelpMethods

+ (NSString *)randomLoadText
{
    NSArray *randomTexts = [NSArray arrayWithObjects:
                            @"To sek bare",
                            @"Snart der..",
                            @"Sjill to, k?",
                            @"I'm loading",
                            @"Please hold",
                            @"Laddar",
                            @"Hold an",
                            @"Very soon",
                            @"Incoming data",
                            @"Shh, hør..",
                            @"Venta lite",
                            @"Incoming",
                            @"Chewing bytes",
                            @"Bitrain",
                            @"Et lite blikk",
                            nil];
    
    int index = arc4random() % [randomTexts count];
    return [randomTexts objectAtIndex:index];
}


+ (UIButton *)buttonWithTitle:(NSString *)titleText color:(UIColor *)color
{
    float buttonWidth = [[UIScreen mainScreen] bounds].size.width - 40.0f;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = color;
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, buttonWidth-40, 20)];
    title.text = titleText;
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont fontWithName:BUTTON_FONT_TYPE size:BUTTON_FONT_SIZE];
    title.textAlignment = NSTextAlignmentLeft;
    title.backgroundColor = [UIColor clearColor];
    [button addSubview:title];
    
    return button;
}
@end
