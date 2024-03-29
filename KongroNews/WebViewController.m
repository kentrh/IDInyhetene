//
//  WebViewController.m
//  KongroNews
//
//  Created by Kent Robin Haugen on 24.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import "WebViewController.h"
#import "SKBounceAnimation.h"
#import "Constants.h"
#import "RootViewController.h"
#import "Colors.h"

@interface WebViewController (){
    UIButton *nextBut;
    UIButton *prevBut;
    UIButton *closeBut;
    float reverseDegree;
    BOOL isPlayingVideo;
    BOOL hasAd;
}

@end

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUpWebView];
    [self setUpNavToolbar];
}

- (void)setUpWebView
{
    _webView.delegate = self;
    [_webView setScalesPageToFit:YES];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_news.sourceUrl];
    [request setValue:[NSString stringWithFormat:@"%@ Safari/528.16", [request valueForHTTPHeaderField:@"User-Agent"]] forHTTPHeaderField:@"User_Agent"];
    [_webView loadRequest:request];
}

- (void)setUpNavToolbar
{
    // Toolbar
    [_navToolbar setBackgroundImage:[UIImage imageNamed:@"navBarImage"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    // Toolbar Items
    UIImage *prevImage = [[UIImage imageNamed:@"backButtonS"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    prevBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [prevBut setFrame:CGRectMake(0, 0, prevImage.size.width, prevImage.size.height)];
    [prevBut setImage:prevImage forState:UIControlStateNormal];
    [prevBut addTarget:self action:@selector(gotoPreviousPage) forControlEvents:UIControlEventTouchUpInside];
    prevBut.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    prevBut.enabled = NO;
    UIBarButtonItem *previousButton = [[UIBarButtonItem alloc] initWithCustomView:prevBut];
    
    UIBarButtonItem *spacing = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIImage *nextImage = [[UIImage imageNamed:@"forwardButtonS"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    nextBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextBut setFrame:CGRectMake(0, 0, nextImage.size.width, nextImage.size.height)];
    [nextBut setImage:nextImage forState:UIControlStateNormal];
    [nextBut addTarget:self action:@selector(gotoNextPage) forControlEvents:UIControlEventTouchUpInside];
    nextBut.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    nextBut.enabled = NO;
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithCustomView:nextBut];
    
    UIImage *closeImage = [[UIImage imageNamed:@"shareButtonS"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    closeBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBut setFrame:CGRectMake(0, 0, closeImage.size.width, closeImage.size.height)];
    [closeBut setImage:closeImage forState:UIControlStateNormal];
    [closeBut addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    closeBut.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithCustomView:closeBut];
    
    [_navToolbar setItems:[NSArray arrayWithObjects:previousButton, nextButton, spacing, closeButton, nil]];
}

- (void)gotoPreviousPage
{
    [_webView goBack];
}

- (void)gotoNextPage
{
    [_webView goForward];
}

- (void)closeButtonPressed
{
    CGRect rect = self.view.frame;
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setFrame:CGRectMake(rect.origin.x, -(rect.size.height), rect.size.width, rect.size.height)];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self setStartPositionForAnimation];
    [self startBounceInAnimation];
}

- (void)startBounceInAnimation
{
    NSString *keyPath = @"position.y";
    CGRect frame = [[UIScreen mainScreen] bounds];
    CGPoint center = CGPointMake(frame.size.width/2, frame.size.height/2);
    id finalValue = [NSNumber numberWithFloat:center.y];
    
    SKBounceAnimation *bounceAnimation = [SKBounceAnimation animationWithKeyPath:keyPath];
    bounceAnimation.fromValue = [NSNumber numberWithFloat:self.view.center.y];
    bounceAnimation.toValue = finalValue;
    bounceAnimation.duration = ANIMATION_DURATION;
    bounceAnimation.numberOfBounces = ANIMATION_NUMBER_OF_BOUNCES;
    bounceAnimation.shouldOvershoot = ANIMATION_SHOULD_OVERSHOOT;
    
    [self.view.layer addAnimation:bounceAnimation forKey:@"someKey"];
    [self.view.layer setValue:finalValue forKeyPath:keyPath];
}

- (void)setStartPositionForAnimation
{
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.origin.y = -(frame.size.height);
    frame.origin.x = self.view.frame.origin.x;
    self.view.frame = frame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
//    return isPlayingVideo ? UIInterfaceOrientationMaskAllButUpsideDown : UIInterfaceOrientationMaskPortrait;
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark - UIWebViewDelegate Methods

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    prevBut.enabled = _webView.canGoBack ? YES : NO;
    nextBut.enabled = _webView.canGoForward ? YES : NO;
//    NSString* js =
//    @"var meta = document.createElement('meta'); " \
//    "meta.setAttribute( 'name', 'viewport' ); " \
//    "meta.setAttribute( 'content', 'width = device-width, initial-scale = 5.0, user-scalable = yes' ); " \
//    "document.getElementsByTagName('head')[0].appendChild(meta)";
//    
//    [webView stringByEvaluatingJavaScriptFromString: js];
    [SVProgressHUD dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [SVProgressHUD dismiss];
}
@end
