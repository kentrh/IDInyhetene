//
//  SingleArticleViewController.m
//  KongroNews
//
//  Created by Kent Robin Haugen on 27.03.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import "SingleArticleViewController.h"
#import "Colors.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Constants.h"
#import "MapViewController.h"
#import "NSDate+TimeSince.h"

@interface SingleArticleViewController ()

@end

@implementation SingleArticleViewController

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
    [self setUpUI];
    [self setUpScrollView];
    [self addDoubleTapGestureRecognizer];
    
    NSLog(@"number of locations: %d", _newsArticle.locations.count);
}

- (void)viewDidAppear:(BOOL)animated
{

}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [self setBodyTextViewHeight];
//    [self setScrollViewContentSize];
//}

- (void)setUpScrollView
{
    
    [_rootScrollView setBackgroundColor:[UIColor whiteColor]];
    _rootScrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    _rootScrollView.clipsToBounds = NO;
    _rootScrollView.scrollEnabled = YES;
    _rootScrollView.pagingEnabled = YES;
    
}

- (void)setUpUI
{
    _titleLabel.text = _newsArticle.title;
    _leadTextLabel.text = _newsArticle.leadText;
    _bodyTextView.text = _newsArticle.bodyText;
    _publisherLabel.text = _newsArticle.publisher;
    _timeSinceLabel.text = [_newsArticle.published timeSinceFromDate];
    NSString *cats = @"";
    for (NSString *cat in _newsArticle.categories) {
        cats  = [cats stringByAppendingString:[NSString stringWithFormat:@"%@ ", cat]];
    }
    _categoryLabel.text = cats;
    
    if (_newsArticle.images.count > 0) {
        [_imageView setImageWithURL:[_newsArticle.images objectAtIndex:0]];
        //        [_imageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:_newsArticle.imageUrl]]];
        UIView *filterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _imageView.frame.size.width, _imageView.frame.size.height)];
        [filterView setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f]];
        [_imageView addSubview:filterView];
    }
    else {
        int random = arc4random() % NUMBER_OF_GRADIENTS;
        CAGradientLayer *gradient;
        switch (random) {
            case 0:
                gradient = [Colors redGradientWithFrame:_imageView.frame];
                break;
            case 1:
                gradient = [Colors greenGradientWithFrame:_imageView.frame];
                break;
            case 2:
                gradient = [Colors blueGradientWithFrame:_imageView.frame];
                break;
            case 3:
                gradient = [Colors purpleGradientWithFrame:_imageView.frame];
                break;
            case 4:
                gradient = [Colors purpleGreenGradientWithFrame:_imageView.frame];
                break;
            default:
                gradient = [Colors blueGradientWithFrame:_imageView.frame];
                break;
        }
        UIImage *placeholderImage = [[UIImage alloc] init];
        [_imageView setImage:placeholderImage];
        [_imageView.layer insertSublayer:gradient atIndex:0];
        UIView *filterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _imageView.frame.size.width, _imageView.frame.size.height)];
        [filterView setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f]];
        [_imageView addSubview:filterView];
        
    }
}

- (void)setBodyTextViewHeight
{
    CGRect frame = _bodyTextView.frame;
    frame.size.height = _bodyTextView.contentSize.height;
    _bodyTextView.frame = frame;
}

- (void)setScrollViewContentSize
{
    CGSize contentSize = CGSizeMake(_rootScrollView.contentSize.width, _bodyTextView.frame.origin.y + _bodyTextView.frame.size.height);
    [_rootScrollView setContentSize:contentSize];
}

- (void)addDoubleTapGestureRecognizer
{
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    doubleTap.delegate = self;
    [self.view addGestureRecognizer:doubleTap];
}

- (IBAction)doubleTapAction:(id)sender
{
    if (_newsArticle.locations.count > 0) {
        [self showMapView];
    }
}

- (void)showMapView
{
    MapViewController *mapViewController = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    [mapViewController setNewsArticle:_newsArticle];
    [self presentViewController:mapViewController animated:YES completion:nil];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
