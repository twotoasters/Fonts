//
//  TWTFontLoader.h
//  Fonts
//
//  Created by Andrew Hershberger on 2/20/14.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

@import Foundation;


extern NSString *const kTWTFontLoaderDidStartWebServerNotification;
extern NSString *const kTWTFontLoaderDidStopWebServerNotification;
extern NSString *const kTWTFontLoaderDidChangeFontsNotification;


@interface TWTFontLoader : NSObject

+ (instancetype)sharedInstance;

- (void)loadFonts;
- (BOOL)openFontWithURL:(NSURL *)url;
- (BOOL)loadFontWithURL:(NSURL *)url;
- (BOOL)unloadFontWithURL:(NSURL *)url;

@property (nonatomic, readonly) NSURL *webServerURL;

@end
