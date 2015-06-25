//
//  VenueTableCell.m
//  UpWorkProCoding
//
//  Created by Kostiantyn Sokolinskyi on 6/25/15.
//  Copyright (c) 2015 SROST Studio. All rights reserved.

#import "VenueTableCell.h"
#import "VenueEntity.h"

@interface VenueTableCell ()
{
}

@end

@implementation VenueTableCell

@synthesize venue = __venue;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}


- (void)setVenue:(VenueEntity *)venue
{
    self.contentView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    
    if ( venue != __venue ) {
        __venue = venue;
        _titleLabel.text  = venue.name;
    }
}

@end
