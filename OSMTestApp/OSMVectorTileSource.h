//
//  OSMVectorTileSource.h
//  OSMTestApp
//
//  Created by Steve Gifford on 5/23/13.
//  Copyright (c) 2013 mousebird consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MaplyComponent.h"

/// Subclass this and register your object to parse a
///  certain class of OSM vector data
@interface OSMVectorCategory : NSObject

/// Construct with the feature name we'll use to identify the pieces of GeoJSON we want
- (id)initWithFeatureName:(NSString *)featureName;

/// Name of the feature category (what we'll see in the JSON)
@property(nonatomic,readonly) NSString *featureName;

/// Time to fade features in/out
@property (nonatomic,assign) float fade;

/// Amount to scale line widths (presumably to compensate for retina)
@property (nonatomic,assign) float scale;

/// Construct features for display and return them (disabled)
- (NSMutableArray *)addFeatures:(MaplyVectorObject *)vecs toView:(MaplyBaseViewController *)viewC forTile:(MaplyTileID)tileID inLayer:(MaplyQuadPagingLayer *)layer;

@end

/** The OSM Vector Tile Source is handed to a MaplyQuadPaging layer.
    It will then be queried to load and/or construct data per tile.
    We subclass this to do the actual feature creation.
  */
@interface OSMVectorTileSource : NSObject <MaplyPagingDelegate>

/// Local cache dir for the exclusive use of the vector tile source
@property (nonatomic) NSString *cacheDir;

/// Remove path we're fetching combined tiles from
@property (nonatomic,readonly) NSString *remotePath;

/// Create with a remote path and min/max zoom levels to roam
- (id)initWithPath:(NSString *)remotePath minZoom:(int)minZoom maxZoom:(int)maxZoom;

/// Add a category for a particular type of data
- (void)addCategory:(OSMVectorCategory *)category;

@end
