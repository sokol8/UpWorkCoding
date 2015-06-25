//
//  DetailViewController.h
//  UpWorkProCoding
//
//  Created by Kostiantyn Sokolinskyi on 6/25/15.
//  Copyright (c) 2015 SROST Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VenueEntity;

@interface DetailViewController : UIViewController
@property (nonatomic, strong) VenueEntity *venue;

@end
