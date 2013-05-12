//
// UIScrollView+SVPullToRefresh.m
//
// Created by Sam Vermette on 23.04.12.
// Copyright (c) 2012 samvermette.com. All rights reserved.
//
// https://github.com/samvermette/SVPullToRefresh
//

#import <QuartzCore/QuartzCore.h>
#import "UIScrollView+SVPullToRefresh.h"

//fequalzro() from http://stackoverflow.com/a/1614761/184130
#define fequalzero(a) (fabs(a) < FLT_EPSILON)

static CGFloat const SVPullToRefreshViewHeight = 60;
static CGFloat const SVPullToRefreshViewWidth = 60;

@interface SVPullToRefreshArrow : UIView

@property (nonatomic, strong) UIColor *arrowColor;

@end


@interface SVPullToRefreshView ()

@property (nonatomic, copy) void (^pullToRefreshActionHandler)(void);

@property (nonatomic, strong) SVPullToRefreshArrow *arrow;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, readwrite) SVPullToRefreshState state;

@property (nonatomic, strong) NSMutableArray *viewForState;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, readwrite) CGFloat originalLeftInset;

@property (nonatomic, assign) BOOL wasTriggeredByUser;
@property (nonatomic, assign) BOOL showsPullToRefresh;
@property(nonatomic, assign) BOOL isObserving;

- (void)resetScrollViewContentInset;
- (void)setScrollViewContentInsetForLoading;
- (void)setScrollViewContentInset:(UIEdgeInsets)insets;
- (void)rotateArrow:(float)degrees hide:(BOOL)hide;

@end



#pragma mark - UIScrollView (SVPullToRefresh)
#import <objc/runtime.h>

static char UIScrollViewPullToRefreshView;

@implementation UIScrollView (SVPullToRefresh)

@dynamic pullToRefreshView, showsPullToRefresh;

- (void)addPullToRefreshWithActionHandler:(void (^)(void))actionHandler {
    
    if(!self.pullToRefreshView) {
        SVPullToRefreshView *view = [[SVPullToRefreshView alloc] initWithFrame:CGRectMake(-SVPullToRefreshViewWidth, 0, SVPullToRefreshViewWidth, self.bounds.size.height)];
        view.pullToRefreshActionHandler = actionHandler;
        view.scrollView = self;
        [self addSubview:view];
        
        view.originalLeftInset = self.contentInset.left;
        self.pullToRefreshView = view;
        self.showsPullToRefresh = YES;
    }
}

- (void)triggerPullToRefresh {
    self.pullToRefreshView.state = SVPullToRefreshStateTriggered;
    [self.pullToRefreshView startAnimating];
}

- (void)setPullToRefreshView:(SVPullToRefreshView *)pullToRefreshView {
    [self willChangeValueForKey:@"SVPullToRefreshView"];
    objc_setAssociatedObject(self, &UIScrollViewPullToRefreshView,
                             pullToRefreshView,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"SVPullToRefreshView"];
}

- (SVPullToRefreshView *)pullToRefreshView {
    return objc_getAssociatedObject(self, &UIScrollViewPullToRefreshView);
}

- (void)setShowsPullToRefresh:(BOOL)showsPullToRefresh {
    self.pullToRefreshView.hidden = !showsPullToRefresh;
    
    if(!showsPullToRefresh) {
      if (self.pullToRefreshView.isObserving) {
        [self removeObserver:self.pullToRefreshView forKeyPath:@"contentOffset"];
        [self removeObserver:self.pullToRefreshView forKeyPath:@"frame"];
        [self.pullToRefreshView resetScrollViewContentInset];
        self.pullToRefreshView.isObserving = NO;
      }
    }
    else {
      if (!self.pullToRefreshView.isObserving) {
        [self addObserver:self.pullToRefreshView forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self.pullToRefreshView forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        self.pullToRefreshView.isObserving = YES;
      }
    }
}

- (BOOL)showsPullToRefresh {
    return !self.pullToRefreshView.hidden;
}

@end

#pragma mark - SVPullToRefresh
@implementation SVPullToRefreshView

// public properties
@synthesize pullToRefreshActionHandler, arrowColor, activityIndicatorViewStyle;

@synthesize state = _state;
@synthesize scrollView = _scrollView;
@synthesize showsPullToRefresh = _showsPullToRefresh;
@synthesize arrow = _arrow;
@synthesize activityIndicatorView = _activityIndicatorView;


- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        
        // default styling values
        self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.state = SVPullToRefreshStateStopped;
        self.viewForState = [NSMutableArray arrayWithObjects:@"", @"", @"", @"", nil];
    }

    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview { 
    if (self.superview && newSuperview == nil) {
        //use self.superview, not self.scrollView. Why self.scrollView == nil here?
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        if (scrollView.showsPullToRefresh) {
          if (self.isObserving) {
            //If enter this branch, it is the moment just before "SVPullToRefreshView's dealloc", so remove observer here
            [scrollView removeObserver:self forKeyPath:@"contentOffset"];
            [scrollView removeObserver:self forKeyPath:@"frame"];
            self.isObserving = NO;
          }
        }
    }
}

- (void)layoutSubviews {
    
    self.activityIndicatorView.center = self.arrow.center;
    
    for(id otherView in self.viewForState) {
        if([otherView isKindOfClass:[UIView class]])
            [otherView removeFromSuperview];
    }
    
    id customView = [self.viewForState objectAtIndex:self.state];
    BOOL hasCustomView = [customView isKindOfClass:[UIView class]];
    
    float angle = -M_PI_2;  //rotate 180°, or 1 π radians
    
    self.arrow.hidden = hasCustomView;
    
    if(hasCustomView) {
        [self addSubview:customView];
        CGRect viewBounds = [customView bounds];
        CGPoint origin = CGPointMake(roundf((self.bounds.size.width-viewBounds.size.width)/2), roundf((self.bounds.size.height-viewBounds.size.height)/2));
        [customView setFrame:CGRectMake(origin.x, origin.y, viewBounds.size.width, viewBounds.size.height)];
    }
    else {
        switch (self.state) {
            case SVPullToRefreshStateStopped:
                self.arrow.alpha = 1;
                [self.activityIndicatorView stopAnimating];
                [self rotateArrow:(float)angle hide:NO];
                break;
                
            case SVPullToRefreshStateTriggered:
                [self rotateArrow:(float)M_PI_2 hide:NO];
                break;
                
            case SVPullToRefreshStateLoading:
                [self.activityIndicatorView startAnimating];
                [self rotateArrow:(float)angle hide:YES];
                break;
        }
    }
    
    CGFloat pos = self.bounds.size.height/2 - self.arrow.frame.size.height/2;
    CGRect arrowFrame = self.arrow.frame;
    arrowFrame.origin.y = pos;
    arrowFrame.origin.x = 0;
    self.arrow.frame = arrowFrame;


}

#pragma mark - Scroll View

- (void)resetScrollViewContentInset {
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.left = self.originalLeftInset+1;
    [self setScrollViewContentInsetToOrigin:currentInsets];
}

- (void)setScrollViewContentInsetToOrigin:(UIEdgeInsets)contentInset {
    [UIView animateWithDuration:0.3 animations:^{
            self.scrollView.contentInset = contentInset;
    } completion:^(BOOL finished) {
        UIEdgeInsets insets = contentInset;
        insets.left = self.originalLeftInset;
        self.scrollView.contentInset = insets;
    }];
}

- (void)setScrollViewContentInsetForLoading {
    CGFloat offset = MAX(self.scrollView.contentOffset.x * -1, 0);
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.left = MIN(offset, self.originalLeftInset + self.bounds.size.width);
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset {
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                        self.scrollView.contentInset = contentInset;
                     }
                     completion:nil];
}

#pragma mark - Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {    
    if([keyPath isEqualToString:@"contentOffset"])
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    else if([keyPath isEqualToString:@"frame"])
        [self layoutSubviews];
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset {
    if(self.state != SVPullToRefreshStateLoading) {
        CGFloat scrollOffsetThreshold = self.frame.origin.x-self.originalLeftInset;
        
        if(!self.scrollView.isDragging && self.state == SVPullToRefreshStateTriggered)
            self.state = SVPullToRefreshStateLoading;
        else if(contentOffset.x < scrollOffsetThreshold && self.scrollView.isDragging && self.state == SVPullToRefreshStateStopped)
            self.state = SVPullToRefreshStateTriggered;
        else if(contentOffset.x >= scrollOffsetThreshold && self.state != SVPullToRefreshStateStopped)
            self.state = SVPullToRefreshStateStopped;
    } else {
        CGFloat offset = MAX(self.scrollView.contentOffset.x * -1, 0.0f);
        offset = MIN(offset, self.originalLeftInset + self.bounds.size.width);
        UIEdgeInsets contentInset = self.scrollView.contentInset;
        self.scrollView.contentInset = UIEdgeInsetsMake(contentInset.top, offset, contentInset.bottom, contentInset.right);
    }
}

#pragma mark - Getters

- (SVPullToRefreshArrow *)arrow {
    if(!_arrow) {
		_arrow = [[SVPullToRefreshArrow alloc]initWithFrame:CGRectMake(0, self.bounds.size.height-54, 22, 48)];
        _arrow.backgroundColor = [UIColor clearColor];
		[self addSubview:_arrow];
    }
    return _arrow;
}

- (UIActivityIndicatorView *)activityIndicatorView {
    if(!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityIndicatorView.hidesWhenStopped = YES;
        [self addSubview:_activityIndicatorView];
    }
    return _activityIndicatorView;
}

- (UIColor *)arrowColor {
	return self.arrow.arrowColor; // pass through
}

- (UIActivityIndicatorViewStyle)activityIndicatorViewStyle {
    return self.activityIndicatorView.activityIndicatorViewStyle;
}

#pragma mark - Setters

- (void)setArrowColor:(UIColor *)newArrowColor {
	self.arrow.arrowColor = newArrowColor; // pass through
	[self.arrow setNeedsDisplay];
}

- (void)setCustomView:(UIView *)view forState:(SVPullToRefreshState)state {
    id viewPlaceholder = view;
    
    if(!viewPlaceholder)
        viewPlaceholder = @"";
    
    if(state == SVPullToRefreshStateAll)
        [self.viewForState replaceObjectsInRange:NSMakeRange(0, 3) withObjectsFromArray:@[viewPlaceholder, viewPlaceholder, viewPlaceholder]];
    else
        [self.viewForState replaceObjectAtIndex:state withObject:viewPlaceholder];
    
    [self setNeedsLayout];
}

- (void)setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)viewStyle {
    self.activityIndicatorView.activityIndicatorViewStyle = viewStyle;
}


#pragma mark -

- (void)triggerRefresh {
    [self.scrollView triggerPullToRefresh];
}

- (void)startAnimating{
    if(fequalzero(self.scrollView.contentOffset.x)) {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -self.frame.size.width) animated:YES];
        self.wasTriggeredByUser = NO;
    }
    else
        self.wasTriggeredByUser = YES;
    
    self.state = SVPullToRefreshStateLoading;
}

- (void)stopAnimating {
    self.state = SVPullToRefreshStateStopped;
    
    if(!self.wasTriggeredByUser && self.scrollView.contentOffset.x < -self.originalLeftInset)
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -self.originalLeftInset) animated:YES];
}

- (void)setState:(SVPullToRefreshState)newState {
    
    if(_state == newState)
        return;
    
    SVPullToRefreshState previousState = _state;
    _state = newState;
    
    [self setNeedsLayout];
    
    switch (newState) {
        case SVPullToRefreshStateStopped:
            [self resetScrollViewContentInset];
            break;
            
        case SVPullToRefreshStateTriggered:
            break;
            
        case SVPullToRefreshStateLoading:
            [self setScrollViewContentInsetForLoading];
            
            if(previousState == SVPullToRefreshStateTriggered && pullToRefreshActionHandler)
                pullToRefreshActionHandler();
            
            break;
    }
}

- (void)rotateArrow:(float)degrees hide:(BOOL)hide {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.arrow.layer.transform = CATransform3DMakeRotation(degrees, 0, 0, 1);
        self.arrow.layer.opacity = !hide;
        //[self.arrow setNeedsDisplay];//ios 4
    } completion:NULL];
}

@end


#pragma mark - SVPullToRefreshArrow

@implementation SVPullToRefreshArrow
@synthesize arrowColor;

- (UIColor *)arrowColor {
	if (arrowColor) return arrowColor;
	return [UIColor grayColor]; // default Color
}

- (void)drawRect:(CGRect)rect {
	CGContextRef c = UIGraphicsGetCurrentContext();
	
	// the rects above the arrow
	CGContextAddRect(c, CGRectMake(5, 0, 12, 4)); // to-do: use dynamic points
	CGContextAddRect(c, CGRectMake(5, 6, 12, 4)); // currently fixed size: 22 x 48pt
	CGContextAddRect(c, CGRectMake(5, 12, 12, 4));
	CGContextAddRect(c, CGRectMake(5, 18, 12, 4));
	CGContextAddRect(c, CGRectMake(5, 24, 12, 4));
	CGContextAddRect(c, CGRectMake(5, 30, 12, 4));
	
	// the arrow
	CGContextMoveToPoint(c, 0, 34);
	CGContextAddLineToPoint(c, 11, 48);
	CGContextAddLineToPoint(c, 22, 34);
	CGContextAddLineToPoint(c, 0, 34);
	CGContextClosePath(c);
	
	CGContextSaveGState(c);
	CGContextClip(c);
	
	// Gradient Declaration
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGFloat alphaGradientLocations[] = {0, 0.8f};
    
	CGGradientRef alphaGradient = nil;
    if([[[UIDevice currentDevice] systemVersion]floatValue] >= 5){
        NSArray* alphaGradientColors = [NSArray arrayWithObjects:
                                        (id)[self.arrowColor colorWithAlphaComponent:0].CGColor,
                                        (id)[self.arrowColor colorWithAlphaComponent:1].CGColor,
                                        nil];
        alphaGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)alphaGradientColors, alphaGradientLocations);
    }else{
        const CGFloat * components = CGColorGetComponents([self.arrowColor CGColor]);
        int numComponents = (int)CGColorGetNumberOfComponents([self.arrowColor CGColor]);
        CGFloat colors[8];
        switch(numComponents){
            case 2:{
                colors[0] = colors[4] = components[0];
                colors[1] = colors[5] = components[0];
                colors[2] = colors[6] = components[0];
                break;
            }
            case 4:{
                colors[0] = colors[4] = components[0];
                colors[1] = colors[5] = components[1];
                colors[2] = colors[6] = components[2];
                break;
            }
        }
        colors[3] = 0;
        colors[7] = 1;
        alphaGradient = CGGradientCreateWithColorComponents(colorSpace,colors,alphaGradientLocations,2);
    }
	
	
	CGContextDrawLinearGradient(c, alphaGradient, CGPointZero, CGPointMake(0, rect.size.height), 0);
    
	CGContextRestoreGState(c);
	
	CGGradientRelease(alphaGradient);
	CGColorSpaceRelease(colorSpace);
    
}
@end
