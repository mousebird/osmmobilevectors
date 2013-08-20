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

    NSArray *lines = [vecs splitVectors];
    for (MaplyVectorObject *line in lines)
    {
        MaplyCoordinate middle;
        float rot;
        if ([line linearMiddle:&middle rot:&rot])
        {
            // Note: Tried to restrict the label to this tile, didn't work
//            if (tileLL.x <= middle.x && tileLL.y <= middle.y &&
//                middle.x < tileUR.x && middle.y < tileUR.y)
            {
                MaplyScreenLabel *label = [[MaplyScreenLabel alloc] init];
                label.loc = middle;
                label.text = line.attributes[@"name"];
                label.selectable = false;
                label.layoutImportance = 1.0;
                label.layoutPlacement = kMaplyLayoutRight;
                label.rotation = rot+M_PI/2.0;
                // Keep the labels upright
                if (label.rotation > M_PI/2 && label.rotation < 3*M_PI/2)
                    label.rotation = label.rotation + M_PI;

                // Change the size and color depending on the type 
                NSString *highway = line.attributes[@"highway"];
                UIColor *textColor = [UIColor blackColor];
                UIColor *outlineColor = nil;
                UIFont *textFont = [UIFont systemFontOfSize:14.0];
                if (!highway)
                {
                } else if (![highway compare:@"primary"])
                {
                    textColor = [UIColor whiteColor];
                    outlineColor = [UIColor blackColor];
                    textFont = [UIFont boldSystemFontOfSize:18.0];
                } else if (![highway compare:@"secondary"])
                {
                    textColor = [UIColor whiteColor];
                    textFont = [UIFont systemFontOfSize:16.0];
                    outlineColor = [UIColor blackColor];
                } else if (![highway compare:@"tertiary"])
                {
                    textColor = [UIColor blackColor];
                    textFont = [UIFont boldSystemFontOfSize:14.0];
                    outlineColor = [UIColor whiteColor];
                }
                
                if (label.text)
                {
                    NSMutableDictionary *desc = [NSMutableDictionary dictionaryWithDictionary:
                                                 @{kMaplyTextColor: textColor,
                                                  kMaplyEnable: @(NO),
                                                  kMaplyFont: textFont
                                                 }];
                    if (outlineColor)
                    {
                        desc[kMaplyTextOutlineColor] = outlineColor;
                        desc[kMaplyTextOutlineSize] = @(1.0);
                    }
                    // Adding these one by one is a bit slow
                    MaplyComponentObject *compObj = [viewC addScreenLabels:@[label] desc:desc];
                    if (compObj)
                        [compObjs addObject:compObj];                    
                }
            }
        }
    }
    
    if ([compObjs count] == 0)
        return nil;
    
    return compObjs;
}

@end
