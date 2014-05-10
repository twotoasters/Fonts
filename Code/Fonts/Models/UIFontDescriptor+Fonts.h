//
//  UIFontDescriptor+Fonts.h
//  Fonts
//
//  Created by Andrew Hershberger on 5/10/14.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

@import UIKit;


@interface UIFontDescriptor (Fonts)

+ (NSString *)twt_visibleNameForFontName:(NSString *)fontName;

+ (NSString *)twt_faceForFontName:(NSString *)fontName;

@end
