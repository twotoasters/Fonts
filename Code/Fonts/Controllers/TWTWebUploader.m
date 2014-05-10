//
//  TWTWebUploader.m
//  Fonts
//
//  Created by Andrew Hershberger on 5/6/14.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import "TWTWebUploader.h"

#import "TWTFontsController.h"


@implementation TWTWebUploader

- (BOOL)shouldDeleteItemAtPath:(NSString *)path
{
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

@end
