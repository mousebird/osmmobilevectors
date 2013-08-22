//
//  OSMLandTileSource.m
//  OSMTestApp
//
//  Created by Steve Gifford on 5/31/13.
//  Copyright (c) 2013 mousebird consulting. All rights reserved.
//

#import "OSMLandTileSource.h"

@interface LandStyle : NSObject

- (id)initWithOutline:(UIColor *)outlineColor fillColor:(UIColor *)fillColor;

@property UIColor *outlineColor;
@property UIColor *fillColor;
@end

@implementation LandStyle

- (id)initWithOutline:(UIColor *)outlineColor fillColor:(UIColor *)fillColor
{
    self = [super init];
    _outlineColor = outlineColor;
    _fillColor = fillColor;
    
    return self;
}

@end

@implementation OSMLandTileSource
{
    NSDictionary *landStyles;
}

- (id)initWithFeatureName:(NSString *)featureName;
{
    self = [super initWithFeatureName:featureName];
    if (!self)
        return nil;
    
    float alpha = 0.25;
    UIColor *green = [UIColor colorWithRed:111/255.0*alpha green:224/255.0*alpha blue:136/255.0*alpha alpha:alpha];
    UIColor *darkGreen = [UIColor colorWithRed:111/255.0 green:224/255.0 blue:136/255.0 alpha:alpha];
//    UIColor *darkGreenOutline = [UIColor colorWithRed:111/255.0*0.25 green:224/255.0*0.25 blue:136/255.0*.25 alpha:1.0];
    UIColor *tan = [UIColor colorWithRed:210/255.0*alpha green:180/255.0*alpha blue:140/255.0*alpha alpha:alpha];
//    UIColor *tanOutline = [UIColor colorWithRed:210/255.0 green:180/255.0 blue:140/255.0 alpha:1.0];
    UIColor *gray = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    UIColor *grayer = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    UIColor *grayest = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
//    UIColor *black = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25];
    landStyles =
    @{ 
       @"scrub": [[LandStyle alloc] initWithOutline:nil fillColor:green],
       @"park": [[LandStyle alloc] initWithOutline:nil fillColor:green],
       @"school" : [[LandStyle alloc] initWithOutline:nil fillColor:gray],
       @"meadow": [[LandStyle alloc] initWithOutline:nil fillColor:tan],
       @"nature_reserve" : [[LandStyle alloc] initWithOutline:nil fillColor:green],
       @"garden": [[LandStyle alloc] initWithOutline:nil fillColor:green],
       @"pitch" : [[LandStyle alloc] initWithOutline:nil fillColor:green],
       @"wood" : [[LandStyle alloc] initWithOutline:nil fillColor:darkGreen],
       @"farm" : [[LandStyle alloc] initWithOutline:nil fillColor:tan],
       @"farmyard" : [[LandStyle alloc] initWithOutline:nil fillColor:tan],
       @"recreation_ground" : [[LandStyle alloc] initWithOutline:nil fillColor:green],
       @"commercial": [[LandStyle alloc] initWithOutline:nil fillColor:grayer],
       @"residential": [[LandStyle alloc] initWithOutline:nil fillColor:gray],
       @"industrial": [[LandStyle alloc] initWithOutline:nil fillColor:grayest],
       @"common" : [[LandStyle alloc] initWithOutline:nil fillColor:gray],
       @"parking": [[LandStyle alloc] initWithOutline:nil fillColor:gray],
       @"default": [[LandStyle alloc] initWithOutline:nil fillColor:gray]
       };
    
    return self;
}

- (NSMutableArray *)addFeatures:(MaplyVectorObject *)vecs toView:(MaplyBaseViewController *)viewC forTile:(MaplyTileID)tileID inLayer:(MaplyQuadPagingLayer *)layer
{
    NSMutableArray *compObjs = [NSMutableArray array];
    
    // Work through the features, categorizing as we go
    NSMutableDictionary *sortedFeatures = [NSMutableDictionary dictionary];
    NSArray *feats = [vecs splitVectors];
    if ([feats count] == 0)
        return nil;
    
    for (MaplyVectorObject *vec in feats)
    {
        NSString *kind = vec.attributes[@"kind"];
        if (kind)
        {
            NSMutableArray *theseVecs = sortedFeatures[kind];
            bool added = false;
            if (!theseVecs)
            {
                theseVecs = [NSMutableArray array];
                added = true;
            }
            [theseVecs addObject:vec];
            if (added)
                sortedFeatures[kind] = theseVecs;
        }
    }
    
    // They're sorted now, so add them as groups
    LandStyle *defaultStyle = landStyles[@"default"];
    for (NSString *kind in [sortedFeatures allKeys])
    {
        LandStyle *theStyle = landStyles[kind];
        if (!theStyle)
            theStyle = defaultStyle;

        // Do the filled representation
        if (theStyle.fillColor)
        {
            NSMutableArray *tris = [NSMutableArray array];
            // We'll tesselate these here rather than make the layer thread do it
            for (MaplyVectorObject *vec in sortedFeatures[kind])
            {
                MaplyVectorObject *theseTris = [vec tesselate];
                if (theseTris)
                    [tris addObject:theseTris];
            }
            
            MaplyComponentObject *compObj = [viewC addVectors:tris desc:
                                             @{kMaplyColor: theStyle.fillColor,
                                           kMaplyDrawPriority: @(100),
                                                   kMaplyFade: @(self.fade),
                                                 kMaplyEnable: @(NO),
                                                 kMaplyFilled: @(YES)
                                     }];
            if (compObj)
                [compObjs addObject:compObj];
        }
        
        // And an optional outline
        if (theStyle.outlineColor)
        {
            NSArray *theseVecs = sortedFeatures[kind];
            
            MaplyComponentObject *compObj = [viewC addVectors:theseVecs desc:
                                             @{kMaplyColor: theStyle.outlineColor,
                                           kMaplyDrawPriority: @(101),
                                                   kMaplyFade: @(self.fade),
                                                 kMaplyEnable: @(NO),
                                             }];
            if (compObj)
                [compObjs addObject:compObj];            
        }
    }
    
    return compObjs;
}

@end
