//
//  TWTFontMetricView.h
//  Fonts
//
//  Created by Andrew Hershberger on 5/6/14.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

@import UIKit;


@interface TWTFontMetricView : UIView

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, copy) NSString *metricName;
@property (nonatomic, copy) NSString *(^metricValueBlock)(UIFont *font);

@end
