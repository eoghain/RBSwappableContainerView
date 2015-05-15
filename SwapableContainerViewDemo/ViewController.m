//
//  ViewController.m
//  SwapableContainerViewDemo
//
//  Created by Rob Booth on 5/14/15.
//  Copyright (c) 2015 Rob Booth. All rights reserved.
//

#import "ViewController.h"
#import "RBSwapableContainerViewController.h"
#import "ComicData.h"
#import "ComicImageViewController.h"
#import "ComicDescriptionViewController.h"
#import "ComicPriceTableViewController.h"
#import "NSString+SwappableDemo.h"

@interface ShrinkFadeAnimatedTransition : NSObject <UIViewControllerAnimatedTransitioning>
@end

@interface GrowFadeAnimatedTransition : NSObject <UIViewControllerAnimatedTransitioning>
@end


@interface ViewController ()< RBSwapableContainerDelegate >

@property (strong, nonatomic) RBSwapableContainerViewController * swapVC;
@property (strong, nonatomic) NSArray * comicData;
@property (strong, nonatomic) NSDictionary * currentComic;
@property (assign, nonatomic) NSInteger currentIndex;

@property (strong, nonatomic) IBOutlet UILabel * titleLabel;
@property (strong, nonatomic) IBOutlet UILabel * attributionLabel;
@property (strong, nonatomic) IBOutlet UIButton * imageBtn;
@property (strong, nonatomic) IBOutlet UIButton * detailBtn;
@property (strong, nonatomic) IBOutlet UIButton * priceBtn;

@property (strong, nonatomic) ComicImageViewController * comicImageVC;
@property (strong, nonatomic) ComicDescriptionViewController * comicDescVC;
@property (strong, nonatomic) ComicPriceTableViewController * comicPriceTVC;


@end

@implementation ViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    self.comicData = [ComicData data][@"data"][@"results"];
    self.currentIndex = 0;
    self.currentComic = self.comicData[self.currentIndex];
    self.attributionLabel.text = [ComicData data][@"attributionText"];
    
    [self loadContainedViewControllers];
    
    self.imageBtn.enabled = NO;
    self.imageBtn.titleLabel.font = [UIFont fontWithName:@"swappable_demo" size:17];
    [self.imageBtn setTitle:[NSString iconPicture] forState:UIControlStateNormal];
    
    self.detailBtn.titleLabel.font = [UIFont fontWithName:@"swappable_demo" size:17];
    [self.detailBtn setTitle:[NSString iconDocText] forState:UIControlStateNormal];
    
    self.priceBtn.titleLabel.font = [UIFont fontWithName:@"swappable_demo" size:17];
    [self.priceBtn setTitle:[NSString iconDollar] forState:UIControlStateNormal];
    
    [self updateViewControllers];
}


#pragma mark - Helper Methods

- (void)loadContainedViewControllers
{
    if (self.comicImageVC == nil) self.comicImageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Image"];
    if (self.comicDescVC == nil) self.comicDescVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Description"];
    if (self.comicPriceTVC == nil) self.comicPriceTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Prices"];
}

- (NSURL *)imageURL
{
    // Get Image URL
    NSString * imagePath = self.currentComic[@"thumbnail"][@"path"];
    imagePath = [imagePath stringByAppendingString:@"/portrait_uncanny."];
    imagePath = [imagePath stringByAppendingString:self.currentComic[@"thumbnail"][@"extension"]];
    return [NSURL URLWithString:imagePath];
}

- (void)updateViewControllers
{
    self.titleLabel.text = self.currentComic[@"title"];
    
    [self.comicImageVC setImageURL:[self imageURL]];
    [self.comicDescVC setComicData:self.currentComic];
    [self.comicPriceTVC setComicData:self.currentComic];
}

#pragma mark - IBActions

- (IBAction)showImage:(id)sender
{
    self.swapVC.selectedIndex = 0;
    self.imageBtn.enabled = NO;
    self.detailBtn.enabled = YES;
    self.priceBtn.enabled = YES;
}

- (IBAction)showDetail:(id)sender
{
    self.swapVC.selectedIndex = 1;
    self.imageBtn.enabled = YES;
    self.detailBtn.enabled = NO;
    self.priceBtn.enabled = YES;
}

- (IBAction)showPrice:(id)sender
{
    self.swapVC.selectedIndex = 2;
    self.imageBtn.enabled = YES;
    self.detailBtn.enabled = YES;
    self.priceBtn.enabled = NO;
}

- (IBAction)previous:(id)sender
{
    self.currentIndex--;
    if (self.currentIndex < 0)
    {
        self.currentIndex = [self.comicData count] - 1;
    }
    
    self.currentComic = self.comicData[self.currentIndex];
    [self updateViewControllers];
}

- (IBAction)next:(id)sender
{
    self.currentIndex++;
    if (self.currentIndex >= [self.comicData count])
    {
        self.currentIndex = 0;
    }
    
    self.currentComic = self.comicData[self.currentIndex];
    [self updateViewControllers];
}

#pragma mark - RBSwapableContainerViewController Delegate

- (void)animationEndedForcontainerViewController:(RBSwapableContainerViewController *)containerViewController
{
}

- (id<UIViewControllerAnimatedTransitioning>)containerViewController:(RBSwapableContainerViewController *)containerViewController animationControllerForTransitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
{
    if (fromViewController == self.comicImageVC)
    {
        return [[ShrinkFadeAnimatedTransition alloc] init];
    }
    
    if (toViewController == self.comicImageVC)
    {
        return [[GrowFadeAnimatedTransition alloc] init];
    }
    
    return nil;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embedSwapableViewController"])
    {
        [self loadContainedViewControllers];
        
        RBSwapableContainerViewController * swapVC = segue.destinationViewController;
        
        swapVC.selectedIndex = 0;
        swapVC.delegate = self;
        swapVC.viewControllers = @[
            self.comicImageVC,
            self.comicDescVC,
            self.comicPriceTVC,
        ];
        
        self.swapVC = swapVC;
    }
    
}

@end

#pragma mark - Custom Animations -

static CGFloat const kDamping = 0.75;
static CGFloat const kInitialSpringVelocity = 0.5;

@implementation ShrinkFadeAnimatedTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1;
}

/// Slide views horizontally, with a bit of space between, while fading out and in.
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(0.1, 0.1);
    
    [[transitionContext containerView] addSubview:toViewController.view];
    toViewController.view.alpha = 0;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:kDamping initialSpringVelocity:kInitialSpringVelocity options:0x00 animations:^{
        fromViewController.view.transform = scaleTransform;
        fromViewController.view.alpha = 0;
        toViewController.view.alpha = 1;
    } completion:^(BOOL finished) {
        fromViewController.view.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end

@implementation GrowFadeAnimatedTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1;
}

/// Slide views horizontally, with a bit of space between, while fading out and in.
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(0.1, 0.1);
    
    [[transitionContext containerView] addSubview:toViewController.view];
    toViewController.view.alpha = 0;
    toViewController.view.transform = scaleTransform;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:kDamping initialSpringVelocity:kInitialSpringVelocity options:0x00 animations:^{
        fromViewController.view.alpha = 1;
        toViewController.view.transform = CGAffineTransformIdentity;
        toViewController.view.alpha = 2;
    } completion:^(BOOL finished) {
        fromViewController.view.alpha = 1;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
