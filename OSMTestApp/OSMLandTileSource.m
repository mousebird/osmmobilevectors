//
//  OSMLandTileSource.m
//  OSMTestApp
//
//  Created by Steve Gifford on 5/31/13.
//  Copyright (c) 2013 mousebird consulting. All rights reserved.
//

#import "OSMLandTileSource.h"

@implementation OSMLandTileSource

- (NSMutableArray *)addFeatures:(MaplyVectorObject *)vecs toView:(MaplyBaseViewController *)viewC
{
    NSMutableArray *compObjs = [NSMutableArray array];
    
    // Convert this into vectors and toss it up there
    MaplyComponentObject *compObj = [viewC addVectors:@[vecs] desc:@{kMaplyColor: [UIColor colorWithRed:111/255.0 green:224/255.0 blue:136/255.0 alpha:1.0],kMaplyDrawOffset: @(0), kMaplyDrawPriority: @(200),kMaplyFade: @(self.fade), kMaplyFilled: @(YES)}];
    if (compObj)
        [compObjs addObject:compObj];
    
    return compObjs;
}

@end
