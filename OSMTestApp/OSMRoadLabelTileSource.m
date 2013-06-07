//
//  OSMRoadLabelTileSource.m
//  OSMTestApp
//
//  Created by Steve Gifford on 6/6/13.
//  Copyright (c) 2013 mousebird consulting. All rights reserved.
//

#import "OSMRoadLabelTileSource.h"

@implementation OSMRoadLabelTileSource

- (NSMutableArray *)addFeatures:(MaplyVectorObject *)vecs toView:(MaplyBaseViewController *)viewC forTile:(MaplyTileID)tileID inLayer:(MaplyQuadPagingLayer *)layer
{
    NSMutableArray *compObjs = [NSMutableArray array];
    
    // We'll check the labels against the tile bounds
    MaplyCoordinate tileLL,tileUR;
    [layer geoBoundsforTile:tileID ll:&tileLL ur:&tileUR];

    NSMutableArray *labels = [NSMutableArray array];
    NSArray *lines = [vecs splitVectors];
    for (MaplyVectorObject *line in lines)
    {
        MaplyCoordinate middle;
        float rot;
        if ([line linearMiddle:&middle rot:&rot])
        {
//            if (tileLL.x <= middle.x && tileLL.y <= middle.y &&
//                middle.x < tileUR.x && middle.y < tileUR.y)
            {
                MaplyScreenLabel *label = [[MaplyScreenLabel alloc] init];
                label.loc = middle;
                label.text = line.attributes[@"name"];
                label.selectable = false;
                label.layoutImportance = 1.0;
                label.rotation = rot;
                if (label.text)
                    [labels addObject:label];
            }
        }
    }
    
    if ([labels count] > 0)
    {
        MaplyComponentObject *compObj = [viewC addScreenLabels:labels desc:
                                         @{kMaplyTextColor: [UIColor blackColor],
                                              kMaplyEnable: @(NO),
                                                    kMaplyFont: [UIFont systemFontOfSize:10.0]
                                         }];
        if (compObj)
            [compObjs addObject:compObj];
    }
    
    if ([compObjs count] == 0)
        return nil;
    
    return compObjs;
}

@end
