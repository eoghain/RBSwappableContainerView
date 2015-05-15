//
//  RBSwapableContainerViewController.h
//  SwapableContainerViewDemo
//
//  Created by Rob Booth on 5/14/15.
//  Copyright (c) 2015 Rob Booth. All rights reserved.
//

#import "ViewController.h"

@class  RBSwapableContainerViewController;

@protocol RBSwapableContainerDelegate <NSObject>

@optional
- (void)containerViewController:(RBSwapableContainerViewController *)containerViewController didSelectViewController:(UIViewController *)viewController;
- (void)animationEndedForcontainerViewController:(RBSwapableContainerViewController *)containerViewController;
- (id <UIViewControllerAnimatedTransitioning>)containerViewController:(RBSwapableContainerViewController *)containerViewController animationControllerForTransitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController;

@end

@interface RBSwapableContainerViewController : ViewController

@property (weak, nonatomic) id<RBSwapableContainerDelegate> delegate;
@property (strong, nonatomic) NSArray * viewControllers;
@property (assign, nonatomic) NSInteger selectedIndex;

@end
