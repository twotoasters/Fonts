//
//  TWTFontsViewController.m
//  Fonts
//
//  Created by Andrew Hershberger on 2/19/14.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import "TWTFontsViewController.h"

#import "TWTEnvironment.h"
#import "TWTFontPreviewViewController.h"
#import "TWTFontsController.h"
#import "TWTWebUploader.h"
#import "UIFontDescriptor+Fonts.h"


NSString *const kTWTFontsViewControllerSelectedFontNameDidChangeNotification = @"TWTFontsViewControllerSelectedFontNameDidChange";
NSString *const kTWTFontsViewControllerSelectedFontNameKey = @"TWTFontsViewControllerSelectedFontName";


static NSString *const kCellIdentifier = @"font cell";


@interface TWTFontsViewController ()

@property (nonatomic, copy) NSArray *fontNames;

@property (nonatomic, copy) NSString *selectedFontName;

@property (nonatomic, weak) UILabel *webUploaderURLLabel;

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


- (void)updateWebUploaderURLLabel
{
    TWTWebUploader *webUploader = [TWTWebUploader sharedInstance];
    self.webUploaderURLLabel.text = webUploader.isRunning ? webUploader.serverURL.absoluteString : nil;
    [self.webUploaderURLLabel sizeToFit];
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

- (void)fontsControllerDidChangeFonts:(NSNotification *)notification
{
    [self reloadFontNames];

    if (self.fontNames.count == 0) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }

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
