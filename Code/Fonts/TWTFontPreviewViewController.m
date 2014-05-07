//
//  TWTFontPreviewViewController.m
//  Fonts
//
//  Created by Andrew Hershberger on 2/19/14.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import "TWTFontPreviewViewController.h"

#import <TWTToast/UIView+TWTConvenientConstraintAddition.h>

#import "TWTEnvironment.h"
#import "TWTFontMetricView.h"
#import "TWTFontsViewController.h"
#import "TWTTextEditorViewController.h"
#import "TWTUserDefaults.h"
#import "UIViewController+Fonts.h"


static NSString *const kDefaultFontName = @"Helvetica";


@interface TWTFontPreviewViewController ()

@property (nonatomic) CGFloat fontSize;

@property (nonatomic, weak) UILabel *label;

@property (nonatomic, copy) NSArray *metricViews;

@property (nonatomic, strong, readonly) NSNumberFormatter *pointSizeNumberFormatter;

@property (nonatomic, strong) TWTUserDefaults *userDefaults;

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, weak) UISlider *fontSizeSlider;

@end


@implementation TWTFontPreviewViewController
@synthesize pointSizeNumberFormatter = _pointSizeNumberFormatter;
@synthesize userDefaults = _userDefaults;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _fontSize = 18.0;

        UISlider *slider = [[UISlider alloc] init];
        slider.minimumValue = 8.0;
        slider.maximumValue = 72.0;
        slider.value = self.fontSize;
        slider.continuous = YES;
        [slider addTarget:self action:@selector(fontSizeSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        UIBarButtonItem *sliderItem = [[UIBarButtonItem alloc] initWithCustomView:slider];
        self.toolbarItems = @[ sliderItem ];
        _fontSizeSlider = slider;

        self.hidesBottomBarWhenPushed = NO;

        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                               target:self
                                                                                               action:@selector(editButtonTapped)];

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

    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;

    UIView *contentView = [[UIView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:contentView];

    TWTFontMetricView *sizeMetricView = [[TWTFontMetricView alloc] init];
    sizeMetricView.metricName = NSLocalizedString(@"Point size", nil);
    sizeMetricView.metricValueBlock = ^(UIFont *font) {
        return [NSString stringWithFormat:@"%@ pt", [self.pointSizeNumberFormatter stringFromNumber:@(font.pointSize)]];
    };

    TWTFontMetricView *ascenderMetricView = [[TWTFontMetricView alloc] init];
    ascenderMetricView.metricName = NSLocalizedString(@"Ascender", nil);
    ascenderMetricView.metricValueBlock = ^(UIFont *font) {
        return [NSString stringWithFormat:@"%@ pt", [self.pointSizeNumberFormatter stringFromNumber:@(font.ascender)]];
    };

    TWTFontMetricView *descenderMetricView = [[TWTFontMetricView alloc] init];
    descenderMetricView.metricName = NSLocalizedString(@"Descender", nil);
    descenderMetricView.metricValueBlock = ^(UIFont *font) {
        return [NSString stringWithFormat:@"%@ pt", [self.pointSizeNumberFormatter stringFromNumber:@(font.descender)]];
    };

    TWTFontMetricView *lineHeightMetricView = [[TWTFontMetricView alloc] init];
    lineHeightMetricView.metricName = NSLocalizedString(@"Line height", nil);
    lineHeightMetricView.metricValueBlock = ^(UIFont *font) {
        return [NSString stringWithFormat:@"%@", [self.pointSizeNumberFormatter stringFromNumber:@(font.lineHeight)]];
    };

    TWTFontMetricView *lineHeightMultiplierMetricView = [[TWTFontMetricView alloc] init];
    lineHeightMultiplierMetricView.metricName = NSLocalizedString(@"Line height multiplier", nil);
    lineHeightMultiplierMetricView.metricValueBlock = ^(UIFont *font) {
        return [NSString stringWithFormat:@"%@", [self.pointSizeNumberFormatter stringFromNumber:@(font.lineHeight / font.pointSize)]];
    };

    TWTFontMetricView *ascenderRatioMetricView = [[TWTFontMetricView alloc] init];
    ascenderRatioMetricView.metricName = NSLocalizedString(@"Ascender / point size", nil);
    ascenderRatioMetricView.metricValueBlock = ^(UIFont *font) {
        return [NSString stringWithFormat:@"%@", [self.pointSizeNumberFormatter stringFromNumber:@(font.ascender / font.pointSize)]];
    };

    TWTFontMetricView *descenderRatioMetricView = [[TWTFontMetricView alloc] init];
    descenderRatioMetricView.metricName = NSLocalizedString(@"Descender / point size", nil);
    descenderRatioMetricView.metricValueBlock = ^(UIFont *font) {
        return [NSString stringWithFormat:@"%@", [self.pointSizeNumberFormatter stringFromNumber:@(font.descender / font.pointSize)]];
    };

    self.metricViews = @[ sizeMetricView, ascenderMetricView, descenderMetricView, lineHeightMetricView, lineHeightMultiplierMetricView, ascenderRatioMetricView, descenderRatioMetricView ];

    for (TWTFontMetricView *metricView in self.metricViews) {
        metricView.translatesAutoresizingMaskIntoConstraints = NO;
        [contentView addSubview:metricView];
    }

    NSInteger index = 0;
    for (TWTFontMetricView *metricView in self.metricViews.reverseObjectEnumerator) {
        metricView.backgroundColor = (index % 2) == 0 ? [UIColor colorWithWhite:0.9 alpha:1.0] : [UIColor whiteColor];
        index++;
    }

    UILabel *label = [[UILabel alloc] init];
    label.text = self.userDefaults.previewText;
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:label];
    self.label = label;

    NSDictionary *views = NSDictionaryOfVariableBindings(scrollView);
    [self.view twt_addConstraintsWithVisualFormatStrings:@[ @"H:|[scrollView]|",
                                                            @"V:|[scrollView]|" ]
                                                   views:views];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:contentView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0.0]];

    views = NSDictionaryOfVariableBindings(contentView);
    [scrollView twt_addConstraintsWithVisualFormatStrings:@[ @"H:|[contentView]|",
                                                             @"V:|[contentView]|" ]
                                                    views:views];

    UIView *previousView = contentView;
    NSLayoutAttribute attribute = NSLayoutAttributeTop;
    for (UIView *metricView in self.metricViews) {
        views = NSDictionaryOfVariableBindings(metricView);
        [contentView twt_addConstraintsWithVisualFormatStrings:@[ @"H:|[metricView]|" ]
                                                         views:views];
        [contentView addConstraint:[NSLayoutConstraint constraintWithItem:metricView
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:previousView
                                                                attribute:attribute
                                                               multiplier:1.0
                                                                 constant:0.0]];
        previousView = metricView;
        attribute = NSLayoutAttributeBottom;
    }

    views = NSDictionaryOfVariableBindings(label);
    [contentView twt_addConstraintsWithVisualFormatStrings:@[ @"H:|-15-[label]-15-|", @"V:[label]-|" ]
                                                     views:views];

    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:previousView
                                                            attribute:attribute
                                                           multiplier:1.0
                                                             constant:20.0]];

    [self updateFont];
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    CGRect frame = self.fontSizeSlider.frame;
    frame.size.width = CGRectGetWidth(self.view.bounds) - 30.0;
    self.fontSizeSlider.frame = frame;
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
        _pointSizeNumberFormatter.maximumFractionDigits = 2;
    }

    return _pointSizeNumberFormatter;
}


- (TWTUserDefaults *)userDefaults
{
    if (!_userDefaults) {
        _userDefaults = [[TWTUserDefaults alloc] init];
    }
    return _userDefaults;
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


- (void)editButtonTapped
{
    TWTTextEditorViewController *viewController = [[TWTTextEditorViewController alloc] init];
    viewController.title = NSLocalizedString(@"Edit Preview", nil);
    viewController.text = self.label.text;

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];

    if (TWTUserInterfaceIdiomIsPad()) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }

    [self presentViewController:navigationController animated:YES completion:nil];

    // It is possible for self to be popped off the navigation stack if all fonts
    // in the current family are deleted. Keeping a strong reference directly to
    // the presenting view controller allows the dismiss to work anyway.
    UIViewController *presentingViewController = viewController.presentingViewController;

    __weak typeof(viewController) weakViewController = viewController;
    viewController.twt_completion = ^(BOOL finished) {
        if (finished) {
            self.label.text = weakViewController.text;
            self.userDefaults.previewText = weakViewController.text;
        }
        [presentingViewController dismissViewControllerAnimated:YES completion:nil];
    };
}


#pragma mark - Helpers

- (void)updateFont
{
    UIFont *font = [UIFont fontWithName:self.fontName ?: kDefaultFontName size:self.fontSize];

    self.title = font.fontName;
    self.label.font = font;

    for (TWTFontMetricView *metricView in self.metricViews) {
        metricView.font = font;
    }
}

@end
