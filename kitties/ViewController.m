//
//  ViewController.m
//  kitties
//
//  Created by Koen Romers on 12-10-12.
//  Copyright (c) 2012 Koen Romers. All rights reserved.
//

// External stuff
#import <SDWebImage/UIImageView+WebCache.h>
// Own stuff
#import "Configuration.h"
#import "ViewController.h"
#import "CVCell.h"

@interface ViewController ()

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet UILabel *loading;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@end

@implementation ViewController

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
    
    // Load photos
    [self issueLoadRequest];
}

- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    [self setLayout:(device)];
}

- (void) setLayout:(UIDevice *)device
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = 0;
    CGFloat spacing = 2;
    CGFloat imageSize = 0;
    
    switch(device.orientation)
    {
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

- (void)issueLoadRequest
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        
        NSString *url = [[Configuration sharedInstance] ApiUrl];
        NSString *method = @"list/96";
        NSString *uri = [NSString stringWithFormat: @"%@%@", url, method];
        
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:uri]];
        [self performSelectorOnMainThread:@selector(receiveData:) withObject:data waitUntilDone:YES];
    });
}

- (void)receiveData:(NSData *)data {
    
    id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    NSMutableArray *section = [[NSMutableArray alloc] init];
    
    for(NSDictionary *photo in [json objectForKey:@"results"]) {
        [section addObject:photo];
    }
    
    self.photos = [[NSArray alloc] initWithObjects:section, nil];
    
	[self.collectionView reloadData];
    
    // Remove loader
    [self.loading removeFromSuperview];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    self.collectionView = nil;
    self.photos = nil;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.photos count];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSMutableArray *sectionArray = [self.photos objectAtIndex:section];
    return [sectionArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Setup cell identifier
    static NSString *cellIdentifier = @"cvCell";
    
    CVCell *cell = (CVCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    self.data = [self.photos objectAtIndex:indexPath.section];
    NSDictionary *photo = [self.data objectAtIndex:indexPath.row];
    
    // Set image
    [cell.photo setImageWithURL:[NSURL URLWithString:[photo objectForKey:@"thumbnail"]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    // Set label
    [cell.titleLabel setText:[photo objectForKey:@"name"]];
    //    [cell.titleLabel setFont:[UIFont fontWithName:@"Arial" size: 12]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *photo = [self.data objectAtIndex:indexPath.row];
    
    
    NSLog(@"clicked name is: %@",[photo objectForKey:@"name"]);
    
//    self.detailViewController.photo = [data objectAtIndex:[indexPath row]];
//    
//    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

@end
