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

@property (nonatomic) CGFloat fontSize;

@property (nonatomic, weak) UILabel *label;

@property (nonatomic, weak) UILabel *fontSizeLabel;
@property (nonatomic, weak) UILabel *ascenderLabel;
@property (nonatomic, weak) UILabel *descenderLabel;

@property (nonatomic, strong, readonly) NSNumberFormatter *pointSizeNumberFormatter;

@end


@implementation TWTFontPreviewViewController
@synthesize pointSizeNumberFormatter = _pointSizeNumberFormatter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _fontName = @"Helvetica";
        _fontSize = 18.0;

        UIBarButtonItem *fontSizeItem = [[UIBarButtonItem alloc] initWithCustomView:[[UILabel alloc] init]];
        _fontSizeLabel = (UILabel *)fontSizeItem.customView;

        UIBarButtonItem *ascenderItem = [[UIBarButtonItem alloc] initWithCustomView:[[UILabel alloc] init]];
        _ascenderLabel = (UILabel *)ascenderItem.customView;

        UIBarButtonItem *descenderItem = [[UIBarButtonItem alloc] initWithCustomView:[[UILabel alloc] init]];
        _descenderLabel = (UILabel *)descenderItem.customView;

        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                       target:nil
                                                                                       action:NULL];

        self.toolbarItems = @[ fontSizeItem, flexibleSpace, ascenderItem, flexibleSpace, descenderItem ];

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

    id bottomLayoutGuide = self.bottomLayoutGuide;

    NSDictionary *views = NSDictionaryOfVariableBindings(label, fontSizeSlider, bottomLayoutGuide);
    [self.view twt_addConstraintsWithVisualFormatStrings:@[ @"H:|-[label]-|", @"H:|-[fontSizeSlider]-|", @"V:[fontSizeSlider]-[bottomLayoutGuide]" ]
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


- (NSNumberFormatter *)pointSizeNumberFormatter
{
    if (!_pointSizeNumberFormatter) {
        _pointSizeNumberFormatter = [[NSNumberFormatter alloc] init];
        _pointSizeNumberFormatter.minimumFractionDigits = 0;
        _pointSizeNumberFormatter.maximumFractionDigits = 6;
    }

    return _pointSizeNumberFormatter;
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
    UIFont *font = [UIFont fontWithName:self.fontName size:self.fontSize];

    self.title = self.fontName;

    self.fontSizeLabel.text = [NSString stringWithFormat:@"%@pt", [self.pointSizeNumberFormatter stringFromNumber:@(font.pointSize)]];
    [self.fontSizeLabel sizeToFit];
    self.ascenderLabel.text = [NSString stringWithFormat:@"↑ %@pt", [self.pointSizeNumberFormatter stringFromNumber:@(font.ascender)]];
    [self.ascenderLabel sizeToFit];
    self.descenderLabel.text = [NSString stringWithFormat:@"↓ %@pt", [self.pointSizeNumberFormatter stringFromNumber:@(font.descender)]];
    [self.descenderLabel sizeToFit];

    self.label.font = font;
}

@end
