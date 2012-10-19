//
//  CVCell.m
//  kitties
//
//  Created by Koen Romers on 08-10-12.
//  Copyright (c) 2012 Koen Romers. All rights reserved.
//

#import "CVCell.h"

@implementation CVCell

@synthesize photo = _photo;
@synthesize loading = _loading;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"CVCell" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
        
    }
    
    return self;
    
}

@end