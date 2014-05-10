//
//  TWTNavigationBarTitleView.m
//  Fonts
//
//  Created by Andrew Hershberger on 5/10/14.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import "TWTNavigationBarTitleView.h"

#import <TWTToast/UIView+TWTConvenientConstraintAddition.h>


@interface TWTNavigationBarTitleView ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *subtitleLabel;

@end


@implementation TWTNavigationBarTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_titleLabel];

        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = [UIFont systemFontOfSize:12.0];
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_subtitleLabel];

        NSDictionary *views = NSDictionaryOfVariableBindings(_titleLabel, _subtitleLabel);
        [self twt_addConstraintsWithVisualFormatStrings:@[ @"H:|[_titleLabel]|",
                                                           @"H:|[_subtitleLabel]|",
                                                           @"V:|->=0-[_titleLabel]->=0-|",
                                                           @"V:|->=0-[_subtitleLabel]->=0-|" ]
                                                  views:views];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0
                                                          constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_subtitleLabel
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0
                                                          constant:0.0]];
    }
    return self;
}


- (void)setTitle:(NSString *)title
{
    _title = [title copy];
    self.titleLabel.text = _title;
}


- (void)setSubtitle:(NSString *)subtitle
{
    _subtitle = [subtitle copy];
    self.subtitleLabel.text = _subtitle;
}


- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize titleLabelSize = [self.titleLabel sizeThatFits:CGSizeZero];
    CGSize subtitleLabelSize = [self.subtitleLabel sizeThatFits:CGSizeZero];
    return CGSizeMake(MAX(titleLabelSize.width, subtitleLabelSize.width), 44.0);
}


- (CGSize)intrinsicContentSize
{
    CGSize titleLabelSize = [self.titleLabel intrinsicContentSize];
    CGSize subtitleLabelSize = [self.subtitleLabel intrinsicContentSize];
    return CGSizeMake(MAX(titleLabelSize.width, subtitleLabelSize.width), 44.0);
}

@end
