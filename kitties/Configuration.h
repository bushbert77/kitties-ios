//
//  Configuration.h
//  kitties
//
//  Created by Koen Romers on 09-10-12.
//  Copyright (c) 2012 Koen Romers. All rights reserved.
//

#import <foundation/Foundation.h>

@interface Configuration : NSObject {
    NSString *ApiUrl;
}

@property (nonatomic, retain) NSString *ApiUrl;

+ (Configuration *)sharedInstance;

@end