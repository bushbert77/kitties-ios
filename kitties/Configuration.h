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
    NSNumber *NumberOfKitties;
}

@property (nonatomic, retain) NSString *ApiUrl;
@property (nonatomic,retain) NSNumber *NumberOfKitties;
@property (nonatomic,retain) NSNumber *IncreaseOfInterestingness;

+ (Configuration *)sharedInstance;

@end