//
//  DetailViewController.m
//  UpWorkProCoding
//
//  Created by Kostiantyn Sokolinskyi on 6/25/15.
//  Copyright (c) 2015 SROST Studio. All rights reserved.
//

#import "DetailViewController.h"
#import "VenueEntity.h"

@interface DetailViewController () <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView *addressTextView;
@property (strong, nonatomic) IBOutlet UITextView *phoneTextView;
@property (strong, nonatomic) IBOutlet UITextView *URLTextView;
@property (strong, nonatomic) IBOutlet UITextView *menuURLTextView;


@end

@implementation DetailViewController

@synthesize venue = _venue;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self layoutVenue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)layoutVenue
{
    self.title = self.venue.name;
    
    self.addressTextView.text = [self contentText: self.venue.address];
    self.phoneTextView.text = [self contentText: self.venue.phone];
    self.URLTextView.text = [self contentText: self.venue.url];
    self.menuURLTextView.text = [self contentText: self.venue.menuUrl];
}

- (NSString*)contentText: (NSString*)string
{
    return (0 < [string length] ? string : @"N/A");
}

#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView*)textView shouldInteractWithURL:(NSURL*)URL inRange:(NSRange)characterRange
{
    return YES;
}


@end
