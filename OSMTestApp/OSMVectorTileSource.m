//
//  OSMVectorTileSource.m
//  OSMTestApp
//
//  Created by Steve Gifford on 5/23/13.
//  Copyright (c) 2013 mousebird consulting. All rights reserved.
//

#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "OSMVectorTileSource.h"

// We use this to track what we've loaded for a given tile as we're loading it.
@interface OSMTileTracker : NSObject
{
@public
    // Number of things we're fetching at once
    int numFetches;
}
@end

@implementation OSMTileTracker
@end

@implementation OSMVectorTileSource
{
    int minValidZoom,maxValidZoom;
}

- (id)initWithFeatureName:(NSString *)featureName path:(NSString *)remotePath minZoom:(int)minZoom maxZoom:(int)maxZoom
{
    self = [super init];

    _featureName = featureName;
    _remotePath = remotePath;
    minValidZoom = minZoom;
    maxValidZoom = maxZoom;
    _fade = 0.5;
    _scale = [UIScreen mainScreen].scale;
    
    return self;
}

- (int)minZoom
{
    return 0;
}

- (int)maxZoom
{
    return maxValidZoom;
}

- (void)startFetchForTile:(MaplyTileID)tileID forLayer:(MaplyQuadPagingLayer *)layer
{
    // Leave anything below what we care about empty
    if (tileID.level < minValidZoom)
    {
        [layer tileDidLoad:tileID];
        return;
    }
    
    // Note: Debugging
    if (false)
    {
        MaplyCoordinate pts[4];
        [layer geoBoundsforTile:tileID ll:&pts[0] ur:&pts[2]];
        pts[3].x = pts[2].x;
        pts[3].y = pts[0].y;
        pts[1].x = pts[0].x;
        pts[1].y = pts[2].y;
        MaplyVectorObject *vec = [[MaplyVectorObject alloc] initWithAreal:pts numCoords:4 attributes:nil];
        MaplyComponentObject *compObj = [layer.viewC addVectors:@[vec] desc:@{kMaplyColor: [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.1], kMaplyFilled: @(YES)}];
//        MaplyComponentObject *compObj = [layer.viewC addLoftedPolys:@[vec] key:nil cache:nil desc:@{kMaplyColor: [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.1], kMaplyLoftedPolyHeight: @(0.0)}];
        if (compObj)
            [layer addData:@[compObj] forTile:tileID];
        MaplyScreenLabel *label = [[MaplyScreenLabel alloc] init];
        MaplyCoordinate center;
        center.x = (pts[0].x + pts[2].x)/2.0;
        center.y = (pts[0].y + pts[2].y)/2.0;
        label.loc = center;
        label.text = [NSString stringWithFormat:@"%d_%d_%d",tileID.level,tileID.x,tileID.y];
        label.color = [UIColor blackColor];
        label.size = CGSizeMake(100.0, 40.0);
        compObj = [layer.viewC addScreenLabels:@[label] desc:@{kMaplyMinVis: @(0.0), kMaplyMaxVis: @(1000.0)}];
        if (compObj)
            [layer addData:@[compObj] forTile:tileID];

//        [layer tileDidLoad:tileID];
//        return;
    }

    // Note: Move this logic into the layer
    int maxY = 1<<tileID.level;
    
    // Kick off an async fetch for the tile data
    {
        if (!(_remotePath && tileID.level >= minValidZoom && tileID.level <= maxValidZoom))
        {
            [layer tileDidLoad:tileID];
            return;
        }
        
        // Look for it in the cache first
        NSString *cacheFile = nil;
        bool wasCached = false;
        if (_cacheDir)
        {
            cacheFile = [NSString stringWithFormat:@"%@/%@_%d_%d_%d.json",_cacheDir,_featureName,tileID.level,tileID.x,tileID.y];
            if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFile])
            {
                wasCached = true;
//                NSLog(@"Cached: %@",cacheFile);
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                               ^{
                                   NSData *jsonData = [NSData dataWithContentsOfFile:cacheFile];
                                   
                                    MaplyVectorObject *vecs = [MaplyVectorObject VectorObjectFromGeoJSON:jsonData];
                                    NSArray *compObjs = [self addFeatures:vecs toView:layer.viewC forTile:tileID inLayer:layer];
                                    if (compObjs)
                                    {
                                        [layer addData:compObjs forTile:tileID];
                                    }
                                   [layer tileDidLoad:tileID];
                               });
            }
        }
        
        if (!wasCached)
        {
            // Construct the full URL
            NSString *fullUrl = [NSString stringWithFormat:@"%@/%d/%d/%d.json",_remotePath,tileID.level,tileID.x,maxY - tileID.y - 1];
            
//            NSLog(@"Fetching: %@",cacheFile);

            // Kick off the request for the geojson
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:fullUrl]];
            AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                ^{
                    NSDictionary *jsonDict = (NSDictionary *) JSON;
                    MaplyVectorObject *vecs = [MaplyVectorObject VectorObjectFromGeoJSONDictionary:jsonDict];
                    
                    // Cache it
                    if (cacheFile && vecs)
                    {
                        NSError *error = nil;
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
                        if (![jsonData writeToFile:cacheFile atomically:NO])
                            NSLog(@"Failed to write file: %@",cacheFile);
                    }
                    
                    NSArray *compObjs = [self addFeatures:vecs toView:layer.viewC forTile:tileID inLayer:layer];
                    if (compObjs)
                        [layer addData:compObjs forTile:tileID];
                    [layer tileDidLoad:tileID];
                });
            }
                                                failure:^(NSURLRequest *request, NSHTTPURLResponse *response,
                        NSError *error, id JSON)
            {
                NSLog(@"Request Failure Because %@",[error userInfo]);
                // Note: This allows a partial load.  Not entirely right.
                [layer tileDidLoad:tileID];
            }
            ];
            
            [operation start];
        }
    }
}

- (NSMutableArray *)addFeatures:(MaplyVectorObject *)vecs toView:(MaplyBaseViewController *)viewC forTile:(MaplyTileID)tileID inLayer:(MaplyQuadPagingLayer *)layer
{
    return nil;
}

@end
