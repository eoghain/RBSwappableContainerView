//
//  RBSwapableContainerViewController.m
//  SwapableContainerViewDemo
//
//  Created by Rob Booth on 5/14/15.
//  Copyright (c) 2015 Rob Booth. All rights reserved.
//

#import "RBSwapableContainerViewController.h"

/** A private UIViewControllerContextTransitioning class to be provided transitioning delegates.
 @discussion Because we are a custom UIVievController class, with our own containment implementation, we have to provide an object conforming to the UIViewControllerContextTransitioning protocol. The system view controllers use one provided by the framework, which we cannot configure, let alone create. This class will be used even if the developer provides their own transitioning objects.
 @note The only methods that will be called on objects of this class are the ones defined in the UIViewControllerContextTransitioning protocol. The rest is our own private implementation.
 */
@interface PrivateTransitionContext : NSObject <UIViewControllerContextTransitioning>
- (instancetype)initWithFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController; /// Designated initializer.
@property (nonatomic, copy) void (^completionBlock)(BOOL didComplete); /// A block of code we can set to execute after having received the completeTransition: message.
@property (nonatomic, assign, getter=isAnimated) BOOL animated; /// Private setter for the animated property.
@property (nonatomic, assign, getter=isInteractive) BOOL interactive; /// Private setter for the interactive property.
@end

/** Instances of this private class perform the default transition animation which is to slide child views horizontally.
 @note The class only supports UIViewControllerAnimatedTransitioning at this point. Not UIViewControllerInteractiveTransitioning.
 */
@interface PrivateAnimatedTransition : NSObject <UIViewControllerAnimatedTransitioning>
@end


@interface RBSwapableContainerViewController ()

@property (assign, nonatomic) BOOL isTransitioning;

@end

@implementation RBSwapableContainerViewController


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add initial view controller

    UIViewController * currentViewController = self.viewControllers[self.selectedIndex];
    [currentViewController willMoveToParentViewController:self];
    
    [self addChildViewController:currentViewController];
    UIView * destView = currentViewController.view;
    destView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    destView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:destView];
    
    [currentViewController didMoveToParentViewController:self];
}


#pragma mark - Getters & Setters

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    if (self.isTransitioning)
    {
        return;
    }
    
    if (selectedIndex != _selectedIndex)
    {
        self.isTransitioning = YES;
        [self displayViewControllerAtIndex:selectedIndex];
        _selectedIndex = selectedIndex;
    }
}

#pragma mark - Private Methods

- (void)displayViewControllerAtIndex:(NSInteger)index
{
    UIViewController * toViewController = self.viewControllers[index];
    UIViewController * fromViewController = self.viewControllers[self.selectedIndex];
    
    if (toViewController == fromViewController)
    {
        return;
    }
    
    UIView *toView = toViewController.view;
    [toView setTranslatesAutoresizingMaskIntoConstraints:YES];
    toView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    toView.frame = self.view.bounds;
    
    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    
    // Animate the transition by calling the animator with our private transition context.
    // If we don't have a delegate, or if it doesn't return an animated transitioning object, we will use our own, private animator.
    
    id<UIViewControllerAnimatedTransitioning>animator = nil;
    if ([self.delegate respondsToSelector:@selector (containerViewController:animationControllerForTransitionFromViewController:toViewController:)]) {
        animator = [self.delegate containerViewController:self animationControllerForTransitionFromViewController:fromViewController toViewController:toViewController];
    }
    animator = (animator ?: [[PrivateAnimatedTransition alloc] init]);
    
    PrivateTransitionContext *transitionContext = [[PrivateTransitionContext alloc] initWithFromViewController:fromViewController toViewController:toViewController];
    
    transitionContext.animated = YES;
    transitionContext.interactive = NO;
    transitionContext.completionBlock = ^(BOOL didComplete) {
        [fromViewController.view removeFromSuperview];
        [fromViewController removeFromParentViewController];
        [toViewController didMoveToParentViewController:self];
        
        if ([animator respondsToSelector:@selector (animationEnded:)]) {
            [animator animationEnded:didComplete];
        }
        
        self.isTransitioning = NO;
        
        // Call the delegate on animation end just incase they didn't use a custom animation
        if ([self.delegate respondsToSelector:@selector(animationEndedForcontainerViewController:)])
        {
            [self.delegate animationEndedForcontainerViewController:self];
        }
    };
    
    [animator animateTransition:transitionContext];
}


@end

#pragma mark - Private Transitioning Classes -

@interface PrivateTransitionContext ()
@property (strong, nonatomic) NSDictionary *privateViewControllers;
@property (assign, nonatomic) CGRect privateDisappearingFromRect;
@property (assign, nonatomic) CGRect privateAppearingFromRect;
@property (assign, nonatomic) CGRect privateDisappearingToRect;
@property (assign, nonatomic) CGRect privateAppearingToRect;
@property (weak, nonatomic)   UIView *containerView;
@property (assign, nonatomic) UIModalPresentationStyle presentationStyle;
@end

@implementation PrivateTransitionContext

- (instancetype)initWithFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
{
    NSAssert ([fromViewController isViewLoaded] && fromViewController.view.superview, @"The fromViewController view must reside in the container view upon initializing the transition context.");
    
    if ((self = [super init]))
    {
        self.presentationStyle = UIModalPresentationCustom;
        self.containerView = fromViewController.view.superview;
        self.privateViewControllers = @{
            UITransitionContextFromViewControllerKey:fromViewController,
            UITransitionContextToViewControllerKey:toViewController,
        };
        
        CGFloat travelDistance = (-self.containerView.bounds.size.width);
        self.privateDisappearingFromRect = self.privateAppearingToRect = self.containerView.bounds;
        self.privateDisappearingToRect = CGRectOffset (self.containerView.bounds, travelDistance, 0);
        self.privateAppearingFromRect = CGRectOffset (self.containerView.bounds, -travelDistance, 0);
    }
    
    return self;
}

- (CGRect)initialFrameForViewController:(UIViewController *)viewController
{
    if (viewController == [self viewControllerForKey:UITransitionContextFromViewControllerKey])
    {
        return self.privateDisappearingFromRect;
    }
    else
    {
        return self.privateAppearingFromRect;
    }
}

- (CGRect)finalFrameForViewController:(UIViewController *)viewController
{
    if (viewController == [self viewControllerForKey:UITransitionContextFromViewControllerKey])
    {
        return self.privateDisappearingToRect;
    }
    else
    {
        return self.privateAppearingToRect;
    }
}

- (UIViewController *)viewControllerForKey:(NSString *)key
{
    return self.privateViewControllers[key];
}

- (void)completeTransition:(BOOL)didComplete
{
    if (self.completionBlock)
    {
        self.completionBlock (didComplete);
    }
}

- (BOOL)transitionWasCancelled { return NO; } // Our non-interactive transition can't be cancelled (it could be interrupted, though)

// Supress warnings by implementing empty interaction methods for the remainder of the protocol:
- (void)updateInteractiveTransition:(CGFloat)percentComplete {}
- (void)finishInteractiveTransition {}
- (void)cancelInteractiveTransition {}
- (CGAffineTransform)targetTransform { return CGAffineTransformIdentity; }
- (UIView *)viewForKey:(NSString *)key { return nil; }

@end

@implementation PrivateAnimatedTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

/// Crossfade views
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [[transitionContext containerView] addSubview:toViewController.view];
    toViewController.view.alpha = 0;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromViewController.view.alpha = 0;
        toViewController.view.alpha = 1;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
