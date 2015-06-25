//
//  VenueTableCell.h
//  UpWorkProCoding
//
//  Created by Kostiantyn Sokolinskyi on 6/25/15.
//  Copyright (c) 2015 SROST Studio. All rights reserved.

#import <UIKit/UIKit.h>
#import "VenueEntity.h"

@class VenueTableCell;


@interface VenueTableCell : UITableViewCell

@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) VenueEntity *venue;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@end
