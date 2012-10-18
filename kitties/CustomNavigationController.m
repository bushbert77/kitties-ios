//
//  CustomNavigationController.m
//  kitties
//
//  Created by Koen Romers on 16-10-12.
//  Copyright (c) 2012 Koen Romers. All rights reserved.
//

#import "CustomNavigationController.h"
#import "ViewController.h"

@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

- (void)customizeAppearance {
    
    // Create resizable images
    UIImage *portrait = [[UIImage imageNamed:@"navigation-bar-bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *landscape = [[UIImage imageNamed:@"navigation-bar-bg-landscape.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    // Set the background image for *all* UINavigationBars
    [[UINavigationBar appearanceWhenContainedIn:[CustomNavigationController class], nil] setBackgroundImage:portrait forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearanceWhenContainedIn:[CustomNavigationController class], nil] setBackgroundImage:landscape forBarMetrics:UIBarMetricsLandscapePhone];
    [[UINavigationBar appearanceWhenContainedIn:[CustomNavigationController class], nil] setShadowImage:[UIImage imageNamed:@"navigation-bar-shadow.png"]];
    
    // Customize the title text for *all* UINavigationBars
    NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [UIColor whiteColor],
                                      UITextAttributeTextColor,
                                      [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],
                                      UITextAttributeTextShadowColor,
                                      [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
                                      UITextAttributeTextShadowOffset,
                                      [UIFont fontWithName:@"GiddyupStd" size:24],
                                      UITextAttributeFont,
                                      nil];
    
    [[UINavigationBar appearanceWhenContainedIn:[CustomNavigationController class], nil] setTitleTextAttributes: textTitleOptions];
    
    [[UINavigationBar appearanceWhenContainedIn:[CustomNavigationController class], nil] setTintColor:[UIColor colorWithRed:215/255.0f green:115/255.0f blue:0/255.0f alpha:1]];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set layout
    [self customizeAppearance];
}

- (BOOL)shouldAutorotate {
    if (self.topViewController != nil)
        return [self.topViewController shouldAutorotate];
    else
        return [super shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations {
    if (self.topViewController != nil)
        return [self.topViewController supportedInterfaceOrientations];
    else
        return [super supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if (self.topViewController != nil)
        return [self.topViewController preferredInterfaceOrientationForPresentation];
    else
        return [super preferredInterfaceOrientationForPresentation];
}

@end
