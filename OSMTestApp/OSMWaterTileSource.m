//
//  OSMWaterTileSource.m
//  OSMTestApp
//
//  Created by Steve Gifford on 5/31/13.
//  Copyright (c) 2013 mousebird consulting. All rights reserved.
//

#import "OSMWaterTileSource.h"

@implementation OSMWaterTileSource

- (NSMutableArray *)addFeatures:(MaplyVectorObject *)vecs toView:(MaplyBaseViewController *)viewC forTile:(MaplyTileID)tileID inLayer:(MaplyQuadPagingLayer *)layer
{
    NSMutableArray *compObjs = [NSMutableArray array];
    
    // We'll tesselate these here rather than make the layer thread do it
    MaplyVectorObject *tris = [vecs tesselate];
        
    // Convert this into vectors and toss it up there
    MaplyComponentObject *compObj = [viewC addVectors:@[tris] desc:
                                     @{kMaplyColor: [UIColor colorWithRed:137/255.0 green:188/255.0 blue:228/255.0 alpha:1.0],kMaplyDrawOffset: @(0),
                                   kMaplyDrawPriority: @(200),
                                         kMaplyFilled: @(YES),
                                         kMaplyEnable: @(NO),
                                           kMaplyFade: @(self.fade)
                                     }];
    if (compObj)
        [compObjs addObject:compObj];
    
    // And an outline
//    compObj = [viewC addVectors:@[vecs] desc:
//               @{kMaplyColor: [UIColor blueColor],
//                   kMaplyEnable: @(NO)
//               }];
//    if (compObj)
//        [compObjs addObject:compObj];
    
    return compObjs;
}

@end
