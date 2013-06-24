//
//  OSMRoadTileSource.m
//  OSMTestApp
//
//  Created by Steve Gifford on 5/31/13.
//  Copyright (c) 2013 mousebird consulting. All rights reserved.
//

#import "OSMRoadTileSource.h"

@implementation OSMRoadTileSource

typedef enum {Highway,MajorRoad,MinorRoad,Rail,Path,Unknown,RoadKindMax} RoadKind;

// Simple style definition
typedef struct
{
    bool twoLines;
    float width;
    int red,green,blue;
    int priority;
} RoadStyle;

// Simple style definitions for the roads types
static RoadStyle RoadStyles[RoadKindMax] =
{
    {true,10.0,204,141,4,400},
    {true,6.0,239,237,88,402},
    {false,2.0,64,64,64,404},
    {true,6.0,100,100,100,406},
    {false,1.0,64,64,64,408}
};

- (NSMutableArray *)addFeatures:(MaplyVectorObject *)vecs toView:(MaplyBaseViewController *)viewC forTile:(MaplyTileID)tileID inLayer:(MaplyQuadPagingLayer *)layer
{
    NSMutableArray *compObjs = [NSMutableArray array];

    // Work through the vectors, sorting as we go
    NSMutableArray *groups[RoadKindMax];
    for (unsigned int ii=0;ii<RoadKindMax;ii++)
        groups[ii] = [NSMutableArray array];
    
    NSArray *roads = [vecs splitVectors];
    for (MaplyVectorObject *vecObj in roads)
    {
        NSDictionary *attrs = vecObj.attributes;
        NSString *kind = attrs[@"kind"];
        // Note: Testing
//        kind = @"path";
        if (!kind)
        {
            [groups[Unknown] addObject:vecObj];
        } else if (![kind compare:@"highway"])
        {
            [groups[Highway] addObject:vecObj];
        } else if (![kind compare:@"major_road"])
        {
            [groups[MajorRoad] addObject:vecObj];
        } else if (![kind compare:@"minor_road"])
        {
            [groups[MinorRoad] addObject:vecObj];
        } else if (![kind compare:@"rail"])
        {
            [groups[Rail] addObject:vecObj];
        } else if (![kind compare:@"path"])
        {
            [groups[Path] addObject:vecObj];
        } else {
            [groups[Unknown] addObject:vecObj];
        }
    }
    
    // Create the roads with their styles
    for (unsigned int ii=0;ii<RoadKindMax;ii++)
    {
        NSArray *theRoads = groups[ii];
        if ([theRoads count] > 0)
        {
            const RoadStyle *style = &RoadStyles[ii];
            // Add a road bed underneath the line
            if (style->twoLines)
            {
                MaplyComponentObject *compObj =
                [viewC addVectors:theRoads desc:
                 @{kMaplyColor: [UIColor colorWithRed:style->red/255.0/2.0 green:style->green/255.0/2.0 blue:style->blue/255.0/2.0 alpha:1.0],
                 kMaplyDrawOffset: @(0),
               kMaplyDrawPriority: @(style->priority),
                   kMaplyVecWidth: @(style->width*self.scale),
                       kMaplyFade: @(self.fade),
                     kMaplyEnable: @(NO)}
                 ];
                if (compObj)
                    [compObjs addObject:compObj];
                
                compObj =
                [viewC addVectors:theRoads desc:
                 @{kMaplyColor: [UIColor colorWithRed:style->red/255.0 green:style->green/255.0 blue:style->blue/255.0 alpha:1.0],
                 kMaplyDrawOffset: @(0),
               kMaplyDrawPriority: @(style->priority+1),
                   kMaplyVecWidth: @((style->width-1.0)*self.scale),
                       kMaplyFade: @(self.fade),
                     kMaplyEnable: @(NO)}
                 ];
                if (compObj)
                    [compObjs addObject:compObj];                
            } else {
                // Just the one line
                MaplyComponentObject *compObj =
                [viewC addVectors:theRoads desc:
                 @{kMaplyColor: [UIColor colorWithRed:style->red/255.0 green:style->green/255.0 blue:style->blue/255.0 alpha:1.0],
                 kMaplyDrawOffset: @(0),
               kMaplyDrawPriority: @(style->priority),
                   kMaplyVecWidth: @(style->width*self.scale),
                       kMaplyFade: @(self.fade),
                     kMaplyEnable: @(NO)}
                 ];
                if (compObj)
                    [compObjs addObject:compObj];
            }
        }
    }
        
    return compObjs;
}

@end
