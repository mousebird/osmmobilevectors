/*
 *  TestViewController.m
 *  WhirlyGlobeComponentTester
 *
 *  Created by Steve Gifford on 7/23/12.
 *  Copyright 2011-2012 mousebird consulting
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

#import <QuartzCore/QuartzCore.h>
#import "TestViewController.h"
#import "AFJSONRequestOperation.h"
#import "OSMVectorTileSource.h"
#import "OSMRoadTileSource.h"
#import "OSMLandTileSource.h"
#import "OSMWaterTileSource.h"
#import "OSMBuildingTileSource.h"

// Local interface for TestViewController
// We'll hide a few things here
@interface TestViewController ()
{
}

@end

@implementation TestViewController
{
    MapType startupMapType;
    BaseLayer startupLayer;
}

- (id)initWithMapType:(MapType)mapType baseLayer:(BaseLayer)baseLayer
{
    self = [super init];
    if (self) {
        startupMapType = mapType;
        startupLayer = baseLayer;
    }
    return self;
}

- (void)dealloc
{
    // This should release the globe view
    if (baseViewC)
    {
        [baseViewC.view removeFromSuperview];
        [baseViewC removeFromParentViewController];
        baseViewC = nil;
    }    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create an empty globe or map controller
    if (startupMapType == MapGlobe)
    {
        globeViewC = [[WhirlyGlobeViewController alloc] init];
        globeViewC.delegate = self;
        baseViewC = globeViewC;
    } else {
        mapViewC = [[MaplyViewController alloc] init];
        mapViewC.delegate = self;
        baseViewC = mapViewC;
    }
    [self.view addSubview:baseViewC.view];
    baseViewC.view.frame = self.view.bounds;
    [self addChildViewController:baseViewC];
    
    // Set the background color for the globe
    baseViewC.clearColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
    
    // This will get us taps and such
    if (globeViewC)
    {
        // Start up over San Francisco
        globeViewC.height = 0.005;
        [globeViewC animateToPosition:MaplyCoordinateMakeWithDegrees(-122.4192, 37.7793) time:1.0];
        [globeViewC setHints:@{kMaplyRenderHintZBuffer: @(NO)}];
    } else {
        mapViewC.height = 1.0;
        [mapViewC animateToPosition:MaplyCoordinateMakeWithDegrees(-122.4192, 37.7793) time:1.0];
    }

    self.title = @"OpenStreetMap Vectors";
    
    // For network paging layers, where we'll store temp files
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)  objectAtIndex:0];
    NSString *jsonTileSpec = nil;
    NSString *thisCacheDir = nil;
//    jsonTileSpec = @"http://a.tiles.mapbox.com/v3/examples.map-zyt2v9k2.json";
//    thisCacheDir = [NSString stringWithFormat:@"%@/mbtilessat/",cacheDir];

    // Fill out the cache dir if there is one
    if (thisCacheDir)
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:thisCacheDir withIntermediateDirectories:YES attributes:nil error:&error];        
    }
    
    // If we're fetching one of the JSON tile specs, kick that off
    if (jsonTileSpec)
    {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:jsonTileSpec]];
        [request setTimeoutInterval:15];
        
        AFJSONRequestOperation *operation =
        [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
        {
            // Add a quad earth paging layer based on the tile spec we just fetched
            MaplyQuadEarthWithRemoteTiles *layer = [[MaplyQuadEarthWithRemoteTiles alloc] initWithTilespec:JSON];
            layer.handleEdges = false;
            layer.cacheDir = thisCacheDir;
            [baseViewC addLayer:layer];
        }
                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
        {
            NSLog(@"Failed to reach JSON tile spec at: %@",jsonTileSpec);
        }
         ];
        
        [operation start];
    } else {
        // Let's load a specific base layer instead
        MaplyQuadEarthWithRemoteTiles *layer = [[MaplyQuadEarthWithRemoteTiles alloc] initWithBaseURL:@"http://a.tiles.mapbox.com/v3/mousebird.map-2ebn78d1/" ext:@"png" minZoom:0 maxZoom:19];
        [baseViewC addLayer:layer];
    }
    
    // Cache directory for vector data
    NSError *error = nil;
    NSString *tileCacheDir = [NSString stringWithFormat:@"%@/tileCache/",cacheDir];
    [[NSFileManager defaultManager] createDirectoryAtPath:tileCacheDir withIntermediateDirectories:YES attributes:nil error:&error];
    
    // Add a layer to do the OSM data
    MaplyCoordinateSystem *coordSys = [[MaplySphericalMercator alloc] initWebStandard];

    OSMRoadTileSource *roadSource = [[OSMRoadTileSource alloc] initWithFeatureName:@"highroad" path:@"http://tile.openstreetmap.us/vectiles-highroad/" minZoom:0 maxZoom:17];
    roadSource.cacheDir = tileCacheDir;
    MaplyQuadPagingLayer *osmRoadLayer = [[MaplyQuadPagingLayer alloc] initWithCoordSystem:coordSys delegate:roadSource];
    [baseViewC addLayer:osmRoadLayer];
    
    OSMBuildingTileSource *buildingSource = [[OSMBuildingTileSource alloc] initWithFeatureName:@"building" path:@"http://tile.openstreetmap.us/vectiles-buildings/" minZoom:15 maxZoom:18];
    buildingSource.cacheDir = tileCacheDir;
    MaplyQuadPagingLayer *osmBuildingLayer = [[MaplyQuadPagingLayer alloc] initWithCoordSystem:coordSys delegate:buildingSource];
    [baseViewC addLayer:osmBuildingLayer];    
    
//    OSMVectorTileSource *landDelegate = [[OSMVectorTileSource alloc] initWithMinZoom:11 maxZoom:18];
//    landDelegate.cacheDir = landCacheDir;
//    [landDelegate setPath:@"http://tile.openstreetmap.us/vectiles-land-usages/" minZoom:0 maxzoom:18 forFeature:OSMLandUse];
//    MaplyQuadPagingLayer *osmLandLayer = [[MaplyQuadPagingLayer alloc] initWithCoordSystem:coordSys delegate:landDelegate];
//    [baseViewC addLayer:osmLandLayer];

//    OSMVectorTileSource *waterDelegate = [[OSMVectorTileSource alloc] initWithMinZoom:0 maxZoom:18];
//    waterDelegate.cacheDir = waterCacheDir;
//    [waterDelegate setPath:@"http://tile.openstreetmap.us/vectiles-water-areas/" minZoom:11 maxzoom:18 forFeature:OSMWater];
//    MaplyQuadPagingLayer *osmWaterLayer = [[MaplyQuadPagingLayer alloc] initWithCoordSystem:coordSys delegate:waterDelegate];
//    [baseViewC addLayer:osmWaterLayer];
    
//    [fetchingDelegate setPath:@"http://tile.openstreetmap.us/vectiles-skeletron/" minZoom:0 maxzoom:16 forFeature:OSMRoadLabel];
//    [fetchingDelegate setPath:@"http://tile.openstreetmap.us/vectiles-land-usages/" forFeature:OSMLandUse];
//    [fetchingDelegate setPath:@"http://tile.openstreetmap.us/vectiles-water-areas/" forFeature:OSMWater];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // This should release the globe view
    if (baseViewC)
    {
        [baseViewC.view removeFromSuperview];
        [baseViewC removeFromParentViewController];
        baseViewC = nil;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Whirly Globe Delegate

// Build a simple selection view to draw over top of the globe
- (UIView *)makeSelectionView:(NSString *)msg
{
    float fontSize = 32.0;
    float marginX = 32.0;
    
    // Make a label and stick it in as a view to track
    // We put it in a top level view so we can center it
    UIView *topView = [[UIView alloc] initWithFrame:CGRectZero];
    // Start out hidden before the first placement.  The tracker will turn it on.
    topView.hidden = YES;
    topView.alpha = 0.8;
    UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
    [topView addSubview:backView];
    topView.clipsToBounds = NO;
    UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [backView addSubview:testLabel];
    testLabel.font = [UIFont systemFontOfSize:fontSize];
    testLabel.textColor = [UIColor whiteColor];
    testLabel.backgroundColor = [UIColor clearColor];
    testLabel.text = msg;
    CGSize textSize = [testLabel.text sizeWithFont:testLabel.font];
    testLabel.frame = CGRectMake(marginX/2.0,0,textSize.width,textSize.height);
    testLabel.opaque = NO;
    backView.layer.cornerRadius = 5.0;
    backView.backgroundColor = [UIColor colorWithRed:0.0 green:102/255.0 blue:204/255.0 alpha:1.0];
    backView.frame = CGRectMake(-(textSize.width)/2.0,-(textSize.height)/2.0,textSize.width+marginX,textSize.height);
    
    return topView;
}

@end
