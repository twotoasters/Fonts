//
//  TWTFontLoader.m
//  Fonts
//
//  Created by Andrew Hershberger on 2/20/14.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import "TWTFontLoader.h"

@import CoreText;


NSString *const kTWTFontLoaderDidOpenFontNotification = @"TWTFontLoaderDidOpenFont";


@implementation TWTFontLoader

+ (void)loadFonts
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


+ (BOOL)openFontWithURL:(NSURL *)url
{
    if (!url.isFileURL) {
        return NO;
    }

    NSURL *toURL = [[self fontsDirectoryURL] URLByAppendingPathComponent:url.lastPathComponent isDirectory:NO];

    NSError *error = nil;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL copySuccess = [fileManager copyItemAtURL:url toURL:toURL error:&error];

    if (!copySuccess) {
        NSLog(@"Failed to copy file from %@ to %@", url, toURL);
        return NO;
    }

    BOOL loadSuccess = [self loadFontWithURL:toURL];

    if (!loadSuccess) {
        error = nil;
        [fileManager removeItemAtURL:toURL error:&error];
        return NO;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kTWTFontLoaderDidOpenFontNotification object:self userInfo:nil];

    return YES;
}


+ (BOOL)loadFontWithURL:(NSURL *)url
{
    CFErrorRef error = nil;
    bool success = CTFontManagerRegisterFontsForURL((CFURLRef)url, kCTFontManagerScopeProcess, &error);

    if (!success) {
        CFStringRef errorDescription = CFErrorCopyDescription(error);
        NSLog(@"Failed to register font: %@", errorDescription);
        CFRelease(errorDescription);
    }

    return success;
}


+ (NSURL *)fontsDirectoryURL
{
    NSURL *documentsDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSURL *fontsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:@"Fonts" isDirectory:YES];

    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSError *error = nil;
    BOOL success = [fileManager createDirectoryAtURL:fontsDirectoryURL withIntermediateDirectories:YES attributes:nil error:&error];
    NSAssert(success, @"Failed to create directory: %@ %@", fontsDirectoryURL, error);

    return fontsDirectoryURL;
}

@end
