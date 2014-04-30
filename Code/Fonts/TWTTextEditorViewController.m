//
//  TWTTextEditorViewController.m
//  Fonts
//
//  Created by Andrew Hershberger on 4/29/14.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import "TWTTextEditorViewController.h"

#import "UIViewController+Fonts.h"


@interface TWTTextEditorViewController () <UITextViewDelegate>
@property (nonatomic, readonly) UITextView *textView;
@end


@implementation TWTTextEditorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                               target:self
                                                                                               action:@selector(twt_finish)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                              target:self
                                                                                              action:@selector(twt_cancel)];
    }
    return self;
}

- (void)loadView
{
    self.view = [[UITextView alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.textView.text = self.text;
    self.textView.delegate = self;
    self.textView.font = [UIFont systemFontOfSize:16.0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.textView becomeFirstResponder];
}

- (UITextView *)textView
{
    return (UITextView *)self.view;
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.text = textView.text;
}

@end
