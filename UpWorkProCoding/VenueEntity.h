//
//  VenueEntity.h
//  UpWorkProCoding
//
//  Created by Kostiantyn Sokolinskyi on 6/25/15.
//  Copyright (c) 2015 SROST Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface VenueEntity : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * venueId;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lon;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * menuUrl;

@end
