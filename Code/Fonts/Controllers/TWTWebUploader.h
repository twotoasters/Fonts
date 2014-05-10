//
//  TWTWebUploader.h
//  Fonts
//
//  Created by Andrew Hershberger on 5/6/14.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import <GCDWebServer/GCDWebUploader.h>


extern NSString *const kTWTWebUploaderDidChangeURLNotification;


@interface TWTWebUploader : GCDWebUploader

+ (instancetype)sharedInstance;

@end
