//
//  TWTFontLoader.h
//  Fonts
//
//  Created by Andrew Hershberger on 2/20/14.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

@import Foundation;


extern NSString *const kTWTFontLoaderDidOpenFontNotification;


@interface TWTFontLoader : NSObject

+ (void)loadFonts;
+ (BOOL)openFontWithURL:(NSURL *)url;

@end
