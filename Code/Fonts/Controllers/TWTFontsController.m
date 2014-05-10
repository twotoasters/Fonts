//
//  TWTFontsController.m
//  Fonts
//
//  Created by Andrew Hershberger on 2/20/14.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import "TWTFontsController.h"

@import CoreText;

#import "TWTEnvironment.h"


NSString *const kTWTFontsControllerDidChangeFontsNotification = @"TWTFontsControllerDidChangeFonts";


@implementation TWTFontsController

+ (instancetype)sharedInstance
{
    static TWTFontsController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}


- (void)loadFonts
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];

    NSError *error = nil;
    NSArray *fileURLs = [fileManager contentsOfDirectoryAtURL:[self fontsDirectoryURL]
                                   includingPropertiesForKeys:nil
                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        error:&error];

    for (NSURL *fileURL in fileURLs) {
        [self loadFontWithURL:fileURL];
    }
}


- (BOOL)loadFontWithURL:(NSURL *)url
{
    NSLog(@"%s url: %@", __PRETTY_FUNCTION__, url);

    CFErrorRef error = nil;
    bool success = CTFontManagerRegisterFontsForURL((CFURLRef)url, kCTFontManagerScopeProcess, &error);

    if (success) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kTWTFontsControllerDidChangeFontsNotification object:self userInfo:nil];
    }
    else {
        CFStringRef errorDescription = CFErrorCopyDescription(error);
        NSLog(@"Failed to register font: %@", errorDescription);
        CFRelease(errorDescription);

        NSError *error = nil;
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        [fileManager removeItemAtURL:url error:&error];
    }

    return success;
}


- (BOOL)unloadFontWithURL:(NSURL *)url
{
    NSLog(@"%s url: %@", __PRETTY_FUNCTION__, url);

    CFErrorRef error = nil;
    bool success = CTFontManagerUnregisterFontsForURL((CFURLRef)url, kCTFontManagerScopeProcess, &error);

    if (success) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kTWTFontsControllerDidChangeFontsNotification object:self userInfo:nil];
    }
    else {
        CFStringRef errorDescription = CFErrorCopyDescription(error);
        NSLog(@"Failed to unregister font: %@", errorDescription);
        CFRelease(errorDescription);
    }

    return success;
}


#pragma mark - Property Accessors

- (NSURL *)fontsDirectoryURL
{
    NSURL *fontsDirectoryURL = [TWTDocumentsDirectoryURL() URLByAppendingPathComponent:@"Fonts" isDirectory:YES];

    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSError *error = nil;
    BOOL success = [fileManager createDirectoryAtURL:fontsDirectoryURL withIntermediateDirectories:YES attributes:nil error:&error];
    NSAssert(success, @"Failed to create directory: %@ %@", fontsDirectoryURL, error);

    return fontsDirectoryURL;
}

@end
