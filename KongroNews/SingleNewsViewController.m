//
//  SingleNewsViewController.m
//  KongroNews
//
//  Created by Kent Robin Haugen on 23.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import "SingleNewsViewController.h"
#import "Colors.h"
#import "WebViewController.h"
#import "SKBounceAnimation.h"
#import "Constants.h"
#import "HelpMethods.h"

#define kIndexTwitter 0
#define kIndexFavorite 1
#define kIndexEmail 2
#define kIndexFaceBook 3

#define NUMBER_OF_GRADIENTS 3;

@interface SingleNewsViewController (){
    KLExpandingSelect *shareFlower;
    NSArray *selectorData;
}

@end

@implementation SingleNewsViewController

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
    [self setUpUi];
    [self addSwipeUpGestureRecognizer];
    [self initShareFlower];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (_shouldAnimate) {
        _parentScrollView.scrollEnabled = YES;
        [self setStartPositionForAnimation];
        [self startBounceInAnimation];
    }
}

- (void)setStartPositionForAnimation
{
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.origin.y = frame.size.height;
    frame.origin.x = self.view.frame.origin.x;
    self.view.frame = frame;
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

- (void)addSwipeUpGestureRecognizer
{
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeMade:)];
    [swipeGestureRecognizer setNumberOfTouchesRequired:1];
    [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:swipeGestureRecognizer];
}

- (void)swipeMade:(UISwipeGestureRecognizer*)swipeGesture
{
    if (swipeGesture.direction == UISwipeGestureRecognizerDirectionDown) {
        NSString *status = [HelpMethods randomLoadText];
        [SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeBlack];
        _shouldAnimate = YES;
        _parentScrollView.scrollEnabled = NO;
        CGRect rect = self.view.frame;
        [UIView animateWithDuration:0.3f animations:^{
            [self.view setFrame:CGRectMake(rect.origin.x, rect.size.height, rect.size.width, rect.size.height)];
        } completion:^(BOOL finished) {
            WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
            [webViewController setNews:_newsArticle];
            [self presentViewController:webViewController animated:NO completion:nil];
        }];
    }
}

- (void)setUpUi
{
    _titleLabel.text = _newsArticle.title;
    _textView.text = _newsArticle.leadText;
    if (_newsArticle.imageUrl) {
        NSData *imageData = [NSData dataWithContentsOfURL:_newsArticle.imageUrl];
        UIImage *image = [UIImage imageWithData:imageData];
        _imageView.image = image;
        UIView *filterView = [[UIView alloc] initWithFrame:_imageView.frame];
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
            default:
                gradient = [Colors blueGradientWithFrame:_imageView.frame];
                break;
        }
        UIImage *placeholderImage = [[UIImage alloc] init];
        [_imageView setImage:placeholderImage];
        [_imageView.layer insertSublayer:gradient atIndex:0];
        UIView *filterView = [[UIView alloc] initWithFrame:_imageView.frame];
        [filterView setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f]];
        [_imageView insertSubview:filterView belowSubview:_titleLabel];
    }
    
    NSTimeInterval timeDiff = [[NSDate date] timeIntervalSinceDate:_newsArticle.pubDate];
    int time = (int) timeDiff;
    int minutes = ((time / 60) % 60);
    int hours = (time / 3600);
    
    NSString *entallFlertallMinutter = minutes == 1 ? @"minutt" : @"minutter";
    NSString *entallFlertallTimer = hours == 1 ? @"time" : @"timer";
    
    NSString *timeSinceText;
    if (hours == 0) {
        timeSinceText = [NSString stringWithFormat:@"%d %@ siden", minutes, entallFlertallMinutter];
    }
    else if (hours == 1 || hours == 2) {
        timeSinceText = [NSString stringWithFormat:@"%d %@ og %d %@ siden", hours, entallFlertallTimer, minutes, entallFlertallMinutter];
    }
    else if (hours > 2) {
        timeSinceText = [NSString stringWithFormat:@"%d %@ siden", hours, entallFlertallTimer];
    }
    else if (hours > 23) {
        timeSinceText = [NSString stringWithFormat:@"Mer enn én dag siden"];
    }
    
    [_timeSinceLabel setText:timeSinceText];
    [_timeSinceLabel setFont:[UIFont fontWithName:@"AmericanTypewriter" size:14.0f]];
    [_timeSinceLabel sizeToFit];
}

- (void)initShareFlower
{
    //Initialize the table data
    NSString* plistPath = [[NSBundle mainBundle] pathForResource: @"Petal Data"
                                                          ofType: @"plist"];
    // Build the array from the plist
    selectorData = [[NSArray alloc] initWithContentsOfFile:plistPath];
    
    shareFlower = [[KLExpandingSelect alloc] initWithDelegate:self dataSource:self];
    [self.view setExpandingSelect:shareFlower];
    [self.view addSubview: shareFlower];
    [self addGestureRecognizerForRemovingShareFlower];
}

- (void)addGestureRecognizerForRemovingShareFlower
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeShareFlower)];
    [tap setNumberOfTapsRequired:1];
    [tap setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:tap];
}

- (void)removeShareFlower
{
    [shareFlower collapseItems];
}



#pragma mark - KLExpandingSelectDataSource

- (NSInteger)expandingSelector:(id) expandingSelect numberOfRowsInSection:(NSInteger)section{
    return [selectorData count];
}
- (KLExpandingPetal *)expandingSelector:(id) expandingSelect itemForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* dictForPetal = [selectorData objectAtIndex:indexPath.row];
    NSString* imageName;
    if (indexPath.row == kIndexFavorite) {
        if ([self isStarred]) {
            imageName = [dictForPetal objectForKey:@"image2"];
        }
        else {
            imageName = [dictForPetal objectForKey:@"image"];
        }
    }
    else {
        imageName = [dictForPetal objectForKey:@"image"];
    }
    KLExpandingPetal* petal = [[KLExpandingPetal alloc] initWithImage:[UIImage imageNamed:imageName]];
    return petal;
}

#pragma mark - KLExpandingSelect Delegate Methods
// Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
- (NSIndexPath *)expandingSelector:(id)expandingSelect willSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return  indexPath;
}


// Called after the user changes the selection.
- (void)expandingSelector:(id)expandingSelect didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == kIndexEmail) {
        MFMailComposeViewController* mailViewController = [[MFMailComposeViewController alloc] init];
        [mailViewController setMailComposeDelegate: self];
        [mailViewController setSubject:@"Interessant artikkel jeg fant via nyhetene for iPhone"];
        [mailViewController setMessageBody:[NSString stringWithFormat:@"%@ \n\n %@", _newsArticle.title, [_newsArticle.link absoluteString]] isHTML:NO];
        [self presentViewController: mailViewController
                           animated: YES
                         completion: nil];
        return;
    }
    else {
        SLComposeViewController* shareViewController;
        
        switch (indexPath.row) {
            case kIndexEmail:
                break;
            case kIndexFaceBook:
                shareViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                break;
            case kIndexTwitter:
                shareViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                break;
            case kIndexFavorite:
                //Handle favorites
                [self starArticle];
                return;
            default:
                break;
        }
        [shareViewController addURL: _newsArticle.link];
        [shareViewController setInitialText:@"Interessant artikkel jeg fant via nyhetene for iPhone"];
        
        if ([SLComposeViewController isAvailableForServiceType:shareViewController.serviceType]) {
            [self presentViewController:shareViewController
                               animated:YES
                             completion: nil];
        }
        else {
            UIAlertView* errorAlert = [[UIAlertView alloc] initWithTitle: @"Tjenesten er ikke støttet"
                                                                 message: @"Gå til innstillinger og konfigurer tjenesten."
                                                                delegate: nil
                                                       cancelButtonTitle: nil
                                                       otherButtonTitles: nil];
            [errorAlert show];
        }
    }
}

-(BOOL)isStarred
{
    NSMutableArray *starred;
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"starredArticles"];
    if (data) {
        starred = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    for (News *news in starred) {
        if ([[news.link absoluteString] compare:[_newsArticle.link absoluteString]] == NSOrderedSame) {
            return YES;
        }
    }
    return NO;
}

-(void)starArticle
{
    NSMutableArray *starred;
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"starredArticles"];
    if (data) {
        starred = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    for (News *news in starred) {
        if ([[news.link absoluteString] compare:[_newsArticle.link absoluteString]] == NSOrderedSame) {
            
            [starred removeObject:news];
            NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:starred];
            [[NSUserDefaults standardUserDefaults] setObject:archiveData forKey:@"starredArticles"];
            return;
        }
    }
    
    if (!starred) {
        starred = [[NSMutableArray alloc] init];
    }
    [starred addObject:_newsArticle];
    NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:starred];
    [[NSUserDefaults standardUserDefaults] setObject:archiveData forKey:@"starredArticles"];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Artikkel lagt til" message:@"Artikkelen er nå lagt til i favoritter." delegate:self cancelButtonTitle:@"Lukk" otherButtonTitles:nil];
    [alertView show];
}

//Called after the animations have completed
- (void)expandingSelector:(id)expandingSelect didFinishExpandingAtPoint:(CGPoint) point {
}
- (void)expandingSelector:(id)expandingSelect didFinishCollapsingAtPoint:(CGPoint) point {
}

#pragma mark - MFMailComposerDelegate callback

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
