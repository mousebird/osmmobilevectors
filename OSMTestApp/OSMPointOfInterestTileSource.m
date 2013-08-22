//
//  OSMPointOfInterestTileSource.m
//  OSMTestApp
//
//  Created by Steve Gifford on 8/19/13.
//  Copyright (c) 2013 mousebird consulting. All rights reserved.
//

#import "OSMPointOfInterestTileSource.h"

@implementation OSMPointOfInterestTileSource

- (NSMutableArray *)addFeatures:(MaplyVectorObject *)vecs toView:(MaplyBaseViewController *)viewC forTile:(MaplyTileID)tileID inLayer:(MaplyQuadPagingLayer *)layer
{
    if (!vecs)
        return nil;
    UIFont *textFont = [UIFont systemFontOfSize:14.0];
    
    NSMutableArray *labels = [NSMutableArray array];
    for (MaplyVectorObject *pt in [vecs splitVectors])
    {
        if ([pt vectorType] == MaplyVectorPointType)
        {
            NSString *name = pt.attributes[@"name"];
            if (name)
            {
                MaplyScreenLabel *label = [[MaplyScreenLabel alloc] init];
                label.loc = [pt center];
                label.text = name;
                label.selectable = false;
                label.layoutImportance = 2.0;
//                label.layoutPlacement = kMaplyLayoutRight;
                [labels addObject:label];
            }
        }
    }
    
    MaplyComponentObject *compObj = nil;
    if ([labels count] > 0)
        compObj = [viewC addScreenLabels:labels
                          desc:
            @{kMaplyTextColor: [UIColor colorWithRed:1.0 green:0.75 blue:0.75 alpha:1.0],
                  kMaplyEnable: @(NO),
                   kMaplyTextOutlineSize: @(1.0),
                  kMaplyTextOutlineColor: [UIColor blackColor],
                    kMaplyFont: textFont}];
    
    if (compObj)
        return [NSMutableArray arrayWithObject:compObj];
    
    return nil;
}

@end
