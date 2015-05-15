//
//  ComicData.m
//  RBCollectionViewInfoFolderLayout
//
//  Created by Rob Booth on 4/4/14.
//
//

#import "ComicData.h"

@implementation ComicData

+ (NSDictionary *)data
{
    NSString * path = [[NSBundle mainBundle] pathForResource:@"xmenData" ofType:@"json"];
    NSData * data = [NSData dataWithContentsOfFile:path];
    id xmen = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    return xmen;
}

@end