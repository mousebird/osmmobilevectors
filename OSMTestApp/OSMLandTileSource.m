//
//  OSMLandTileSource.m
//  OSMTestApp
//
//  Created by Steve Gifford on 5/31/13.
//  Copyright (c) 2013 mousebird consulting. All rights reserved.
//

#import "OSMLandTileSource.h"

@implementation OSMLandTileSource

- (NSMutableArray *)addFeatures:(MaplyVectorObject *)vecs toView:(MaplyBaseViewController *)viewC forTile:(MaplyTileID)tileID inLayer:(MaplyQuadPagingLayer *)layer
{
    NSMutableArray *compObjs = [NSMutableArray array];
    
    // We'll tesselate these here rather than make the layer thread do it
    MaplyVectorObject *tris = [vecs tesselate];

    // Convert this into vectors and toss it up there
    float alpha = 0.25;
    MaplyComponentObject *compObj = [viewC addVectors:@[tris] desc:
                                     @{kMaplyColor: [UIColor colorWithRed:111/255.0*alpha green:224/255.0*alpha blue:136/255.0*alpha alpha:alpha],kMaplyDrawOffset: @(0),
                                   kMaplyDrawPriority: @(100),
                                           kMaplyFade: @(self.fade),
                                         kMaplyEnable: @(NO),
                                         kMaplyFilled: @(YES)
                                     }];
    if (compObj)
        [compObjs addObject:compObj];
    
    return compObjs;
}

@end
