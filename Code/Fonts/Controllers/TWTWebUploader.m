//
//  TWTWebUploader.m
//  Fonts
//
//  Created by Andrew Hershberger on 5/6/14.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import "TWTWebUploader.h"

#import "TWTFontsController.h"


NSString *const kTWTWebUploaderDidChangeURLNotification = @"TWTWebUploaderDidChangeURL";


@interface TWTWebUploader () <GCDWebUploaderDelegate>
@end


@implementation TWTWebUploader


+ (instancetype)sharedInstance
{
    static TWTWebUploader *webUploader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        webUploader = [[[self class] alloc] init];
    });
    return webUploader;
}


- (instancetype)init
{
    NSString *uploadPath = [[[TWTFontsController sharedInstance] fontsDirectoryURL] path];
    self = [super initWithUploadDirectory:uploadPath];
    if (self) {
        self.allowedFileExtensions = @[ @"ttf", @"otf" ];
        self.delegate = self;
    }
    return self;
}


- (BOOL)validatePath:(NSString *)path
{
    path = [[path stringByStandardizingPath] stringByDeletingLastPathComponent];

    NSString *uploadPath = [[[[TWTFontsController sharedInstance] fontsDirectoryURL] path] stringByStandardizingPath];

    return [path isEqualToString:uploadPath];
}


- (BOOL)shouldUploadFileAtPath:(NSString *)path withTemporaryFile:(NSString *)tempPath
{
    return [self validatePath:path];
}


- (BOOL)shouldDeleteItemAtPath:(NSString *)path
{
    if (![self validatePath:path]) {
        return NO;
    }

    NSURL *url = [NSURL fileURLWithPath:path];

    __block BOOL shouldDelete = YES;

    if ([self.allowedFileExtensions containsObject:url.pathExtension]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            shouldDelete = [[TWTFontsController sharedInstance] unloadFontWithURL:url];
        });
    }

    return shouldDelete;
}


- (BOOL)shouldCreateDirectoryAtPath:(NSString *)path
{
    return NO;
}


- (BOOL)shouldMoveItemFromPath:(NSString *)fromPath toPath:(NSString *)toPath
{
    return NO;
}


- (void)postDidChangeURLNotification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kTWTWebUploaderDidChangeURLNotification
                                                            object:self
                                                          userInfo:nil];
    });
}


#pragma mark - GCDWebUploaderDelegate

- (void)webUploader:(GCDWebUploader *)uploader didUploadFileAtPath:(NSString *)path
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *url = [NSURL fileURLWithPath:path];
        [[TWTFontsController sharedInstance] loadFontWithURL:url];
    });
}


- (void)webServerDidStart:(GCDWebServer *)server
{
    [self postDidChangeURLNotification];
}


- (void)webServerDidStop:(GCDWebServer *)server;
{
    [self postDidChangeURLNotification];
}

@end
