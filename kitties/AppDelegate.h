//
//  AppDelegate.h
//  kitties
//
//  Created by Koen Romers on 12-10-12.
//  Copyright (c) 2012 Koen Romers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavigationController.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    CustomNavigationController *navigationController;
}
@property (strong, nonatomic) CustomNavigationController *navigationController;
@property (strong, nonatomic) UIWindow *window;

@end
