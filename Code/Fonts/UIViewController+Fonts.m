//
//  UIViewController+Fonts.m
//  Fonts
//
//  Created by Andrew Hershberger on 4/29/14.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import "UIViewController+Fonts.h"

@import ObjectiveC.runtime;


static void *kTWTCompletionKey = &kTWTCompletionKey;


@implementation UIViewController (Fonts)

- (void (^)(BOOL))twt_completion
{
    return objc_getAssociatedObject(self, &kTWTCompletionKey);
}


- (void)setTwt_completion:(void (^)(BOOL))twt_completion
{
    objc_setAssociatedObject(self, &kTWTCompletionKey, twt_completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


- (void)twt_finish
{
    [self twt_complete:YES];
}


- (void)twt_cancel
{
    [self twt_complete:NO];
}


- (void)twt_complete:(BOOL)finished
{
    void (^completion)(BOOL) = self.twt_completion;
    if (completion) {
        self.twt_completion = nil;
        completion(finished);
    }
}

@end
