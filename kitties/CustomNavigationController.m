//
//  CustomNavigationController.m
//  kitties
//
//  Created by Koen Romers on 16-10-12.
//  Copyright (c) 2012 Koen Romers. All rights reserved.
//

#import "CustomNavigationController.h"

@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

- (void)customizeAppearance {
    
    // Create resizable images
    UIImage *portrait = [[UIImage imageNamed:@"navigation-bar-bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *landscape = [[UIImage imageNamed:@"navigation-bar-bg-landscape.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    // Set the background image for *all* UINavigationBars
    [[UINavigationBar appearance] setBackgroundImage:portrait forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundImage:landscape forBarMetrics:UIBarMetricsLandscapePhone];
    [[UINavigationBar appearance] setShadowImage:[UIImage imageNamed:@"navigation-bar-shadow.png"]];
    
    // Customize the title text for *all* UINavigationBars
    NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [UIColor whiteColor],
                                      UITextAttributeTextColor,
                                      [UIColor colorWithRed:0 green:0 blue:0 alpha:0],
                                      UITextAttributeTextShadowColor,
                                      [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
                                      UITextAttributeTextShadowOffset,
                                      [UIFont fontWithName:@"GiddyupStd" size:26],
                                      UITextAttributeFont,
                                      nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes: textTitleOptions];
    
//    // Back button
//    UIImage *buttonBack = [[UIImage imageNamed:@"back"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 5)];
//    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:buttonBack forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    UIImage *buttonBackLandscape = [[UIImage imageNamed:@"back-landscape"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 5)];
//    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:buttonBackLandscape forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    
    
    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:215/255.0f green:118/255.0f blue:0/255.0f alpha:1]];
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
