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
@end


@implementation TWTFontFamiliesViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _familyNames = [[UIFont familyNames] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        self.title = NSLocalizedString(@"Fonts", nil);

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


#pragma mark - Notification Handlers

- (void)fontLoaderDidOpenFont:(NSNotification *)notification
{
    self.familyNames = [[UIFont familyNames] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    if (self.isViewLoaded) {
        [self.tableView reloadData];
    }
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
