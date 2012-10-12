//
//  Configuration.m
//  kitties
//
//  Created by Koen Romers on 09-10-12.
//  Copyright (c) 2012 Koen Romers. All rights reserved.
//

#import "Configuration.h"

@implementation Configuration

@synthesize ApiUrl;

#pragma mark Singleton Methods

+ (Configuration *)sharedInstance {
    static Configuration *sharedConfiguration = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedConfiguration = [[self alloc] init];
    });
    return sharedConfiguration;
}

- (id)init {
    if (self = [super init]) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Configuration" ofType:@"plist"];
		NSDictionary *pfile = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        
        [self setApiUrl:[pfile objectForKey:@"ApiUrl"]];
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end