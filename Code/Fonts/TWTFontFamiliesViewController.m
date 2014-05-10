//
//  TWTFontFamiliesViewController.m
//  Fonts
//
//  Created by Andrew Hershberger on 2/19/14.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import "TWTFontFamiliesViewController.h"

#import "TWTFontLoader.h"
#import "TWTFontsViewController.h"


static NSString *const kCellIdentifier = @"family cell";


@interface TWTFontFamiliesViewController ()

@property (nonatomic, copy) NSArray *familyNames;

@property (nonatomic, weak) UILabel *webServerURLLabel;

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

        UIBarButtonItem *webServerURLItem = [[UIBarButtonItem alloc] initWithCustomView:[[UILabel alloc] init]];
        _webServerURLLabel = (UILabel *)webServerURLItem.customView;
        [self updateWebServerURLLabel];

        self.toolbarItems = @[ webServerURLItem ];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fontLoaderDidChangeFonts:)
                                                     name:kTWTFontLoaderDidChangeFontsNotification
                                                   object:[TWTFontLoader sharedInstance]];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fontLoaderDidStartWebServer:)
                                                     name:kTWTFontLoaderDidStartWebServerNotification
                                                   object:[TWTFontLoader sharedInstance]];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fontLoaderDidStopWebServer:)
                                                     name:kTWTFontLoaderDidStopWebServerNotification
                                                   object:[TWTFontLoader sharedInstance]];
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


- (void)updateWebServerURLLabel
{
    NSString *urlString = [[[TWTFontLoader sharedInstance] webServerURL] absoluteString];
    self.webServerURLLabel.text = urlString ?: nil;
    [self.webServerURLLabel sizeToFit];
}


#pragma mark - Notification Handlers

- (void)fontLoaderDidChangeFonts:(NSNotification *)notification
{
    self.familyNames = [[UIFont familyNames] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    if (self.isViewLoaded) {
        [self.tableView reloadData];
    }
}


- (void)fontLoaderDidStartWebServer:(NSNotification *)notification
{
    [self updateWebServerURLLabel];
}


- (void)fontLoaderDidStopWebServer:(NSNotification *)notification
{
    [self updateWebServerURLLabel];
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
