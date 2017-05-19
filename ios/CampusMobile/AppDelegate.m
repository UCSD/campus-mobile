/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "AppDelegate.h"
#import "CodePush.h"

#import "RCTUtils.h"
#import "RCTBundleURLProvider.h"
#import "RCTRootView.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  NSURL *jsCodeLocation;
  
#ifdef DEBUG
		jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index.ios" fallbackResource:nil];
#else
		jsCodeLocation = [CodePush bundleURL];
#endif
  
  RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                      moduleName:@"CampusMobile"
                                               initialProperties:nil
                                                   launchOptions:launchOptions];
  
  rootView.backgroundColor = [[UIColor alloc] initWithRed:0.0118f green:0.2588f blue:0.3843f alpha:1];
  
  // Get launch image
  NSString *launchImageName = nil;
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    CGFloat height = MAX(RCTScreenSize().width, RCTScreenSize().height);
    if (height == 480) 		launchImageName = @"splashscreen_640x960.png";
    else if (height == 568) launchImageName = @"splashscreen_640x1136.png";
    else if (height == 667) launchImageName = @"splashscreen_750x1334.png";
    else if (height == 736) launchImageName = @"splashscreen_1242x212208.png";
    else					launchImageName = @"splashscreen_640x1136.png";
  }
  
  // Create loading view
  UIImage *image = [UIImage imageNamed:launchImageName];
  if (image) {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:(CGRect){CGPointZero, RCTScreenSize()}];
    imageView.contentMode = UIViewContentModeBottom;
    imageView.image = image;
    rootView.loadingView = imageView;
  }
  
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  return YES;
}

@end

