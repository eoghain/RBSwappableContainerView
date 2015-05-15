//
//  RBSwappableContainerViewController.h
//  SwappableContainerViewDemo
//
//  Created by Rob Booth on 5/14/15.
//  Copyright (c) 2015 Rob Booth. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  RBSwappableContainerViewController;

@protocol RBSwappableContainerDelegate <NSObject>

@optional
- (void)containerViewController:(RBSwappableContainerViewController *)containerViewController didSelectViewController:(UIViewController *)viewController;
- (void)animationEndedForcontainerViewController:(RBSwappableContainerViewController *)containerViewController;
- (id <UIViewControllerAnimatedTransitioning>)containerViewController:(RBSwappableContainerViewController *)containerViewController animationControllerForTransitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController;

@end

@interface RBSwappableContainerViewController : UIViewController

@property (weak, nonatomic) id<RBSwappableContainerDelegate> delegate;
@property (strong, nonatomic) NSArray * viewControllers;
@property (assign, nonatomic) NSInteger selectedIndex;

@end
