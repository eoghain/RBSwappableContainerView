# RBSwapableContainerViewController

![license](https://img.shields.io/badge/license-MIT-blue.svg) ![cocoapods](https://img.shields.io/badge/pod-valid-brightgreen.svg) ![platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)

An implementation of [Objc.IO's](www.objc.io) [Custom Container View Controller Transitions](http://www.objc.io/issue-12/custom-container-view-controller-transitions.html) with inspiration from Michael Luton's [custom container view controllers](http://sandmoose.com/post/35714028270/storyboards-with-custom-container-view-controllers) blog post.

My goal was to allow for the swapping out of a content view while leaving my navigation controls in place in my parent UIViewController.  After building this, I realized that it could easily be used to re-create a UITabBarController (minus the IB niceties that Apple won't let us implement yet).