//
//  TWTUserDefaults.m
//  Fonts
//
//  Created by Andrew Hershberger on 4/29/14.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import "TWTUserDefaults.h"

static NSString *const kPreviewTextKey = @"PreviewText";

@implementation TWTUserDefaults

- (void)setPreviewText:(NSString *)previewText
{
    [[NSUserDefaults standardUserDefaults] setObject:previewText forKey:kPreviewTextKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (NSString *)previewText
{
    NSString *previewText = [[NSUserDefaults standardUserDefaults] objectForKey:kPreviewTextKey];
    if (!previewText) {
        previewText = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz\n0123456789\n@.,:;%$#!?()'\"‘’“”/\\";
    }
    return previewText;
}

@end
