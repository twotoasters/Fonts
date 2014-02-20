//
//  TWTFontsViewController.h
//  Fonts
//
//  Created by Andrew Hershberger on 2/19/14.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

@import UIKit;


extern NSString *const kTWTFontsViewControllerSelectedFontNameDidChangeNotification;
extern NSString *const kTWTFontsViewControllerSelectedFontNameKey;


@interface TWTFontsViewController : UITableViewController

@property (nonatomic, copy) NSString *familyName;

@end
