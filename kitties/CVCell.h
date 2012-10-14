//
//  CVCell.h
//  kitties
//
//  Created by Koen Romers on 08-10-12.
//  Copyright (c) 2012 Koen Romers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CVCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *photo;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loading;

@end
