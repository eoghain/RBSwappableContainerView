//
//  ComicImageViewController.m
//  SwapableContainerViewDemo
//
//  Created by Rob Booth on 5/14/15.
//  Copyright (c) 2015 Rob Booth. All rights reserved.
//

#import "ComicImageViewController.h"

@interface ComicImageViewController ()

@property (strong, nonatomic) IBOutlet UIImageView * imageView;
@property (nonatomic, strong) NSCache * imageCache;

@end

@implementation ComicImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageCache = [[NSCache alloc] init];
}

- (void)setImageURL:(NSURL *)imageURL
{    
    if ([self.imageCache objectForKey:imageURL] == nil)
    {
        __weak typeof(self) weakSelf = self;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [weakSelf.imageCache setObject:image forKey:imageURL];
                
                [self.imageView setImage:image];
                [self.view setNeedsLayout];
            });
        });
    }
    else
    {
        self.imageView.image = [self.imageCache objectForKey:imageURL];
    }
}

@end
