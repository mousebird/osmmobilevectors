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

@implementation OSMVectorCategory

- (id)initWithFeatureName:(NSString *)inFeatureName
{
    self = [super init];
    if (!self)
        return nil;
    _featureName = inFeatureName;
    _fade = 0.5;
    _scale = [UIScreen mainScreen].scale;
    
    return self;
}

- (NSMutableArray *)addFeatures:(MaplyVectorObject *)vecs toView:(MaplyBaseViewController *)viewC forTile:(MaplyTileID)tileID inLayer:(MaplyQuadPagingLayer *)layer
{
    return nil;
}

@end

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
    NSMutableDictionary *categories;
}

- (id)initWithPath:(NSString *)remotePath minZoom:(int)minZoom maxZoom:(int)maxZoom
{
    self = [super init];

    _remotePath = remotePath;
    minValidZoom = minZoom;
    maxValidZoom = maxZoom;
    categories = [NSMutableDictionary dictionary];
    
    return self;
}

- (void)addCategory:(OSMVectorCategory *)category
{
    NSString *featureName = category.featureName;
    if (featureName)
        categories[featureName] = category;
}

- (int)minZoom
{
    return 0;
}

- (int)maxZoom
{
    return maxValidZoom;
}

- (bool)parseGeoJSONAssembly:(NSData *)jsonData forTile:(MaplyTileID)tileID forLayer:(MaplyQuadPagingLayer *)layer
{
    // The data we get back from OSM is in an odd concatenated form, basically a dictionary
    //  of GeoJSON blobs.
    NSDictionary *topLevelVecs = [MaplyVectorObject VectorObjectsFromGeoJSONAssembly:jsonData];
    if (!topLevelVecs)
        return false;
    for (NSString *featureName in topLevelVecs.keyEnumerator)
    {
        OSMVectorCategory *category = categories[featureName];
        if (category)
        {
            NSArray *compObjs = [category addFeatures:topLevelVecs[featureName] toView:layer.viewC forTile:tileID inLayer:layer];
            if (compObjs)
                [layer addData:compObjs forTile:tileID style:MaplyDataStyleReplace];
        }
    }
    [layer tileDidLoad:tileID];
    
    return true;
}

- (void)startFetchForTile:(MaplyTileID)tileID forLayer:(MaplyQuadPagingLayer *)layer
{
    // Leave anything below what we care about empty
    if (tileID.level < minValidZoom)
    {
        [layer tileDidLoad:tileID];
        return;
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
            cacheFile = [NSString stringWithFormat:@"%@/%d_%d_%d.json",_cacheDir,tileID.level,tileID.x,tileID.y];
            if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFile])
            {
                wasCached = true;
//                NSLog(@"Cached: %@",cacheFile);
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                               ^{
                                   NSData *jsonData = [NSData dataWithContentsOfFile:cacheFile];
                                   [self parseGeoJSONAssembly:jsonData forTile:tileID forLayer:layer];
                               });
            }
        }
        
        if (!wasCached)
        {
            // Note: This ignore everything but vectors
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

            // Construct the full URL
            NSString *fullUrl = [NSString stringWithFormat:@"%@/%d/%d/%d.json",_remotePath,tileID.level,tileID.x,maxY - tileID.y - 1];
            
//            NSLog(@"Fetching: %@",cacheFile);

            // Kick off the request for the geojson
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:fullUrl]];
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            [operation
             setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
             {
                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                                ^{
                                    NSData *jsonData = responseObject;
                                    bool valid = [self parseGeoJSONAssembly:jsonData forTile:tileID forLayer:layer];
                                    
                                    // Cache it
                                    if (cacheFile && valid)
                                        [jsonData writeToFile:cacheFile atomically:YES];
                                });
                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error)
            {
                 NSLog(@"Request Failure Because %@",[error userInfo]);
                 // Note: This allows a partial load.  Not entirely right.
                 [layer tileDidLoad:tileID];

                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            }
             ];
            
            [operation start];
        }
    }
}

@end
