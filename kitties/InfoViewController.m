//
//  InfoViewController.m
//  kitties
//
//  Created by Koen Romers on 15-10-12.
//  Copyright (c) 2012 Koen Romers. All rights reserved.
//

#import "InfoViewController.h"
#import "Configuration.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

@synthesize infoText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set background pattern
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern.png"]]];
    
    // Set title navigation bar
    [self setTitle:@"Information"];
    UIFont *font = [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:16];
    
    [infoText setFont:font];
    [infoText setTextColor:[UIColor blackColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate {
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}


@end
