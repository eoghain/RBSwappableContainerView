//
//  ComicPriceTableViewController.h
//  SwappableContainerViewDemo
//
//  Created by Rob Booth on 5/15/15.
//  Copyright (c) 2015 Rob Booth. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComicPriceTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSDictionary * comicData;

@end
