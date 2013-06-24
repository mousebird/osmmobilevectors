//
//  OSMBuildingTileSource.m
//  OSMTestApp
//
//  Created by Steve Gifford on 5/31/13.
//  Copyright (c) 2013 mousebird consulting. All rights reserved.
//

#import "OSMBuildingTileSource.h"

@implementation OSMBuildingTileSource

- (NSMutableArray *)addFeatures:(MaplyVectorObject *)vecs toView:(MaplyBaseViewController *)viewC forTile:(MaplyTileID)tileID inLayer:(MaplyQuadPagingLayer *)layer
{
    if (!vecs)
        return nil;

    NSMutableArray *compObjs = [NSMutableArray array];
    
    // Convert this into vectors and toss it up there
    MaplyComponentObject *compObj = [viewC addVectors:@[vecs] desc:
                                     @{kMaplyColor: [UIColor colorWithRed:1.0 green:186/255.0 blue:103/255.0 alpha:1.0],
                                     kMaplyDrawOffset: @(0),
                                   kMaplyDrawPriority: @(600),
                                         kMaplyFilled: @(YES),
                                           kMaplyFade: @(self.fade),
                                         kMaplyEnable: @(NO)}];
    if (compObj)
        [compObjs addObject:compObj];
    compObj = [viewC addVectors:@[vecs] desc:
               @{kMaplyColor: [UIColor colorWithRed:1.0/2.0 green:186/255.0/2.0 blue:103/255.0/2.0 alpha:1.0],
               kMaplyDrawOffset: @(0),
             kMaplyDrawPriority: @(601),
                     kMaplyFade: @(self.fade),
                   kMaplyEnable: @(NO)}];
    if (compObj)
        [compObjs addObject:compObj];
    
    return compObjs;
}

@end
