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
#import "InfoViewController.h"

@interface ViewController ()

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet UILabel *loading;
@property (nonatomic, strong) UIPickerView *sortPicker;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSNumber *total;
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSMutableArray *pictures;
@property (nonatomic, strong) NSMutableArray *sortOptions;
@property (nonatomic, strong) NSString *sorting;
@property (nonatomic, strong) NSString *previousSorting;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, assign) BOOL allowedToLoadMore;
@property (nonatomic, assign) BOOL scrollToTop;
@property (nonatomic, assign) BOOL sortingHidden;
@property (nonatomic, assign) BOOL navigationBarHidden;
@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) CGFloat screenHeight;
@property (nonatomic, assign) CGFloat imageWidth;
@property (nonatomic, assign) CGFloat imageHeight;
@property (nonatomic, assign) CGFloat startContentOffset;
@property (nonatomic, assign) CGFloat lastContentOffset;
@property (nonatomic, assign) CGRect sortPickerShownFrame;
@property (nonatomic, assign) CGRect sortPickerHiddenFrame;

@end

@implementation ViewController

// View did load
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set screensizes
    [self setScreenSizes];
    
    // Setup sort pickerview
    [self initSortPicker];
    
    // Set layout
    [self setLayout];
    
    // Allowed to load
    [self setAllowedToLoadMore:YES];
    
    // By default scroll to top false
    [self setScrollToTop:NO];
    
    // Setup navigationbar
    [self setupNavigationBar];
    
    // Set size of pictures based on device orientation
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    [self.collectionView registerClass:[CVCell class] forCellWithReuseIdentifier:@"cvCell"];
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    // Load total amount of photos
    [self loadTotal];
    // Load photos
    [self loadKitties:[[[Configuration sharedInstance] NumberOfKitties] intValue] :0];
    
    // Pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    
}

// Memory warning!
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// If orientation is changed
- (void) orientationChanged:(NSNotification *)note {
    [self setScreenSizes];
    [self setLayout];
    [self setSortPickerSizes];
}
// Set screensizes based on orientation
-(void) setScreenSizes {
    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    
    switch(orientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            self.screenWidth = screenRect.size.width;
            self.screenHeight = screenRect.size.height;
            self.imageWidth = (self.screenWidth - 2) / 3;
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            self.screenWidth = screenRect.size.height;
            self.screenHeight = screenRect.size.width;
            self.imageWidth = (self.screenWidth - 4) / 5;
            break;
    };
    self.imageHeight = self.imageWidth;
}

// Init picker
- (void)initSortPicker {
    
    // Set up the initial state of the picker.
    [self setSortingHidden:YES];
    self.sortPicker = [[UIPickerView alloc] init];
    [self.sortPicker setDelegate:self];
    [self.sortPicker setDataSource:self];
    [self.sortPicker setShowsSelectionIndicator:YES];
    [self setSortPickerSizes];
    [self.view addSubview:self.sortPicker];
    
    // Add options to sort picker
    self.sortOptions = [[NSMutableArray alloc] init];
    [self.sortOptions addObject:@"Sort by date"];
    [self.sortOptions addObject:@"Sort by popularity"];
    
    // Default sorting
    [self setSorting:@"Sort by date"];
    [self setPreviousSorting:self.sorting];
}

-(void)setSortPickerSizes {
    
    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
    
    if(self.navigationBarHidden){
        navBarHeight = 0;
    }
    
    CGFloat pickerHeight = self.sortPicker.frame.size.height;
    CGFloat pickerXShown = self.screenHeight - navBarHeight - pickerHeight;
    CGFloat pickerXHidden = self.screenHeight - navBarHeight;
    
    // Set pickerView's shown and hidden position frames.
    self.sortPickerShownFrame = CGRectMake(0.f, pickerXShown, self.screenWidth, pickerHeight);
    self.sortPickerHiddenFrame = CGRectMake(0.f, pickerXHidden, self.screenWidth, pickerHeight);
    
    if(self.sortingHidden){
        [self.sortPicker setFrame:self.sortPickerHiddenFrame];
    } else {
        [self.sortPicker setFrame:self.sortPickerShownFrame];
    }
}

- (void)setupNavigationBar {
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStyleBordered target:self action:@selector(showInfo:)]];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Sort" style:UIBarButtonItemStyleBordered target:self action:@selector(sortKitties:)]];
    
    // Set title navigation bar
    [self setTitle:@"Kitties"];
}

// Push info view
-(void)showInfo: (UIBarButtonItem *)sender {
    UIViewController *infoViewController = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:nil];
    [self.navigationController presentViewController:infoViewController animated:NO completion:nil];
    [self.navigationController dismissViewControllerAnimated:NO completion: nil];
    [self.navigationController pushViewController:infoViewController animated:YES];
}

// Sort kitties
-(void)sortKitties: (UIBarButtonItem *)sender {
    // sortPicker is always visible, but outside the screen
    [self.sortPicker setHidden:NO];
    
    if(self.sortingHidden){
        [self showPickerView];
    } else {
        [self hidePickerView];
        
        if(self.sorting != self.previousSorting){
            [self setPreviousSorting:self.sorting];
            
            [self setScrollToTop:YES];
            [self showProgressHUDWithMessage:@"Sorting kitties..."];
            [self reloadKitties];
        }
    }
}
- (void) hidePickerView {
    if(self.sortingHidden) {
        return;
    }
    [self.navigationItem.leftBarButtonItem setTitle:@"Sort"];
    [UIView animateWithDuration:0.33 animations:^{
        [self.sortPicker setFrame:self.sortPickerHiddenFrame];
    } completion:nil];
    [self setSortingHidden:YES];
}
- (void) showPickerView {
    if(!self.sortingHidden) {
        return;
    }
    [self.navigationItem.leftBarButtonItem setTitle:@"Done"];
    [UIView animateWithDuration:0.33 animations:^{
        [self.sortPicker setFrame:self.sortPickerShownFrame];
    } completion:nil];
    [self setSortingHidden:NO];
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self setSorting:[self.sortOptions objectAtIndex:row]];
    
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.sortOptions count];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.sortOptions objectAtIndex:row];
}

// Load kitties again!
-(void)handleRefresh:(UIRefreshControl *)refreshControl {
    [self reloadKitties];
}

-(void)reloadKitties {
    self.photos = nil;
    self.data = nil;
    self.pictures = nil;
    self.total = nil;
    
    // Load total amount of photos
    [self loadTotal];
    // Load photos
    [self loadKitties:[[[Configuration sharedInstance] NumberOfKitties] intValue] :0];
}

// Call API to load total number of photos
- (void)loadTotal {
    [[ApiClient sharedClient] getPath:@"total" parameters:nil success:^(AFHTTPRequestOperation *operation, id json) {
        [self setTotal:[json objectForKey:@"total"]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (error){
            [self showNetworkError:error];
        }
    }];
}
// Call API to load kitties
- (void)loadKitties:(int)limit :(int)skip {
    
    [self.navigationController.navigationBar setUserInteractionEnabled:NO];
    [self setAllowedToLoadMore:NO];
    [self.collectionView setUserInteractionEnabled:NO];
    
    // Check for sorting
    NSString *sortMethod = @"";
    if(self.sorting == @"Sort by popularity"){
        sortMethod = @"interestingness";
    }
    
    NSString *path = [NSString stringWithFormat:@"/list/%d/%d", limit, skip];
    if(![sortMethod isEqualToString:@""]){
        path = [NSString stringWithFormat:@"%@?sort=%@",path, sortMethod];
    }
    
    [[ApiClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id json) {
        NSMutableArray *section = [[NSMutableArray alloc] init];
        
        if([self.data count] > 0){
            section = self.data;
        }
        
        for(NSDictionary *photo in [json objectForKey:@"results"]) {
            [section addObject:photo];
        }
        
        [self setPhotos:[[NSArray alloc] initWithObjects:section, nil]];
        
        [self.collectionView reloadData];
        
        // Remove loaders
        [self.loading removeFromSuperview];
        [self hideProgressHUD:@"" :NO];
        [self.refreshControl endRefreshing];
        
        // If scroll to top, scroll to top
        if(self.scrollToTop){
            [self.collectionView setContentOffset: CGPointZero];
            [self setScrollToTop:NO];
        }
        
        // Enable interaction again
        [self.navigationController.navigationBar setUserInteractionEnabled:YES];
        [self setAllowedToLoadMore:YES];
        [self.collectionView setUserInteractionEnabled:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (error){
            [self showNetworkError:error];
        }
    }];
}

// Show error message
- (void)showNetworkError:(NSError *)error {
    // Hide other loaders
    [self.loading removeFromSuperview];
    [self.refreshControl endRefreshing];
    [self hideProgressHUD:@"" :NO];
    // Show error
    [self setProgressHUD:[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES]];
    [self.progressHUD setLabelText:@"Network error!"];
    [self.progressHUD setCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"err_mark"]]];
    [self.progressHUD setMode:MBProgressHUDModeCustomView];
    
    NSLog(@"%@", [error localizedDescription]);
}

// Show activity indicator with custom message
- (void)showProgressHUDWithMessage:(NSString *)message {
    
    [self setProgressHUD:[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES]];
    [self.progressHUD setLabelText:message];
    
    [self.navigationController.navigationBar setUserInteractionEnabled:NO];
}
// Hide activity indicator with message and icon
- (void)hideProgressHUD:(NSString *)message :(BOOL)error {
    if ([message length] > 0) {
        
        NSString *image = error ? @"err_mark" : @"check_mark";
        
        if (self.progressHUD.isHidden) [self.progressHUD show:YES];
        [self.progressHUD setLabelText:message];
        [self.progressHUD setCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:image]]];
        [self.progressHUD setMode:MBProgressHUDModeCustomView];
        [self.progressHUD hide:YES afterDelay:1.5];
    } else {
        [self.progressHUD hide:YES];
    }
    [self.navigationController.navigationBar setUserInteractionEnabled:YES];
}

// Set layout
- (void) setLayout {
    
    CGFloat spacing = 1;
    
    // Configure layout
    [self.flowLayout setItemSize:CGSizeMake(self.imageWidth,self.imageHeight)];
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
    
    // Hide picker view
    [self hidePickerView];
    
    // Set pictures for MWPhotoBrowser
    NSMutableArray *pictures = [[NSMutableArray alloc] init];
    
    for(NSDictionary *picture in self.data) {
        MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:[picture objectForKey:@"image"]]];
        [photo setCaption:[picture objectForKey:@"name"]];
        [pictures addObject:photo];
    }
    
    self.pictures = pictures;
    
    // Load MWPhotoBrowser
    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    [photoBrowser setInitialPageIndex:[indexPath row]];
    [photoBrowser setDisplayActionButton:YES];
    
    // Action button for detail view of MWPhotoBrowser
    [photoBrowser setActionButtons:[NSArray arrayWithObjects:NSLocalizedString(@"Share", nil), nil]];
    [photoBrowser setDestructiveButton:@"Report"];
    [photoBrowser setCancelButton:@"Cancel"];
    
    // Push MWPhotoBrowser to navigation controller
    [self.navigationController pushViewController:photoBrowser animated:YES];
    
    // Show navigationbar again
    //    [self showNavigationBar:YES];
    
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
            // Share
            [self showActivityView:photoIndex];
            break;
        case 1:
            // Report image
            [self reportImage:(photoIndex)];
            break;
    }
}

-(void) showActivityView:(NSUInteger)photoIndex {
    id <MWPhoto> photo = [self.pictures objectAtIndex:photoIndex];
    NSArray *activityItems = @[@"Check this cute kitty I found thanks to the Kitties app!", [photo underlyingImage]];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    
    [activityController setExcludedActivityTypes:@[UIActivityTypeAssignToContact,UIActivityTypePrint,UIActivityTypePostToWeibo]];
    
    [activityController setCompletionHandler:^(NSString *activityType, BOOL completed) {
        if(completed){
            // Increase interestingness
            [self increaseInterestingness:photoIndex];
        }
    }];
    
    [self presentViewController:activityController animated:YES completion:nil];
}

// Save image to photo album on device
- (void) saveImage:(NSUInteger)photoIndex {
    
    [self showProgressHUDWithMessage:@"Saving kitty..."];
    
    // Increase interestingness
    [self increaseInterestingness:photoIndex];
    
    // Get photo and save it!
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

// Increase interestingness for this picture
- (void) increaseInterestingness:(NSUInteger)photoIndex {
    // Get json of photo based on index
    NSDictionary *photo = [self.data objectAtIndex:photoIndex];
    // Set new interestingness
    NSNumber *newInterestingness = [NSNumber numberWithInteger:([[photo objectForKey:@"interestingness"] intValue] + [[[Configuration sharedInstance] IncreaseOfInterestingness] intValue])];
    // Path to call
    NSString *path = [NSString stringWithFormat:@"/%@", [photo objectForKey:@"externalID"]];
    // Params
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: newInterestingness, @"interestingness",nil];
    // Call api!
    [[ApiClient sharedClient] putPath:path parameters:params success:nil failure:nil];
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

- (void) hideNavigationBar:(BOOL)animated {
    if(self.navigationBarHidden) {
        return;
    }
    
    [self setNavigationBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [self hidePickerView];
    [self setSortPickerSizes];
    [self.collectionView reloadData];
}

- (void) showNavigationBar:(BOOL)animated {
    if(!self.navigationBarHidden) {
        return;
    }
    
    [self setNavigationBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    // To prevent showing the viewpicker in the bottom after scrolling up
    [self.sortPicker setHidden:YES];
    [self hidePickerView];
    [self setSortPickerSizes];
    [self.collectionView reloadData];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.startContentOffset = self.lastContentOffset = scrollView.contentOffset.y;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate { }

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView { }

// If user has reached the end of the collection view
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //    CGFloat currentOffset = scrollView.contentOffset.y;
    //    CGFloat differenceFromStart = self.startContentOffset - currentOffset;
    //    CGFloat differenceFromLast = self.lastContentOffset - currentOffset;
    //    [self setLastContentOffset:currentOffset];
    //
    //    if((differenceFromStart) < 0) {
    //        // scroll up
    //        if(scrollView.isTracking && (abs(differenceFromLast)>1)) {
    //            [self hideNavigationBar:YES];
    //        }
    //    } else {
    //        // scroll down
    //        if(scrollView.isTracking && (abs(differenceFromLast)>1)) {
    //            [self showNavigationBar:YES];
    //        }
    //    }
    
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat differenceFromLast = self.lastContentOffset - currentOffset;
    [self setLastContentOffset:currentOffset];
    
    if(scrollView.isTracking && (abs(differenceFromLast)>1)) {
        [self hidePickerView];
    }
    
    if(self.allowedToLoadMore && [self.data count] < [self.total intValue]){
        CGFloat height = scrollView.frame.size.height;
        CGFloat contentYoffset = scrollView.contentOffset.y;
        CGFloat distanceFromBottom = scrollView.contentSize.height - contentYoffset;
        
        if(distanceFromBottom < height) {
            [self showProgressHUDWithMessage:@"Loading more kitties..."];
            [self loadKitties:[[[Configuration sharedInstance] NumberOfKitties] intValue] :[self.data count]];
        }
    }
}

-(BOOL)shouldAutorotate {
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end