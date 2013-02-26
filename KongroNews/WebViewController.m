//
//  WebViewController.m
//  KongroNews
//
//  Created by Kent Robin Haugen on 24.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

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
    [self setWantsFullScreenLayout:YES];
}

- (void)setUpWebView
{
    _webView.delegate = self;
    [_webView loadRequest:[NSURLRequest requestWithURL:_news.link]];
}

- (void)setUpNavToolbar
{
    // Toolbar
    [_navToolbar setBackgroundImage:[UIImage imageNamed:@"navBarImage"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [_navToolbar setAlpha:0.8f];
    
    // Toolbar Items
    UIImage *prevImage = [[UIImage imageNamed:@"backButtonS"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIButton *prevBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [prevBut setFrame:CGRectMake(0, 0, prevImage.size.width, prevImage.size.height)];
    [prevBut setImage:prevImage forState:UIControlStateNormal];
    [prevBut addTarget:self action:@selector(gotoPreviousPage) forControlEvents:UIControlEventTouchUpInside];
    prevBut.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    UIBarButtonItem *previousButton = [[UIBarButtonItem alloc] initWithCustomView:prevBut];
    
    UIBarButtonItem *spacing = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIImage *nextImage = [[UIImage imageNamed:@"forwardButtonS"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIButton *nextBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextBut setFrame:CGRectMake(0, 0, nextImage.size.width, nextImage.size.height)];
    [nextBut setImage:nextImage forState:UIControlStateNormal];
    [nextBut addTarget:self action:@selector(gotoNextPage) forControlEvents:UIControlEventTouchUpInside];
    nextBut.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithCustomView:nextBut];
    
    UIImage *closeImage = [[UIImage imageNamed:@"shareButtonS"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIButton *closeBut = [UIButton buttonWithType:UIButtonTypeCustom];
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
    CGRect rect = self.view.frame;
    [self.view setFrame:CGRectMake(rect.origin.x, -(rect.size.height), rect.size.width, rect.size.height)];
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame = rect;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
