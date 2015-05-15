//
//  ComicDescriptionViewController.m
//  SwappableContainerViewDemo
//
//  Created by Rob Booth on 5/15/15.
//  Copyright (c) 2015 Rob Booth. All rights reserved.
//

#import "ComicDescriptionViewController.h"

@interface ComicDescriptionViewController ()

@property (strong, nonatomic) IBOutlet UILabel * descLabel;

@end

@implementation ComicDescriptionViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateDescription];
}

- (void)setComicData:(NSDictionary *)comicData
{
    _comicData = comicData;
    [self updateDescription];
}

- (void)updateDescription
{
    self.descLabel.text = self.comicData[@"description"];
}

@end
