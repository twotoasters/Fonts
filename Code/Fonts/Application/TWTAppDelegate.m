//
//  TWTAppDelegate.m
//  Fonts
//
//  Created by Andrew Hershberger on 2/19/14.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import "TWTAppDelegate.h"

#import <TWTToast/TWTBlockEnumeration.h>

#import "TWTEnvironment.h"
#import "TWTFontFamiliesViewController.h"
#import "TWTFontPreviewViewController.h"
#import "TWTFontsController.h"
#import "TWTWebUploader.h"


@implementation TWTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[TWTFontsController sharedInstance] loadFonts];
    [[TWTWebUploader sharedInstance] start];

    TWTFontFamiliesViewController *fontFamiliesViewController = [[TWTFontFamiliesViewController alloc] init];

    UIViewController *rootViewController = nil;

    if (TWTUserInterfaceIdiomIsPad()) {
        TWTFontPreviewViewController *fontPreviewViewController = [[TWTFontPreviewViewController alloc] init];
        UISplitViewController *splitViewController = [[UISplitViewController alloc] init];
        NSArray *viewControllers = @[ fontFamiliesViewController, fontPreviewViewController ];
        splitViewController.viewControllers = [viewControllers twt_collectWithBlock:^id(UIViewController *viewController) {
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
            navigationController.toolbarHidden = NO;
            return navigationController;
        }];
        rootViewController = splitViewController;
    }
    else {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:fontFamiliesViewController];
        navigationController.toolbarHidden = NO;
        rootViewController = navigationController;
    }

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];

    return YES;
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    NSURL *fontsDirectoryURL = [[TWTFontsController sharedInstance] fontsDirectoryURL];
    NSURL *toURL = [fontsDirectoryURL URLByAppendingPathComponent:url.lastPathComponent
                                                      isDirectory:NO];

    NSError *error = nil;
    BOOL copySuccess = [[NSFileManager defaultManager] copyItemAtURL:url toURL:toURL error:&error];

    if (!copySuccess) {
        NSLog(@"Failed to copy file from %@ to %@", url, toURL);
        return NO;
    }

    return [[TWTFontsController sharedInstance] loadFontWithURL:url];
}

@end
