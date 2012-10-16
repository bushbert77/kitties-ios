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
@synthesize infoText2;
@synthesize name;
@synthesize website;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//-(void)popView: (UIBarButtonItem *)sender {
//    [self.navigationController popViewControllerAnimated:YES];
//}

- (void)viewDidLoad {
    [super viewDidLoad];

//    UIImage *buttonBackground = [[UIImage imageNamed:@"back"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 25, 0, 5) resizingMode:UIImageResizingModeStretch];
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(popView:)];
//    [backButton setBackgroundImage:buttonBackground forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    [self.navigationItem setLeftBarButtonItem:backButton];
//    [self.navigationItem setHidesBackButton:YES];
    
    // Set background pattern
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern.png"]]];
    
    // Set title navigation bar
    self.title = @"Information";
    UIFont *font = [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:16];
    
    [infoText setFont:font];
    [infoText setTextColor:[UIColor blackColor]];
    
    [infoText2 setFont:font];
    [infoText2 setTextColor:[UIColor blackColor]];
    
    [name setFont:[UIFont fontWithName:@"AvenirNextCondensed-Medium" size:14]];
    [name setTextColor:[UIColor darkGrayColor]];
    
    website.titleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:14];
    website.titleLabel.textColor = [UIColor colorWithRed:255.0f/255.0f green:102.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    [website addTarget:self action:@selector(openWebsite:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)openWebsite: (UIButton *)button {
    NSURL *url = [NSURL URLWithString:@"http://www.koenromers.com"];
    [[UIApplication sharedApplication] openURL:url];
}

-(BOOL)shouldAutorotate {
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}


@end
