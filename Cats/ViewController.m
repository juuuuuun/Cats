//
//  ViewController.m
//  Cats
//
//  Created by Jun Oh on 2019-01-24.
//  Copyright © 2019 Jun Oh. All rights reserved.
//

#import "ViewController.h"
#import "Photo.h"
#import "PhotoCollectionViewCell.h"

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *photoCollection;

@property (nonatomic) NSMutableArray<Photo *>* allPhotos;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UICollectionViewFlowLayout* photoLayout = [[UICollectionViewFlowLayout alloc] init];
    
    self.photoCollection.delegate = self;
    self.photoCollection.dataSource = self;
    self.photoCollection.collectionViewLayout = photoLayout;
    
    NSURLRequest* photoListRequest = [self constructURLRequestForPhotoList];
    [self makeRequestForPhotoList:photoListRequest];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.frame.size.width/3.0, self.view.frame.size.width/3.0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PhotoCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
    
    cell.titleLabel.text = self.allPhotos[indexPath.row].title;
    [self requestPhoto:self.allPhotos[indexPath.row] forCell:cell];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.allPhotos.count;
}

- (void)requestPhoto:(Photo *)photo forCell:(PhotoCollectionViewCell *)cell{
    NSURL *url = photo.photoURL;
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDownloadTask *downloadTask = [urlSession downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) { // 1
            // Handle the error
            NSLog(@"error: %@", error.localizedDescription);
            return;
        }
        
        NSData *data = [NSData dataWithContentsOfURL:location];
        UIImage *image = [UIImage imageWithData:data]; // 2
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // This will run on the main queue
            
            cell.imageView.image = image; // 4
        }];
    }]; // 4
    
    [downloadTask resume]; // 5
}

- (NSMutableURLRequest *)constructURLRequestForPhotoList {
    NSString *method = @"GET";
    NSString *uri = @"https://api.flickr.com/";
    NSString *path = @"services/rest/";
    NSString *apiMethod = @"?method=flickr.photos.search&format=json&nojsoncallback=1";
    NSString *apiKey = @"&api_key=12a5adb121690c2ac6df6e5bf88da69f";
    NSString *searchTerm = @"&tags=cat";
    
    // Just the URL
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@", uri, path, apiMethod, apiKey, searchTerm]];
    
    // The URL and all of the other HTTP options
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    urlRequest.URL = url;
    urlRequest.HTTPMethod = method;
    
    return urlRequest;
}

- (void)makeRequestForPhotoList:(NSURLRequest *)urlRequest {
    // setup the url session object
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config];
    
    // create a data task object from the url session
    // This is the thing that makes the HTTP request
    NSURLSessionDataTask *task = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"Request error: %@", error);
            return;
        }
        
        NSError *jsonError;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError) {
            NSLog(@"JSON error: %@", jsonError);
            return;
        }
        
        
        self.allPhotos = [NSMutableArray array];
        
        NSDictionary *photos = json[@"photos"];
        NSArray *photo = photos[@"photo"];
        for(NSDictionary* photoInfo in photo) {
            NSString *urlString = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@.jpg", photoInfo[@"farm"], photoInfo[@"server"], photoInfo[@"id"], photoInfo[@"secret"]];
            
            Photo* photoToAdd = [[Photo alloc] initWithPhotoURL: [NSURL URLWithString: urlString] andTitle:photoInfo[@"title"]];
            
            [self.allPhotos addObject:photoToAdd];
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.photoCollection reloadData];
        }];
    }];
    
    // resume teh data task
    [task resume];
    
    // here i have access to the data.
}


@end
