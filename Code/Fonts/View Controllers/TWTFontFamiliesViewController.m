//
//  TWTFontFamiliesViewController.m
//  Fonts
//
//  Created by Andrew Hershberger on 2/19/14.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import "TWTFontFamiliesViewController.h"

#import "TWTFontsController.h"
#import "TWTFontsViewController.h"
#import "TWTWebUploader.h"


static NSString *const kCellIdentifier = @"family cell";


@interface TWTFontFamiliesViewController ()

@property (nonatomic, copy) NSArray *familyNames;

@property (nonatomic, weak) UILabel *webUploaderURLLabel;

@end


@implementation TWTFontFamiliesViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _familyNames = [[UIFont familyNames] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:nil
                                                                                action:NULL];

        UIBarButtonItem *webUploaderURLItem = [[UIBarButtonItem alloc] initWithCustomView:[[UILabel alloc] init]];
        _webUploaderURLLabel = (UILabel *)webUploaderURLItem.customView;

        self.toolbarItems = @[ webUploaderURLItem ];

        [self updateWebUploaderURLLabel];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fontsControllerDidChangeFonts:)
                                                     name:kTWTFontsControllerDidChangeFontsNotification
                                                   object:[TWTFontsController sharedInstance]];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(webUploaderDidChangeURL:)
                                                     name:kTWTWebUploaderDidChangeURLNotification
                                                   object:[TWTWebUploader sharedInstance]];
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
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
}


- (void)updateWebUploaderURLLabel
{
    TWTWebUploader *webUploader = [TWTWebUploader sharedInstance];
    self.webUploaderURLLabel.text = webUploader.isRunning ? webUploader.serverURL.absoluteString : nil;
    [self.webUploaderURLLabel sizeToFit];
}


#pragma mark - Notification Handlers

- (void)fontsControllerDidChangeFonts:(NSNotification *)notification
{
    self.familyNames = [[UIFont familyNames] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    if (self.isViewLoaded) {
        [self.tableView reloadData];
    }
}


- (void)webUploaderDidChangeURL:(NSNotification *)notification
{
    [self updateWebUploaderURLLabel];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.familyNames.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = self.familyNames[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TWTFontsViewController *viewController = [[TWTFontsViewController alloc] init];
    viewController.familyName = self.familyNames[indexPath.row];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
