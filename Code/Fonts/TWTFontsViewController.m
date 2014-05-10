//
//  TWTFontsViewController.m
//  Fonts
//
//  Created by Andrew Hershberger on 2/19/14.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import "TWTFontsViewController.h"

#import "TWTEnvironment.h"
#import "TWTFontLoader.h"
#import "TWTFontPreviewViewController.h"
#import "UIFontDescriptor+Fonts.h"


NSString *const kTWTFontsViewControllerSelectedFontNameDidChangeNotification = @"TWTFontsViewControllerSelectedFontNameDidChange";
NSString *const kTWTFontsViewControllerSelectedFontNameKey = @"TWTFontsViewControllerSelectedFontName";


static NSString *const kCellIdentifier = @"font cell";


@interface TWTFontsViewController ()

@property (nonatomic, copy) NSArray *fontNames;

@property (nonatomic, copy) NSString *selectedFontName;

@property (nonatomic, weak) UILabel *webServerURLLabel;

@end


@implementation TWTFontsViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {

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


- (void)reloadFontNames
{
    self.fontNames = [[UIFont fontNamesForFamilyName:self.familyName] sortedArrayUsingComparator:^NSComparisonResult(NSString *fontName1, NSString *fontName2) {
        NSString *face1 = [UIFontDescriptor twt_faceForFontName:fontName1];
        NSString *face2 = [UIFontDescriptor twt_faceForFontName:fontName2];
        return [face1 localizedCaseInsensitiveCompare:face2];
    }];

    self.selectedFontName = [self.fontNames firstObject];

    if (self.isViewLoaded) {
        [self.tableView reloadData];
    }
}


- (void)updateWebServerURLLabel
{
    NSString *urlString = [[[TWTFontLoader sharedInstance] webServerURL] absoluteString];
    self.webServerURLLabel.text = urlString ?: nil;
    [self.webServerURLLabel sizeToFit];
}


#pragma mark - Property Accessors

- (void)setFamilyName:(NSString *)familyName
{
    _familyName = [familyName copy];

    self.title = _familyName;

    [self reloadFontNames];
}


- (void)setFontNames:(NSArray *)fontNames
{
    _fontNames = [fontNames copy];

    if (![_fontNames containsObject:self.selectedFontName]) {
        self.selectedFontName = [_fontNames firstObject];
    }
}


- (void)setSelectedFontName:(NSString *)selectedFontName
{
    if (TWTUserInterfaceIdiomIsPad() && self.isViewLoaded) {
        NSInteger index = (NSInteger)[self.fontNames indexOfObject:_selectedFontName];

        if (index != NSNotFound) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }

    _selectedFontName = [selectedFontName copy];

    if (TWTUserInterfaceIdiomIsPad() && self.isViewLoaded) {
        NSInteger index = (NSInteger)[self.fontNames indexOfObject:_selectedFontName];

        if (index != NSNotFound) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }

    NSDictionary *userInfo = nil;
    if (_selectedFontName) {
        userInfo = @{ kTWTFontsViewControllerSelectedFontNameKey : _selectedFontName };
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kTWTFontsViewControllerSelectedFontNameDidChangeNotification
                                                        object:self
                                                      userInfo:userInfo];
}


#pragma mark - Notification Handlers

- (void)fontLoaderDidChangeFonts:(NSNotification *)notification
{
    [self reloadFontNames];

    if (self.fontNames.count == 0) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }

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
    return self.fontNames.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *fontName = self.fontNames[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [UIFontDescriptor twt_faceForFontName:fontName];
    if (TWTUserInterfaceIdiomIsPad()) {
        cell.accessoryType = (  [fontName isEqualToString:self.selectedFontName]
                              ? UITableViewCellAccessoryCheckmark
                              : UITableViewCellAccessoryNone );
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedFontName = self.fontNames[indexPath.row];

    if (TWTUserInterfaceIdiomIsPad()) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else {
        TWTFontPreviewViewController *fontPreviewViewController = [[TWTFontPreviewViewController alloc] init];
        fontPreviewViewController.fontName = self.selectedFontName;
        [self.navigationController pushViewController:fontPreviewViewController animated:YES];
    }
}

@end
