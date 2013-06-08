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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int numLayers = 0;
    switch (section)
    {
        case 0:
            numLayers = 5;
            break;
        case 1:
            numLayers = 8;
            break;
    }
    return numLayers;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    
    switch (section)
    {
        case 0:
            title = @"Demo";
            break;
        case 1:
            title = @"Testing";
            break;
    }
    
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    switch (indexPath.section)
    {
        case 0:
            switch (indexPath.row)
            {
                case 0:
                    cell.textLabel.text = @"Roads - Single Resolution";
                    break;
                case 1:
                    cell.textLabel.text = @"Roads - Multiple Resolution";
                    break;
                case 2:
                    cell.textLabel.text = @"Base Map + Multiple Layers";
                    break;
                case 3:
                    cell.textLabel.text = @"Base Map + Multiple Layers + Labels";
                    break;
                case 4:
                    cell.textLabel.text = @"Pure Vector Map";
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row)
            {
                case 0:
                    cell.textLabel.text = @"Paging Test";
                    break;
                case 1:
                    cell.textLabel.text = @"Water Test";
                    break;
                case 2:
                    cell.textLabel.text = @"Base Map Only";
                    break;
                case 3:
                    cell.textLabel.text = @"Roads Only";
                    break;
                case 4:
                    cell.textLabel.text = @"Road Labels Only";
                    break;
                case 5:
                    cell.textLabel.text = @"Water Only";
                    break;
                case 6:
                    cell.textLabel.text = @"Land Use Only";
                    break;
                case 7:
                    cell.textLabel.text = @"Buildings Only";
                    break;
            }
            break;
    }
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor grayColor];
    
    return cell;
}

#pragma mark - Table Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TestViewController *viewC = [[TestViewController alloc] initWithMapType:MapGlobe  baseLayer:DefaultLayer];
    
    switch (indexPath.section)
    {
        case 0:
            switch (indexPath.row)
            {
                case 0:
                    viewC.title = @"OSM Roads - Single Res";
                    viewC.settings = @{kOSMRoadLayer:
                                           @{kOSMLayerMin: @(15),
                                             kOSMLayerMax: @(15)}
                                       };
                    break;
                case 1:
                    viewC.title = @"OSM Roads - Multi Res";
                    viewC.settings = @{kOSMRoadLayer:
                                           @{kOSMLayerMin: @(0),
                                             kOSMLayerMax: @(17)}
                                       };
                    break;
                case 2:
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
                case 3:
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
                                             kOSMLayerMax: @(18)}
                                       };
                    break;
                case 4:
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
                                             kOSMLayerMax: @(14)}
                                       };
                    break;
            }
            break;
        case 1:
            switch (indexPath.row)
            {
                case 0:
                    viewC.title = @"Paging Test";
                    viewC.settings = @{kOSMRoadLayer:
                                           @{kOSMLayerMin: @(15),
                                             kOSMLayerMax: @(16)}
                                       };
                    break;
                case 1:
                    viewC.title = @"Water Test";
                    viewC.settings = @{kOSMWaterLayer:
                                           @{kOSMLayerMin: @(14),
                                             kOSMLayerMax: @(14)}
                                       };
                    break;
                case 2:
                    viewC.title = @"Base Map Only";
                    viewC.settings = @{kOSMBaseLayer: @(YES)
                                       };
                    break;
                case 3:
                    viewC.title = @"Roads Only";
                    viewC.settings = @{kOSMRoadLayer:
                                           @{kOSMLayerMin: @(0),
                                             kOSMLayerMax: @(17)}
                                       };
                    break;
                case 4:
                    viewC.title = @"Road Labels Only";
                    viewC.settings = @{kOSMRoadLabelLayer:
                                           @{kOSMLayerMin: @(0),
                                             kOSMLayerMax: @(17)}
                                       };
                    break;
                case 5:
                    viewC.title = @"Water Only";
                    viewC.settings = @{kOSMWaterLayer:
                                           @{kOSMLayerMin: @(14),
                                             kOSMLayerMax: @(14)}
                                       };
                    break;
                case 6:
                    viewC.title = @"Land Use Only";
                    viewC.settings = @{kOSMLandLayer:
                                           @{kOSMLayerMin: @(14),
                                             kOSMLayerMax: @(14)}
                                       };
                    break;
                case 7:
                    viewC.title = @"Buildings Only";
                    viewC.settings = @{kOSMBuildingLayer:
                                           @{kOSMLayerMin: @(15),
                                             kOSMLayerMax: @(18)}
                                       };
                    break;
            }
            break;
    }
    
    [self.navigationController pushViewController:viewC animated:YES];
}

@end
