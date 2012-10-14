//
//  HTTPClient.h
//  kitties
//
//  Created by Koen Romers on 14-10-12.
//  Copyright (c) 2012 Koen Romers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPClient.h"

@interface ApiClient : AFHTTPClient

+ (ApiClient *)sharedClient;

@end
