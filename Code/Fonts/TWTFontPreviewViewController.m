//
//  TWTFontPreviewViewController.m
//  Fonts
//
//  Created by Andrew Hershberger on 2/19/14.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import "TWTFontPreviewViewController.h"

#import <TWTToast/UIView+TWTConvenientConstraintAddition.h>

#import "TWTFontsViewController.h"


@interface TWTFontPreviewViewController ()
@property (nonatomic, copy) NSString *fontName;
@property (nonatomic) CGFloat fontSize;

@property (nonatomic, weak) UILabel *label;
@end


@implementation TWTFontPreviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _fontName = @"Helvetica";
        _fontSize = 18.0;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fontsViewControllerSelectedFontNameDidChange:)
                                                     name:kTWTFontsViewControllerSelectedFontNameDidChangeNotification
                                                   object:nil];
    }
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    UILabel *label = [[UILabel alloc] init];
    label.text = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz\n0123456789\n@.,:;%$#!?()'\"‘’“”/\\";
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:label];
    self.label = label;

    UISlider *fontSizeSlider = [[UISlider alloc] init];
    fontSizeSlider.minimumValue = 8.0;
    fontSizeSlider.maximumValue = 72.0;
    fontSizeSlider.value = self.fontSize;
    fontSizeSlider.continuous = YES;
    [fontSizeSlider addTarget:self action:@selector(fontSizeSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    fontSizeSlider.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:fontSizeSlider];

    NSDictionary *views = NSDictionaryOfVariableBindings(label, fontSizeSlider);
    [self.view twt_addConstraintsWithVisualFormatStrings:@[ @"H:|-[label]-|", @"H:|-[fontSizeSlider]-|", @"V:[fontSizeSlider]-|" ]
                                                   views:views];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0.0]];

    [self updateFont];
}


#pragma mark - Property Accessors

- (void)setFontName:(NSString *)fontName
{
    _fontName = [fontName copy];

    [self updateFont];
}


- (void)setFontSize:(CGFloat)fontSize
{
    _fontSize = fontSize;

    [self updateFont];
}


#pragma mark - Notification Handlers

- (void)fontsViewControllerSelectedFontNameDidChange:(NSNotification *)notification
{
    self.fontName = notification.userInfo[kTWTFontsViewControllerSelectedFontNameKey];
}


#pragma mark - Actions

- (void)fontSizeSliderValueChanged:(UISlider *)fontSizeSlider
{
    self.fontSize = round(fontSizeSlider.value);
}


#pragma mark - Helpers

- (void)updateFont
{
    self.title = [NSString stringWithFormat:@"%.0fpt %@", self.fontSize, self.fontName];
    self.label.font = [UIFont fontWithName:self.fontName size:self.fontSize];
}

@end
