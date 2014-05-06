//
//  TWTFontLoader.m
//  Fonts
//
//  Created by Andrew Hershberger on 2/20/14.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import "TWTFontLoader.h"

@import CoreText;

#import "TWTWebUploader.h"

#import "TWTEnvironment.h"


NSString *const kTWTFontLoaderDidStartWebServerNotification = @"TWTFontLoaderDidStartWebServer";
NSString *const kTWTFontLoaderDidStopWebServerNotification = @"TWTFontLoaderDidStopWebServer";
NSString *const kTWTFontLoaderDidChangeFontsNotification = @"TWTFontLoaderDidChangeFonts";


@interface TWTFontLoader () <GCDWebUploaderDelegate>

@property (nonatomic, strong) TWTWebUploader *webServer;

@end


@implementation TWTFontLoader

+ (instancetype)sharedInstance
{
    static TWTFontLoader *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TWTFontLoader alloc] init];
    });
    return sharedInstance;
}


- (id)init
{
    self = [super init];
    if (self) {
        NSString *uploadPath = [[self fontsDirectoryURL] path];
        _webServer = [[TWTWebUploader alloc] initWithUploadDirectory:uploadPath];
        _webServer.allowedFileExtensions = @[ @"ttf", @"otf" ];
        _webServer.delegate = self;
        [_webServer start];
    }
    return self;
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


- (BOOL)openFontWithURL:(NSURL *)url
{
    if (!url.isFileURL) {
        return NO;
    }

    if (![self.webServer.allowedFileExtensions containsObject:url.pathExtension]) {
        NSLog(@"Skipping non-font file: %@", url);
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

    return [self loadFontWithURL:toURL];
}


- (BOOL)loadFontWithURL:(NSURL *)url
{
    NSLog(@"%s url: %@", __PRETTY_FUNCTION__, url);

    CFErrorRef error = nil;
    bool success = CTFontManagerRegisterFontsForURL((CFURLRef)url, kCTFontManagerScopeProcess, &error);

    if (success) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kTWTFontLoaderDidChangeFontsNotification object:self userInfo:nil];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:kTWTFontLoaderDidChangeFontsNotification object:self userInfo:nil];
    }
    else {
        CFStringRef errorDescription = CFErrorCopyDescription(error);
        NSLog(@"Failed to unregister font: %@", errorDescription);
        CFRelease(errorDescription);
    }

    return success;
}


- (NSURL *)fontsDirectoryURL
{
    NSURL *fontsDirectoryURL = [TWTDocumentsDirectoryURL() URLByAppendingPathComponent:@"Fonts" isDirectory:YES];

    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSError *error = nil;
    BOOL success = [fileManager createDirectoryAtURL:fontsDirectoryURL withIntermediateDirectories:YES attributes:nil error:&error];
    NSAssert(success, @"Failed to create directory: %@ %@", fontsDirectoryURL, error);

    return fontsDirectoryURL;
}


- (NSURL *)webServerURL
{
    return self.webServer.serverURL;
}


#pragma mark - GCDWebUploaderDelegate

- (void)webUploader:(GCDWebUploader *)uploader didUploadFileAtPath:(NSString *)path
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *url = [NSURL fileURLWithPath:path];
        [self loadFontWithURL:url];
    });
}


- (void)webServerDidStart:(GCDWebServer *)server
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kTWTFontLoaderDidStartWebServerNotification object:self userInfo:nil];
    });
}


- (void)webServerDidStop:(GCDWebServer *)server;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kTWTFontLoaderDidStopWebServerNotification object:self userInfo:nil];
    });
}

@end
