//
//  TWTEnvironment.m
//  Fonts
//
//  Created by Andrew Hershberger on 4/29/14.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import "TWTEnvironment.h"

BOOL TWTUserInterfaceIdiomIsPad(void)
{
    static BOOL isPad;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
    });
    return isPad;
}
