//
//  TWTAppDelegate.m
//  Fonts
//
//  Created by Andrew Hershberger on 2/19/14.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import "TWTAppDelegate.h"

#import <TWTToast/TWTHighOrderFunctions.h>

#import "TWTFontFamiliesViewController.h"
#import "TWTFontLoader.h"
#import "TWTFontPreviewViewController.h"


@implementation TWTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TWTFontLoader loadFonts];

    TWTFontFamiliesViewController *fontFamiliesViewController = [[TWTFontFamiliesViewController alloc] init];
    TWTFontPreviewViewController *fontPreviewViewController = [[TWTFontPreviewViewController alloc] init];

    UISplitViewController *splitViewController = [[UISplitViewController alloc] init];
    splitViewController.viewControllers = TWTSimpleMap(@[ fontFamiliesViewController, fontPreviewViewController ], ^id(UIViewController *viewController) {
        return [[UINavigationController alloc] initWithRootViewController:viewController];
    });

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = splitViewController;
    [self.window makeKeyAndVisible];

    return YES;
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [TWTFontLoader openFontWithURL:url];
}

@end
