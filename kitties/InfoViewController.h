//
//  InfoViewController.h
//  kitties
//
//  Created by Koen Romers on 15-10-12.
//  Copyright (c) 2012 Koen Romers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController {
    IBOutlet UILabel *infoText;
}

@property (nonatomic, retain) UILabel *infoText;

@end
