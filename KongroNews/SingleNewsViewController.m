//
//  SingleNewsViewController.m
//  KongroNews
//
//  Created by Kent Robin Haugen on 23.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import "SingleNewsViewController.h"
#import "Colors.h"
#import "Constants.h"
#import "HelpMethods.h"
#import "NSDate+TimeSince.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "RootViewController.h"
#import "NSString+HTML.h"

#define kIndexTwitter 0
#define kIndexFavorite 1
#define kIndexEmail 2
#define kIndexFaceBook 3

#define NUMBER_OF_GRADIENTS 5;

@interface SingleNewsViewController (){
    KLExpandingSelect *shareFlower;
    NSArray *selectorData;
    int counter;
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
    [self initShareFlower];
    if ([RootViewController isFirstRun]) {
        [self setUpPopUp];
    }
}

//- (NSString *)getSummarizedNews
//{
//    NSString *apiUrl = @"http://clipped.me/algorithm/clippedapi.php?url=";
//    apiUrl = [apiUrl stringByAppendingString:_newsArticle.link.absoluteString];
//    
//    NSURL *url = [NSURL URLWithString:apiUrl];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    NSURLResponse *response;
//    NSError *error;
//    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//    if (data == nil || (error != nil && [error code] != noErr)) {
//        // If there was a no data received, or an error...
//        NSLog(@"Error fetching json");
//        NSLog(@"URL: %@", apiUrl);
//        //            dispatch_async(dispatch_get_main_queue(), ^{
//        //
//        //            });
//    } else {
//        // Handle the data
//        NSError *error;
//        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//        NSArray *queryResponse = [jsonData objectForKey:@"summary"];
//        NSString *cliffNotes = @"";
//        for (int i=0; i<queryResponse.count; i++) {
//            cliffNotes = [cliffNotes stringByAppendingString:[NSString stringWithFormat:@"- %@\n\n", [queryResponse objectAtIndex:i]]];
//        }
//        cliffNotes = [cliffNotes stringByConvertingHTMLToPlainText];
//        return cliffNotes;
//    }
//    return _newsArticle.leadText;
//}

- (void)setUpPopUp
{
    CMPopTipView *popTip;
    popTip = [[CMPopTipView alloc] initWithMessage:@"Dra til siden for å lese neste artikkel."];
    [popTip setTextColor:[UIColor whiteColor]];
    [popTip setTextFont:[UIFont fontWithName:BUTTON_FONT_TYPE size:BUTTON_FONT_SIZE]];
    [popTip setBackgroundColor:[Colors help]];
    [popTip setDismissTapAnywhere:YES];
    [popTip setDelegate:self];
    [popTip presentPointingAtView:_textView inView:self.view animated:YES];
    counter = 0;
}

- (void)viewDidAppear:(BOOL)animated
{
    _timeSinceLabel.text = [_newsArticle.pubDate timeSinceFromDate];
}

- (void)setUpUi
{
    _titleLabel.text = _newsArticle.title;
    [self trimLeadText];
    _textView.text = _newsArticle.leadText;
    _pageNumber.text = [NSString stringWithFormat:@"%d", _pageIndex];
    if (_newsArticle.imageUrl) {
        [_imageView setImageWithURL:_newsArticle.imageUrl];
//        [_imageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:_newsArticle.imageUrl]]];
        UIView *filterView = [[UIView alloc] initWithFrame:_imageView.frame];
        [filterView setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f]];
        [_imageView addSubview:filterView];
    }
    else {
        int random = _pageIndex % NUMBER_OF_GRADIENTS;
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
        UIView *filterView = [[UIView alloc] initWithFrame:_imageView.frame];
        [filterView setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f]];
        [_imageView insertSubview:filterView belowSubview:_titleLabel];
    }
    
    [_timeSinceLabel setText:[_newsArticle.pubDate timeSinceFromDate]];
    [_timeSinceLabel setFont:[UIFont fontWithName:@"AmericanTypewriter" size:14.0f]];
    [_timeSinceLabel sizeToFit];
    if ([_newsArticle.publisher isKindOfClass:[NSArray class]]) {
        NSArray *pubs = (NSArray *)_newsArticle.publisher;
        _providerLabel.text = [pubs objectAtIndex:0];
    }
    else if ([_newsArticle.publisher isKindOfClass:[NSString class]]) {
        _providerLabel.text = _newsArticle.publisher;
    }
    else {
        _providerLabel.text = @"";
    }
}

- (void)trimLeadText
{
    if (IS_IPHONE_5) {
        if (_newsArticle.leadText.length > 460) {
            NSString *text = [_newsArticle.leadText substringToIndex:460];
            _newsArticle.leadText = [NSString stringWithFormat:@"%@%@", text, @"..."];
        }
    }
    else {
        if (_newsArticle.leadText.length > 280) {
            NSString *text = [_newsArticle.leadText substringToIndex:280];
            _newsArticle.leadText = [NSString stringWithFormat:@"%@%@", text, @"..."];
        }
    }
    
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
        [TestFlight passCheckpoint:@"SingleNewsView: ShareFlower mail clicked."];
        if ([MFMailComposeViewController canSendMail])
        {
            MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
            [mailViewController setMailComposeDelegate:self];
            [mailViewController setSubject:@"[via @nyheteneapp for iPhone]"];
            [mailViewController setMessageBody:[NSString stringWithFormat:@"%@ \n\n %@", _newsArticle.title, [_newsArticle.link absoluteString]] isHTML:NO];
            [self presentViewController:mailViewController animated:YES completion:nil];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Send mail" message:@"Ingen mailkonto er lagt inn på enheten. Registrer en mailkonto og prøv igjen." delegate:nil cancelButtonTitle:@"Lukk" otherButtonTitles: nil];
            [alertView show];
        }
        return;
    }
    else {
        SLComposeViewController* shareViewController;
        NSString *shareText;
        
        switch (indexPath.row) {
            case kIndexEmail:
                break;
            case kIndexFaceBook:
                [TestFlight passCheckpoint:@"SingleNewsView: ShareFlower Facebook clicked."];
                shareViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                shareText = @"Via http://fb.com/nyheteneapp - ";
                break;
            case kIndexTwitter:
                [TestFlight passCheckpoint:@"SingleNewsView: ShareFlower Twitter clicked."];
                shareViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                shareText = @"Via @nyheteneapp - ";
                break;
            case kIndexFavorite:
                //Handle favorites
                [TestFlight passCheckpoint:@"SingleNewsView: ShareFlower Star clicked."];
                [self starArticle];
                return;
            default:
                break;
        }
        [shareViewController addURL: _newsArticle.link];
        [shareViewController setInitialText:shareText];
        
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
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Artikkel fjernet" message:@"Artikkelen er nå fjernet fra favoritter." delegate:self cancelButtonTitle:@"Lukk" otherButtonTitles:nil];
            [alertView show];
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

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:^{
        //        _shouldAnimate = YES;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CMPopTipViewDelegate Methods
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    CMPopTipView *popTip = [[CMPopTipView alloc] init];
    [popTip setTextColor:[UIColor whiteColor]];
    [popTip setTextFont:[UIFont fontWithName:BUTTON_FONT_TYPE size:BUTTON_FONT_SIZE]];
    [popTip setBackgroundColor:[Colors help]];
    [popTip setDismissTapAnywhere:YES];
    [popTip setDelegate:self];
    
    if (counter == 0) {
        
        [popTip setMessage:@"Dra ned for å lese hele artikkelen."];
        [popTip presentPointingAtView:_textView inView:self.view animated:YES];
        counter++;
    }
    else if (counter == 1) {
        [popTip setMessage:@"Hold nede én finger for å åpne delemenyen."];
        [popTip presentPointingAtView:_textView inView:self.view animated:YES];
        counter++;
    }
    else if (counter == 2) {
        [popTip setMessage:@"Dobbelklikk med én finger for oppdatere nyhetene og gå til nyeste artikkel."];
        [popTip presentPointingAtView:_textView inView:self.view animated:YES];
        counter++;
        [RootViewController setIsFirstRun:NO];
    }
}

@end
