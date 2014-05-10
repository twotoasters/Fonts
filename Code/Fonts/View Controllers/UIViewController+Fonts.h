//
//  UIViewController+Fonts.h
//  Fonts
//
//  Created by Andrew Hershberger on 4/29/14.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

@import UIKit;


@interface UIViewController (Fonts)

@property (nonatomic, copy) void(^twt_completion)(BOOL finished);

- (void)twt_finish;

- (void)twt_cancel;

@end
