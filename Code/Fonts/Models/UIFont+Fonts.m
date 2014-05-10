//
//  UIFont+Fonts.m
//  Fonts
//
//  Created by Andrew Hershberger on 5/10/14.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import "UIFont+Fonts.h"


@implementation UIFont (Fonts)

- (NSString *)twt_visibleName
{
    return [[self fontDescriptor] objectForKey:UIFontDescriptorVisibleNameAttribute];
}


- (NSString *)twt_face
{
    return [[self fontDescriptor] objectForKey:UIFontDescriptorFaceAttribute];
}

@end
