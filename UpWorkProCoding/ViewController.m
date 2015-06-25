//
//  ViewController.m
//  UpWorkProCoding
//
//  Created by Kostiantyn Sokolinskyi on 6/25/15.
//  Copyright (c) 2015 SROST Studio. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "Foursquare2.h"
#import "MagicalRecord.h"

#import "ViewController.h"
#import "VenueEntity.h"
#import "VenueTableCell.h"
#import "DetailViewController.h"
#import "MBProgressHud.h"


NSString *const FS_CLIENT_ID = @"QG4PYA44EFO1BURJB2TMQEMMBCYW5QP3IP5SC3UZYAAIFJZN";
NSString *const FS_CLIENT_SECRET = @"0BL02KFJH55WFERUCAUYZDJU14QRARCAFIIOEUE0NEU5PU0B";

NSString *const kContextUpdatedNotification = @"kContextUpdatedNotification";
NSString *const kCellReuseIdentifier = @"kCellReuseIdentifier";


@interface ViewController () <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (atomic, assign) BOOL locationAcquired;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Foursquare2 setupFoursquareWithClientId: FS_CLIENT_ID
                                      secret: FS_CLIENT_SECRET
                                 callbackURL: @"no-callback"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"VenueTableCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kCellReuseIdentifier];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action: @selector(refreshLocation) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview: self.refreshControl];

    
    if (&UIApplicationWillEnterForegroundNotification)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    
    [self refreshLocationWithHud];
}

- (void)refreshLocation {
    [VenueEntity MR_truncateAll];
    self.locationAcquired = NO;
    [self requestLocation];
}

- (void)refreshLocationWithHud
{
    [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    [self refreshLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)requestLocation {

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
}

- (void)requestVenuesFromFoursquareWithLocation: (CLLocation*)location
{
    [Foursquare2 venueSearchNearByLatitude: [NSNumber numberWithFloat: location.coordinate.latitude]
                                 longitude: [NSNumber numberWithFloat: location.coordinate.longitude]
                                     query: @"pizza"
                                     limit: @5
                                    intent: intentBrowse
                                    radius: @5000
                                categoryId: nil
                                  callback: ^(BOOL success, id responseObject) {
                                      
                                      if ( success ) {
                                          NSArray *venuesArray = [NSArray arrayWithArray:responseObject[@"response"][@"venues"]];
                                          [self saveVenues: venuesArray];
                                      }
                                      else {
                                          [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Network Error", @"")
                                                                      message: NSLocalizedString(@"Something went wrong. Please try again in a minute and check your connection status.", @"")
                                                                     delegate: nil
                                                            cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                                            otherButtonTitles: nil] show];
                                          [self finishRefresh];
                                      }
                                  }];
}

- (void)saveVenues: (NSArray*)venuesArray
{
    if ([venuesArray count] == 0) {
        [self finishRefresh];
        return;
    }
    
    for (NSDictionary *venueDictionary in venuesArray) {
        
        VenueEntity *venueEntity = [VenueEntity MR_createEntity];
        [venueEntity MR_importValuesForKeysWithObject: venueDictionary];
        venueEntity.address = [venueDictionary[@"location"][@"formattedAddress"] componentsJoinedByString: @"\n"];
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfWithCompletion: ^(BOOL success, NSError *error) {
        NSLog(@"saved %ld venueEntity", [VenueEntity MR_countOfEntities]);
        [self finishRefresh];
    }];

}

- (void)finishRefresh
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kContextUpdatedNotification object:nil];
    [MBProgressHUD hideHUDForView: self.view animated: YES];
    [self.refreshControl endRefreshing];
}

- (void)applicationWillEnterForeground: (UIApplication *)application
{
    [self refreshLocationWithHud];
}


#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager*)manager didFailWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Location Error", @"")
                               message: error.localizedDescription
                              delegate: nil
                     cancelButtonTitle: NSLocalizedString(@"OK", @"")
                     otherButtonTitles: nil] show];
    [self finishRefresh];
}

- (void)locationManager:(CLLocationManager*)manager didUpdateLocations:(NSArray*)locations
{
    if ( !self.locationAcquired ) {
        
        CLLocation *location = [locations lastObject];
        NSLog(@"lat: %f - lon: %f", location.coordinate.latitude, location.coordinate.longitude);
        [manager stopUpdatingLocation];
        
        self.locationAcquired = YES;
        [self requestVenuesFromFoursquareWithLocation: location];
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSInteger numRows = [sectionInfo numberOfObjects];
    return numRows;
}


- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    VenueTableCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
    [self configureCell: cell forIndexPath: indexPath];
    return cell;
}


#pragma mark UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    VenueEntity *venue = [[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.row];
    DetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    vc.venue = venue;
    [self.navigationController pushViewController: vc animated:YES];

}

#pragma mark - Layout

- (void)configureCell: (VenueTableCell*)cell forIndexPath: (NSIndexPath*)indexPath
{
    VenueEntity *venue = (VenueEntity*)[self.fetchedResultsController objectAtIndexPath: indexPath];
    cell.venue = venue;
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    _fetchedResultsController = [VenueEntity MR_fetchAllSortedBy:@"name" ascending:YES withPredicate:nil groupBy:nil delegate:self inContext: [NSManagedObjectContext MR_defaultContext]];
    
    return _fetchedResultsController;
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
        {
            [tableView deleteRowsAtIndexPaths: [NSArray arrayWithObject: indexPath]
                             withRowAnimation: UITableViewRowAnimationFade];
            break;
        }
            
        case NSFetchedResultsChangeUpdate: {
            [self configureCell: (VenueTableCell*)[self.tableView cellForRowAtIndexPath: indexPath]
                   forIndexPath: indexPath];
            
            break;
        }
        case NSFetchedResultsChangeMove:
        {
            [tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
        }
    }
    
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

@end
