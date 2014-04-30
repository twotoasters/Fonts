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


NSString *const kTWTFontsViewControllerSelectedFontNameDidChangeNotification = @"TWTFontsViewControllerSelectedFontNameDidChange";
NSString *const kTWTFontsViewControllerSelectedFontNameKey = @"TWTFontsViewControllerSelectedFontName";


static NSString *const kCellIdentifier = @"font cell";


@interface TWTFontsViewController ()
@property (nonatomic, copy) NSArray *fontNames;
@property (nonatomic, copy) NSString *selectedFontName;
@end


@implementation TWTFontsViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fontLoaderDidOpenFont:)
                                                     name:kTWTFontLoaderDidOpenFontNotification
                                                   object:[TWTFontLoader class]];
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


#pragma mark - Property Accessors

- (void)setFamilyName:(NSString *)familyName
{
    _familyName = [familyName copy];

    self.title = _familyName;

    self.fontNames = [[UIFont fontNamesForFamilyName:familyName] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    self.selectedFontName = [self.fontNames firstObject];

    if (self.isViewLoaded) {
        [self.tableView reloadData];
    }
}


- (void)setSelectedFontName:(NSString *)selectedFontName
{
    if (TWTUserInterfaceIdiomIsPad() && self.isViewLoaded) {
        NSInteger index = (NSInteger)[self.fontNames indexOfObject:_selectedFontName];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    _selectedFontName = [selectedFontName copy];

    if (TWTUserInterfaceIdiomIsPad() && self.isViewLoaded) {
        NSInteger index = (NSInteger)[self.fontNames indexOfObject:_selectedFontName];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kTWTFontsViewControllerSelectedFontNameDidChangeNotification
                                                        object:self
                                                      userInfo:@{ kTWTFontsViewControllerSelectedFontNameKey : _selectedFontName }];
}


#pragma mark - Notification Handlers

- (void)fontLoaderDidOpenFont:(NSNotification *)notification
{
    self.fontNames = [[UIFont fontNamesForFamilyName:self.familyName] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    if (self.isViewLoaded) {
        [self.tableView reloadData];
    }
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
    cell.textLabel.text = fontName;
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
