//
//  KRHTextView.m
//  KongroNews
//
//  Created by Kent Robin Haugen on 01.04.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import "KRHTextView.h"
#import "Constants.h"

@implementation KRHTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setFont:[UIFont fontWithName:BUTTON_FONT_TYPE size:14.0f]];
        [self setEditable:NO];
        [self addLongPressGestureRecognizer];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)addLongPressGestureRecognizer
{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    longPress.delegate = self;
    longPress.numberOfTouchesRequired = 1;
    longPress.minimumPressDuration = 0.5f;
    [self addGestureRecognizer:longPress];
    
}

- (IBAction)longPressAction:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KRHTextViewLongPressActionTriggered" object:self];
    }
}

- (void)dealloc
{
}

- (BOOL)canBecomeFirstResponder {
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
@end
