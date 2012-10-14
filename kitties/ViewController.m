//
//  ViewController.m
//  kitties
//
//  Created by Koen Romers on 12-10-12.
//  Copyright (c) 2012 Koen Romers. All rights reserved.
//

// External stuff
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"

// Own stuff
#import "Configuration.h"
#import "ApiClient.h"
#import "ViewController.h"
#import "CVCell.h"

@interface ViewController ()

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet UILabel *loading;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSNumber *total;
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSMutableArray *pictures;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation ViewController

// View did load
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set title navigation bar
    self.title = @"Kitties";
    
    // Set size of pictures based on device orientation
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    [self.collectionView registerClass:[CVCell class] forCellWithReuseIdentifier:@"cvCell"];
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    // Set layout
    [self setLayout:([UIDevice currentDevice])];
    
    // Load total amount of photos
    [self loadTotal];
    // Load photos
    [self loadKitties:60 :0];
    
    // Pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    
}
// View appears
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}
// Memory warning!
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    self.collectionView = nil;
    self.photos = nil;
    self.data = nil;
    self.pictures = nil;
    self.total = nil;
}
-(void)handleRefresh:(UIRefreshControl *)refreshControl {
    self.photos = nil;
    self.data = nil;
    self.pictures = nil;
    self.total = nil;
    
    // Load total amount of photos
    [self loadTotal];
    // Load photos
    [self loadKitties:60 :0];
}

// Call API to load total number of photos
- (void)loadTotal {
    [[ApiClient sharedClient] getPath:@"total" parameters:nil success:^(AFHTTPRequestOperation *operation, id json) {
        self.total = [json objectForKey:@"total"];
    } failure:nil];
}
// Call API to load kitties
- (void)loadKitties:(int)limit :(int)skip {
        
    NSString *path = [NSString stringWithFormat:@"/list/%d/%d", limit, skip];
    
    [[ApiClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id json) {
        NSMutableArray *section = [[NSMutableArray alloc] init];
            
        if([self.data count] > 0){
            section = self.data;
        }
        
        for(NSDictionary *photo in [json objectForKey:@"results"]) {
            [section addObject:photo];
        }
            
        self.photos = [[NSArray alloc] initWithObjects:section, nil];
        
        [self.collectionView reloadData];
        
        // Remove loaders
        [self.loading removeFromSuperview];
        [self hideProgressHUD:@"" :NO];
        [self.refreshControl endRefreshing];
    } failure:nil];
}

// Show activity indicator with custom message
- (void)showProgressHUDWithMessage:(NSString *)message {
    
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.progressHUD.labelText = message;
    
    self.navigationController.navigationBar.userInteractionEnabled = NO;
}
// Hide activity indicator with message and icon
- (void)hideProgressHUD:(NSString *)message :(BOOL)error {
    if ([message length] > 0) {
        
        NSString *image = error ? @"err_mark.png" : @"check_mark";
        
        if (self.progressHUD.isHidden) [self.progressHUD show:YES];
        self.progressHUD.labelText = message;
        self.progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:image]];
        self.progressHUD.mode = MBProgressHUDModeCustomView;
        [self.progressHUD hide:YES afterDelay:1.5];
    } else {
        [self.progressHUD hide:YES];
    }
    self.navigationController.navigationBar.userInteractionEnabled = YES;
}

// If orientation is changed
- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    [self setLayout:(device)];
}
// Set layout (image size etc.)
- (void) setLayout:(UIDevice *)device
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = 0;
    CGFloat spacing = 2;
    CGFloat imageSize = 0;
    
    switch(device.orientation) {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationUnknown:
            screenWidth = screenRect.size.width - 2;
            imageSize = (screenWidth / 2);
            break;
            
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            screenWidth = screenRect.size.height - 4;
            imageSize = (screenWidth / 3);
            break;
    };
    
    // Configure layout
    [self.flowLayout setItemSize:CGSizeMake(imageSize, imageSize)];
    [self.flowLayout setMinimumInteritemSpacing:spacing];
    [self.flowLayout setMinimumLineSpacing:spacing];
    [self.flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    [self.collectionView setCollectionViewLayout:self.flowLayout];
    [self.collectionView autoresizingMask];
    [self.collectionView autoresizesSubviews];
    // Set background pattern
    [self.collectionView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern.png"]]];
}
// Number of sections in collection view
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.photos count];
}
// Number of items in section
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    self.data = [self.photos objectAtIndex:section];
    return [self.data count];
}
// Put stuff in each cell/item
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Setup cell identifier
    static NSString *cellIdentifier = @"cvCell";
    CVCell *cell = (CVCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // Get photo
    NSDictionary *photo = [self.data objectAtIndex:[indexPath row]];

    // Set image of cell
    [cell.photo setImageWithURL:[NSURL URLWithString:[photo objectForKey:@"thumbnail"]] success:^(UIImage *image) {
        [cell.loading removeFromSuperview];
    } failure:^(NSError *error) {
        [cell.loading removeFromSuperview];
    }];
    
    return cell;
}
// When you tap a kitty
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // Set pictures for MWPhotoBrowser
    NSMutableArray *pictures = [[NSMutableArray alloc] init];
    
    for(NSDictionary *picture in self.data) {
        MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:[picture objectForKey:@"image"]]];
        photo.caption = [picture objectForKey:@"name"];
        [pictures addObject:photo];
    }
    
    self.pictures = pictures;
    
    // Load MWPhotoBrowser
    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    [photoBrowser setInitialPageIndex:[indexPath row]];
    photoBrowser.displayActionButton = YES;
    
    // Action button for detail view of MWPhotoBrowser
    photoBrowser.actionButtons = [NSArray arrayWithObjects:NSLocalizedString(@"Save", nil), nil];
    photoBrowser.destructiveButton = NSLocalizedString(@"Report", nil);
    photoBrowser.cancelButton = NSLocalizedString(@"Cancel", nil);
    
    // Push MWPhotoBrowser to navigation controller
    [self.navigationController pushViewController:photoBrowser animated:YES];

}
// Number of photos in MWPhotoBrowser
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return [self.pictures count];
}
// Define index of chosen image in MWPhotoBrowser
- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < [self.pictures count])
        return [self.pictures objectAtIndex:index];
    return nil;
}
// Handle action sheet of image detail in MWPhotoBrowser
- (void) photoBrowser:(MWPhotoBrowser *)photoBrowser actionIndex:(NSUInteger)index :(NSUInteger)photoIndex {
    switch(index){
        case 0:
            // Report image
            [self reportImage:(photoIndex)];
            break;
        case 1:
            // Save image
            [self saveImage:(photoIndex)];
            break;
    }
}
// Save image to photo album on device
- (void) saveImage:(NSUInteger)photoIndex {
    
    [self showProgressHUDWithMessage:@"Saving kitty..."];
    
    id <MWPhoto> photo = [self.pictures objectAtIndex:photoIndex];
    UIImageWriteToSavedPhotosAlbum([photo underlyingImage], self, @selector(saveImageCallback:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:),NULL);
}
// Callback for saving image to photo album
- (void)saveImageCallback:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo {
    if(error){
        [self hideProgressHUD:@"Error!" :YES];
    } else {
        [self hideProgressHUD:@"Kitty saved!" :NO];
    }
}
// Report image
- (void) reportImage:(NSUInteger)pageIndex {
    
    [self showProgressHUDWithMessage:@"Reporting kitty..."];
    
    NSDictionary *photo = [self.data objectAtIndex:pageIndex];
    
    NSString *path = [NSString stringWithFormat:@"/%@", [photo objectForKey:@"externalID"]];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: @"true", @"reported",nil];
    [[ApiClient sharedClient] putPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id json){
        [self hideProgressHUD:@"Kitty reported!" :NO];
    } failure:nil];
    
}

// If user has reached the end of the collection view
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    CGFloat height = scrollView.frame.size.height;
    CGFloat contentYoffset = scrollView.contentOffset.y;
    CGFloat distanceFromBottom = scrollView.contentSize.height - contentYoffset;

    if(distanceFromBottom - 50 < height) {
        if([self.data count] < [self.total intValue]){
            [self showProgressHUDWithMessage:@"Loading more kitties..."];
            [self loadKitties:60 :[self.data count]];
        }
    }
}

//// If user has reached the end of the collection view
//-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    CGFloat height = scrollView.frame.size.height;
//    CGFloat contentYoffset = scrollView.contentOffset.y;
//    CGFloat distanceFromBottom = scrollView.contentSize.height - contentYoffset;
//
//    if(distanceFromBottom < height) {
//        
//        [self showProgressHUDWithMessage:@"Loading more kitties..."];
//        
//        [self loadKitties:60 :[self.data count]];
//        
//    }
//}

@end
