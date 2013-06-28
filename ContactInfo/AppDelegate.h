//
//  AppDelegate.h
//  ContactInfo
//
//  Created by goodcore1 on 5/21/13.
//  Copyright (c) 2013 goodcore1. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) BOOL isLoadedFirstTime;

@property (strong, nonatomic) ViewController *viewController;

@end
