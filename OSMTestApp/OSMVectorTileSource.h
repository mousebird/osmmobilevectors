//
//  OSMVectorTileSource.h
//  OSMTestApp
//
//  Created by Steve Gifford on 5/23/13.
//  Copyright (c) 2013 mousebird consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MaplyComponent.h"

/** The OSM Vector Tile Source is handed to a MaplyQuadPaging layer.
    It will then be queried to load and/or construct data per tile.
    We subclass this to do the actual feature creation.
  */
@interface OSMVectorTileSource : NSObject <MaplyPagingDelegate>

/// Local cache dir for the exclusive use of the vector tile source
@property (nonatomic) NSString *cacheDir;

/// Time to fade features in/out
@property (nonatomic,assign) float fade;

/// Amount to scale line widths (presumably to compensate for retina)
@property (nonatomic,assign) float scale;

@property (nonatomic,readonly) NSString *featureName;
@property (nonatomic,readonly) NSString *remotePath;

/// Create with a feature name (e.g. roads) for identifying the 
- (id)initWithFeatureName:(NSString *)featureName path:(NSString *)remotePath minZoom:(int)minZoom maxZoom:(int)maxZoom;

/// Override this to construct features for display
- (NSMutableArray *)addFeatures:(MaplyVectorObject *)vecs toView:(MaplyBaseViewController *)viewC forTile:(MaplyTileID)tileID inLayer:(MaplyQuadPagingLayer *)layer;

@end
