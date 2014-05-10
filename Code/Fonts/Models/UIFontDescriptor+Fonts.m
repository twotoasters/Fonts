//
//  UIFontDescriptor+Fonts.m
//  Fonts
//
//  Created by Andrew Hershberger on 5/10/14.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import "UIFontDescriptor+Fonts.h"


@implementation UIFontDescriptor (Fonts)

+ (NSString *)twt_visibleNameForFontName:(NSString *)fontName
{
    NSDictionary *attributes = @{ UIFontDescriptorNameAttribute : fontName };
    UIFontDescriptor *fontDescriptor = [[UIFontDescriptor alloc] initWithFontAttributes:attributes];
    return [fontDescriptor objectForKey:UIFontDescriptorVisibleNameAttribute];
}


+ (NSString *)twt_faceForFontName:(NSString *)fontName
{
    NSDictionary *attributes = @{ UIFontDescriptorNameAttribute : fontName };
    UIFontDescriptor *fontDescriptor = [[UIFontDescriptor alloc] initWithFontAttributes:attributes];
    return [fontDescriptor objectForKey:UIFontDescriptorFaceAttribute];
}

@end
