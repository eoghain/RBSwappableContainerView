# RBSwappableContainerViewController

![license](https://img.shields.io/badge/license-MIT-blue.svg) ![cocoapods](https://img.shields.io/badge/pod-valid-brightgreen.svg) ![platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)

An implementation of [Objc.IO's](www.objc.io) [Custom Container View Controller Transitions](http://www.objc.io/issue-12/custom-container-view-controller-transitions.html) with inspiration from Michael Luton's [custom container view controllers](http://sandmoose.com/post/35714028270/storyboards-with-custom-container-view-controllers) blog post.

My goal was to allow for the swapping out of a content view while leaving my navigation controls in place in my parent UIViewController.  With very little code in your main ViewController you can now have a container that changes it's content with animations while still having nice encapsulation.


## Usage

Here in the `prepareForSegue:` method I identify the embed segue and use it's destinationViewController to setup my `RBSwappableContainerViewController` with the list of viewControllers that it will control:

```ObjC
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embedSwappableViewController"])
    {
        [self loadContainedViewControllers];
        
        RBSwappableContainerViewController * swapVC = segue.destinationViewController;
        
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
```

And here I just change the selectedIndex to kick off the swapping animation in regards to a button press:

```ObjC
- (IBAction)showDetail:(id)sender
{
    self.swapVC.selectedIndex = 1;
    self.imageBtn.enabled = YES;
    self.detailBtn.enabled = NO;
    self.priceBtn.enabled = YES;
}
```

### Example

Example of container mid-transition.  The image is shrinking and fading away while the description text is fading in.  All of the surrounding UI is static, Title, Buttons, Footer, are all a part of the containing UIViewController.

![ScreenShot](https://raw.githubusercontent.com/eoghain/RBSwappableContainerView/master/Screenshots/TransitionAnimation.png)