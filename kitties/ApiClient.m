//
//  HTTPClient.m
//  kitties
//
//  Created by Koen Romers on 14-10-12.
//  Copyright (c) 2012 Koen Romers. All rights reserved.
//

#import "ApiClient.h"
#import "Configuration.h"
#import "AFJSONRequestOperation.h"

@implementation ApiClient

+ (ApiClient *)sharedClient {
    static ApiClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[ApiClient alloc] initWithBaseURL:[NSURL URLWithString:[[Configuration sharedInstance] ApiUrl]]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

@end
