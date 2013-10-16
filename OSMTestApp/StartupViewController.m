/*
 *  StartupViewController.m
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

#import "StartupViewController.h"
#import "TestViewController.h"

@interface StartupViewController ()

@end

@implementation StartupViewController
{
    UITableView *tableView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Options";
    
    tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor grayColor];
    tableView.separatorColor = [UIColor whiteColor];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView];
    self.view.autoresizesSubviews = true;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    tableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [tableView reloadData];
}

#pragma mark - Table Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Demo and Testing
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int numLayers = 0;
    switch (section)
    {
        case 0:
            numLayers = 3;
            break;
//        case 1:
//            numLayers = 8;
//            break;
    }
    return numLayers;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSString *title = nil;
//    
//    switch (section)
//    {
//        case 0:
//            title = @"Demo";
//            break;
//        case 1:
//            title = @"Testing";
//            break;
//    }
//    
//    return title;
//}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return 84.0;
    else
        return 230.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
    } else {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:32.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:24.0];
    }
    cell.detailTextLabel.numberOfLines = 0;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (indexPath.section)
    {
        case 0:
            switch (indexPath.row)
            {
                case 0:
                    cell.imageView.image = [UIImage imageNamed:@"SampleVec+BaseMap.png"];
                    cell.textLabel.text = @"Base Map + Roads + Buildings";
                    cell.detailTextLabel.text = @"An image tile BaseMap from MapBox with vector roads and buildings from OSM.";
                    break;
                case 1:
                    cell.imageView.image = [UIImage imageNamed:@"SampleVec+Labels+BaseMap.png"];
                    cell.textLabel.text = @"Base Map, Roads, Buildings, Labels";
                    cell.detailTextLabel.text = @"An image tile BaseMap from MapBox with vector roads, road labels, buildings and place names from OSM.";
                    break;
                case 2:
                    cell.imageView.image = [UIImage imageNamed:@"SampleVecOnly.png"];
                    cell.textLabel.text = @"Pure Vector Map";
                    cell.detailTextLabel.text = @"All OSM vectors, including water, land use, roads, labels and place names.";
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.imageView.frame = CGRectMake(cell.imageView.frame.origin.x, cell.imageView.frame.origin.y, 128, 128);
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor grayColor];
    
    return cell;
}

#pragma mark - Table Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TestViewController *viewC = [[TestViewController alloc] initWithMapType:MapMap  baseLayer:DefaultLayer];
    
    switch (indexPath.section)
    {
        case 0:
            switch (indexPath.row)
            {
//                case 0:
//                    viewC.title = @"OSM Roads - Single Res";
//                    viewC.settings = @{kOSMRoadLayer:
//                                           @{kOSMLayerMin: @(15),
//                                             kOSMLayerMax: @(15)}
//                                       };
//                    break;
//                case 1:
//                    viewC.title = @"OSM Roads - Multi Res";
//                    viewC.settings = @{kOSMRoadLayer:
//                                           @{kOSMLayerMin: @(0),
//                                             kOSMLayerMax: @(17)}
//                                       };
//                    break;
                case 0:
                    viewC.title = @"Base Map + Roads + Buildings";
                    viewC.settings = @{kOSMBaseLayer: @(YES),
                                       kOSMRoadLayer:
                                           @{kOSMLayerMin: @(0),
                                             kOSMLayerMax: @(17)},
                                       kOSMBuildingLayer:
                                           @{kOSMLayerMin: @(15),
                                             kOSMLayerMax: @(18)}
                                       };
                    break;
                case 1:
                    viewC.title = @"Base Map + OSM Layers + Labels";
                    viewC.settings = @{kOSMBaseLayer: @(YES),
                                       kOSMRoadLayer:
                                           @{kOSMLayerMin: @(0),
                                             kOSMLayerMax: @(17)},
                                       kOSMRoadLabelLayer:
                                           @{kOSMLayerMin: @(0),
                                             kOSMLayerMax: @(17)},
                                       kOSMBuildingLayer:
                                           @{kOSMLayerMin: @(15),
                                             kOSMLayerMax: @(18)},
                                       kOSMPOILayer:
                                           @{kOSMLayerMin: @(0),
                                             kOSMLayerMax: @(21)}
                                       };
                    break;
                case 2:
                    viewC.title = @"Full OSM Vectors";
                    viewC.settings = @{kOSMBaseLayer: @(NO),
                                       kOSMRoadLayer:
                                           @{kOSMLayerMin: @(0),
                                             kOSMLayerMax: @(17)},
                                       kOSMRoadLabelLayer:
                                           @{kOSMLayerMin: @(0),
                                             kOSMLayerMax: @(17)},
                                       kOSMBuildingLayer:
                                           @{kOSMLayerMin: @(15),
                                             kOSMLayerMax: @(18)},
                                       kOSMLandLayer:
                                           @{kOSMLayerMin: @(14),
                                             kOSMLayerMax: @(14)},
                                       kOSMWaterLayer:
                                           @{kOSMLayerMin: @(14),
                                             kOSMLayerMax: @(14)},
                                       kOSMPOILayer:
                                           @{kOSMLayerMin: @(0),
                                             kOSMLayerMax: @(21)}
                                       };
                    break;
            }
            break;
//        case 1:
//            switch (indexPath.row)
//            {
//                case 0:
//                    viewC.title = @"Paging Test";
//                    viewC.settings = @{kOSMRoadLayer:
//                                           @{kOSMLayerMin: @(15),
//                                             kOSMLayerMax: @(16)}
//                                       };
//                    break;
//                case 1:
//                    viewC.title = @"Water Test";
//                    viewC.settings = @{kOSMWaterLayer:
//                                           @{kOSMLayerMin: @(14),
//                                             kOSMLayerMax: @(14)}
//                                       };
//                    break;
//                case 2:
//                    viewC.title = @"Base Map Only";
//                    viewC.settings = @{kOSMBaseLayer: @(YES)
//                                       };
//                    break;
//                case 3:
//                    viewC.title = @"Roads Only";
//                    viewC.settings = @{kOSMRoadLayer:
//                                           @{kOSMLayerMin: @(0),
//                                             kOSMLayerMax: @(17)}
//                                       };
//                    break;
//                case 4:
//                    viewC.title = @"Road Labels Only";
//                    viewC.settings = @{kOSMRoadLabelLayer:
//                                           @{kOSMLayerMin: @(0),
//                                             kOSMLayerMax: @(17)}
//                                       };
//                    break;
//                case 5:
//                    viewC.title = @"Water Only";
//                    viewC.settings = @{kOSMWaterLayer:
//                                           @{kOSMLayerMin: @(14),
//                                             kOSMLayerMax: @(14)}
//                                       };
//                    break;
//                case 6:
//                    viewC.title = @"Land Use Only";
//                    viewC.settings = @{kOSMLandLayer:
//                                           @{kOSMLayerMin: @(14),
//                                             kOSMLayerMax: @(14)}
//                                       };
//                    break;
//                case 7:
//                    viewC.title = @"Buildings Only";
//                    viewC.settings = @{kOSMBuildingLayer:
//                                           @{kOSMLayerMin: @(15),
//                                             kOSMLayerMax: @(18)}
//                                       };
//                    break;
//            }
//            break;
        default:
            break;
    }
    
    [self.navigationController pushViewController:viewC animated:YES];
}

@end
