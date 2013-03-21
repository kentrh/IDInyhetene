//
//  NewsPageViewController.m
//  KongroNews
//
//  Created by Kent Robin Haugen on 21.03.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import "NewsPageViewController.h"

@interface NewsPageViewController ()

@end

@implementation NewsPageViewController

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
	// Do any additional setup after loading the view.
    [self setGestureRecognizerDelegates];
}

- (void)setGestureRecognizerDelegates
{
    for (UIGestureRecognizer *gr in self.gestureRecognizers) {
        gr.delegate = self;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
        UIPanGestureRecognizer *panGR = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint distance = [panGR translationInView:self.view]; // get distance of pan/swipe in the view in which the gesture recognizer was added
        [panGR cancelsTouchesInView];
        if (distance.x > 0 && abs(distance.y) < abs(distance.x)) { // right
            return YES;
        } else if (distance.x < 0 && abs(distance.y) < abs(distance.x)) { //left
            return YES;
        }
        if (distance.y > 0 && abs(distance.y) > abs(distance.x)) { // down
            return NO;
        } else if (distance.y < 0 && abs(distance.y) > abs(distance.x)) { //up
            return NO;
        }
        
    }
    return NO;
}

@end
