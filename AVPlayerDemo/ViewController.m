//
//  ViewController.m
//  AVPlayer
//
//  Created by apple on 13-5-19.
//  Copyright (c) 2013年 iMoreApp Inc. All rights reserved.
//

#import "ViewController.h"
#import "PlayerViewController.h"
#import "MovieInfosViewController.h"

@interface ViewController () {
    NSArray *_files;
    NSArray *_networkfiles;
}

@end

@implementation ViewController

- (void)reloadFiles
{
    // Local files
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSLog(@"Document path: %@", docPath);
    
    NSArray *files = [[NSFileManager defaultManager]
                      contentsOfDirectoryAtPath:docPath error:NULL];
    
    NSMutableArray *mediaFiles = [NSMutableArray array];
    for (NSString *f in files) {
        NSString *extname = [[f pathExtension] lowercaseString];
        if ([@[@"avi",@"wmv",@"rmvb",@"flv",@"f4v",@"swf",@"mkv",@"dat",@"vob",@"mts",@"ogg",@"mpg",@"wma"] indexOfObject:extname] != NSNotFound) {
            [mediaFiles addObject:[docPath stringByAppendingPathComponent:f]];
        }
    }
    _files = mediaFiles;
    
    // Network files
    _networkfiles = @[@{@"url":@"rtmp://<your RTMP stream url>",@"title":@"RTMP Stream"},
                      @{@"url":@"rtsp://218.204.223.237:554/live/1/66251FC11353191F/e7ooqwcfbqjoo80j.sdp",@"title":@"RTSP Stream"},
                      @{@"url":@"http://hot.vrs.sohu.com/ipad1407291_4596271359934_4618512.m3u8", @"title":@"HTTP m3u8 Stream"},
                      @{@"url":@"http://live.nwk4.yupptv.tv/nwk4/smil:mtunes.smil/playlist.m3u8", @"title":@"Another HTTP m3u8 Stream"},
                      ];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.navigationItem.rightBarButtonItem =
  [[UIBarButtonItem alloc] initWithTitle:@"Open"
                                   style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(handleOpen:)];
  
    [self reloadFiles];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return _networkfiles.count;
        case 1:
            return _files.count;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileTableCell" forIndexPath:indexPath];
    
    NSString *file = nil;
    
    switch (indexPath.section) {
        case 0:
            file = [_networkfiles objectAtIndex:indexPath.row][@"title"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 1:
            file = [_files objectAtIndex:indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            break;
    }
    cell.textLabel.text = [file lastPathComponent];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Network streams";
        case 1:
            return @"Local files";
        default:
            return nil;
    }
}

#pragma mark - UITableViewDelegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showMoviePlayer"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
        
        UIViewController *controller = segue.destinationViewController;
        if ([controller isKindOfClass:[PlayerViewController class]]) {
            PlayerViewController *playerController = (PlayerViewController *)controller;
            
            switch (indexPath.section) {
                case 0:
                    playerController.mediaPath = [_networkfiles objectAtIndex:indexPath.row][@"url"];
                    break;
                case 1:
                    playerController.mediaPath = [_files objectAtIndex:indexPath.row];
                    break;
            }
        }
    }
    else if ([segue.identifier isEqualToString:@"showMovieInfos"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];

        UIViewController *controller = segue.destinationViewController;
        if ([controller isKindOfClass:[MovieInfosViewController class]]) {
            MovieInfosViewController *infosController = (MovieInfosViewController *)controller;
            
            switch (indexPath.section) {
                case 0:
                    break;
                case 1:
                    infosController.moviePath = [_files objectAtIndex:indexPath.row];
                    break;
            }
        }
    }
}

- (IBAction)refresh:(id)sender {
    
    [self reloadFiles];
    [self.tableView reloadData];
}

- (void)handleOpen:(id)sender {
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"AV Source URL"
                                                      message:nil
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Open", nil];
  alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
  [alertView show];
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
  UITextField *tf = [alertView textFieldAtIndex:0];
  
  tf.text =
  [[NSUserDefaults standardUserDefaults] stringForKey:@"last_url"];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  UITextField *tf = [alertView textFieldAtIndex:0];
  
  if (buttonIndex != alertView.cancelButtonIndex) {
    [[NSUserDefaults standardUserDefaults] setObject:tf.text forKey:@"last_url"];
    
    PlayerViewController *playerController =
    [self.storyboard instantiateViewControllerWithIdentifier:@"playerVC"];
    
    playerController.mediaPath = [tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self presentViewController:playerController animated:YES completion:^{
    }];
  }
}

@end
