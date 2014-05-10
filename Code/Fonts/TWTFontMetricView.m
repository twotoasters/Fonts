//
//  TWTFontMetricView.m
//  Fonts
//
//  Created by Andrew Hershberger on 5/6/14.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import "TWTFontMetricView.h"

#import <TWTToast/UIView+TWTConvenientConstraintAddition.h>


@interface TWTFontMetricView ()

@property (nonatomic, strong) UILabel *metricNameLabel;

@property (nonatomic, strong) UILabel *metricValueLabel;

@end


@implementation TWTFontMetricView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _metricNameLabel = [[UILabel alloc] init];
        _metricNameLabel.font = [UIFont boldSystemFontOfSize:17.0];
        _metricNameLabel.textAlignment = NSTextAlignmentLeft;
        _metricNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_metricNameLabel setContentCompressionResistancePriority:UILayoutPriorityRequired
                                                          forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:_metricNameLabel];

        _metricValueLabel = [[UILabel alloc] init];
        _metricValueLabel.font = [UIFont systemFontOfSize:17.0];
        _metricValueLabel.textAlignment = NSTextAlignmentRight;
        _metricValueLabel.adjustsFontSizeToFitWidth = YES;
        _metricValueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_metricValueLabel];

        NSDictionary *views = NSDictionaryOfVariableBindings(_metricNameLabel, _metricValueLabel);
        [self twt_addConstraintsWithVisualFormatStrings:@[ @"V:|-10-[_metricNameLabel]-10-|",
                                                           @"H:|-15-[_metricNameLabel]->=15-[_metricValueLabel]-15-|" ]
                                                  views:views];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:_metricValueLabel
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_metricNameLabel
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0
                                                          constant:0.0]];
    }
    return self;
}


- (void)updateValueLabel
{
    if (self.metricValueBlock && self.font) {
        self.metricValueLabel.text = self.metricValueBlock(self.font);
    }
    else {
        self.metricValueLabel.text = nil;
    }
}


#pragma mark - Property Accessors

- (void)setFont:(UIFont *)font
{
    _font = font;
    [self updateValueLabel];
}


- (void)setMetricName:(NSString *)metricName
{
    _metricName = [metricName copy];
    self.metricNameLabel.text = metricName;
}


- (void)setMetricValueBlock:(NSString *(^)(UIFont *))metricValueBlock
{
    _metricValueBlock = [metricValueBlock copy];
    [self updateValueLabel];
}

@end
