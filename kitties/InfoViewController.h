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
    IBOutlet UILabel *infoText2;
    IBOutlet UILabel *name;
    IBOutlet UIButton *website;
}

@property (nonatomic, retain) UILabel *infoText;
@property (nonatomic, retain) UILabel *infoText2;
@property (nonatomic, retain) UILabel *name;
@property (nonatomic, retain) UIButton *website;

@end
