//
//  FeaturedVideos.m
//  Clipz
//
//  Created by Dony George on 10/11/14.
//  Copyright (c) 2014 Dony George. All rights reserved.
//

#import "FeaturedVideos.h"
#import "VideoCollectionCell.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "UIScrollView+SVInfiniteScrolling.h"

#import "GADBannerView.h"
#import "GADRequest.h"


#define LIBRARY_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/Clipz"]

@interface FeaturedVideos ()

@end

@implementation FeaturedVideos{
    AAShareBubbles *shareBubbles;
    float radius;
    float bubbleRadius;
}
@synthesize videosArray,categoryString;

int pageNum;
int videoIndex;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    radius = 100;
    bubbleRadius = 30;
    
    _adBanner.adUnitID = @"ca-app-pub-7798040448809933/1305633204";
    _adBanner.rootViewController = self;
    
    GADRequest *request = [GADRequest request];
    [_adBanner loadRequest:request];
    
    pageNum=1;
    videoIndex=0;
    videosArray=[[NSMutableArray alloc] init];
    
    [_videoCollectionView addPullToRefreshWithActionHandler:^{
        
        [self loadVideos:pageNum];
        
    }];
    
    [_videoCollectionView addInfiniteScrollingWithActionHandler:^{
        
        pageNum=pageNum+1;
        [self loadVideos:pageNum];
        
    }];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = .5;
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    [_videoCollectionView addGestureRecognizer:lpgr];
    
    
}


-(void)shareVideo:(int)index{
    
    if(shareBubbles) {
        shareBubbles = nil;
    }
    
    videoIndex=index;
    
    shareBubbles = [[AAShareBubbles alloc] initWithPoint:_videoCollectionView.center radius:radius inView:self.view];
    shareBubbles.delegate = self;
    shareBubbles.bubbleRadius = bubbleRadius;
    shareBubbles.showFacebookBubble = YES;
    shareBubbles.showTwitterBubble = YES;
    shareBubbles.showMailBubble = YES;
    shareBubbles.showWhatsappBubble = YES;
    [shareBubbles show];
    
}




-(void)FBTapped{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *fbPostSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [fbPostSheet setInitialText:[NSString stringWithFormat:@"Check this video - %@",[[videosArray objectAtIndex:videoIndex] valueForKey:@"video_title"]]];
        [fbPostSheet addURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[videosArray objectAtIndex:videoIndex] valueForKey:@"video_link"]]]];
        
        [self imageForURL:[[videosArray objectAtIndex:videoIndex] valueForKey:@"video_thumbnail"] completionBlock:^(UIImage *image) {
            
            [fbPostSheet addImage:image];
            
        }];
        
        [self presentViewController:fbPostSheet animated:YES completion:nil];
    } else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"You can't post right now, make sure your device has an internet connection and you have at least one facebook account setup"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}


-(void)TweetTapped{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:[NSString stringWithFormat:@"Check this video - %@",[[videosArray objectAtIndex:videoIndex] valueForKey:@"video_title"]]];
        [tweetSheet addURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[videosArray objectAtIndex:videoIndex] valueForKey:@"video_link"]]]];
        
        [self imageForURL:[[videosArray objectAtIndex:videoIndex] valueForKey:@"video_thumbnail"] completionBlock:^(UIImage *image) {
            
            [tweetSheet addImage:image];
            
        }];
        [self presentViewController:tweetSheet animated:YES completion:nil];
        
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
    
}




-(void)WhatsappTapped{
    
    
    NSString * msg = [NSString stringWithFormat:@"Check this video - %@",[[videosArray objectAtIndex:videoIndex] valueForKey:@"video_link"]];
    NSString * urlWhats = [NSString stringWithFormat:@"whatsapp://send?text=%@",msg];
    NSURL * whatsappURL = [NSURL URLWithString:[urlWhats stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
    } else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"WhatsApp not installed." message:@"Please install WhatsApp to share." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
}



-(void)MailTapped{
    
    mailComposer = [[MFMailComposeViewController alloc]init];
    mailComposer.mailComposeDelegate = self;
    [mailComposer setSubject:@"Check this video"];
    [mailComposer setMessageBody:[NSString stringWithFormat:@"%@",[[videosArray objectAtIndex:videoIndex] valueForKey:@"video_link"]] isHTML:NO];
    
    [self presentViewController:mailComposer animated:YES completion:nil];
    
    
    
    
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }    [self dismissViewControllerAnimated:YES completion:nil];
    
}




#pragma mark AAShareBubbles

-(void)aaShareBubbles:(AAShareBubbles *)shareBubbles tappedBubbleWithType:(int)bubbleType
{
    switch (bubbleType) {
        case AAShareBubbleTypeFacebook:
            [self FBTapped];
            break;
        case AAShareBubbleTypeTwitter:
            [self TweetTapped];
            break;
        case AAShareBubbleTypeMail:
            [self MailTapped];
            break;
        case AAShareBubbleTypeWhatsapp:
            [self WhatsappTapped];
            break;
        default:
            break;
    }
}

-(void)aaShareBubblesDidHide:(AAShareBubbles*)bubbles {
    NSLog(@"All Bubbles hidden");
}


-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:_videoCollectionView];
    
    NSIndexPath *indexPath = [_videoCollectionView indexPathForItemAtPoint:p];
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    } else {
        NSLog(@"index:%d",indexPath.row);
        //UICollectionViewCell* cell = [_videoCollectionView cellForItemAtIndexPath:indexPath];
        [self shareVideo:indexPath.row];
       
    }
}

- (void)imageForURL:(NSString *)strURL completionBlock:(void(^)(UIImage *image))block {
    
    NSString *folderPath = [LIBRARY_FOLDER stringByAppendingPathComponent:@"Thumbnails"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath]) {
        NSError *error = nil;
        BOOL sucesss = [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (!sucesss) {
            NSLog(@"Fail to create directory : %@",[error description]);
        }
    }
    
    UIImage *image = nil;
    NSString *filePath = [folderPath stringByAppendingPathComponent:[strURL lastPathComponent]];
    if (filePath) {
        image = [UIImage imageWithContentsOfFile:filePath];
    }
    
    if (image) {
        block(image);
    }
    else {
        NSURL *imageURL = [NSURL URLWithString:strURL];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
                       ^{
                           NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                           UIImage *image = [UIImage imageWithData:imageData];
                           if(image) {
                               [imageData writeToFile:filePath atomically:YES];
                               block(image);
                           }
                       });
        imageURL = nil;
    }
}


-(void)loadVideos:(int)pageNo{
    
    
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Loading";
    [HUD showInView:self.view];
    
    _videoCollectionView.userInteractionEnabled=NO;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *urlString=[[NSString alloc] init];
    if ([categoryString isEqualToString:@"1"]) {
        
         urlString=[NSString stringWithFormat:@"https://api.import.io/store/data/4942052d-c5dc-4137-8b63-21255effde32/_query?input/webpage/url=%@&_user=77bb870e-21a8-4077-9dbc-4318cb6f07ea&_apikey=tbIruRemqfpdMqmpWhZS4PGhvD8oEv77DjkX0aKV6EGenEE10Hhb67BrFrQ6uEiiEXitgySAxCQAZ4lGUZeBYA==",[[NSString stringWithFormat:@"http://www.liveleak.com/browse?featured=1&page=%d",pageNum] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  lowercaseLetterCharacterSet]]];
        
    }else if ([categoryString isEqualToString:@"2"]){
        
        urlString=[NSString stringWithFormat:@"https://api.import.io/store/data/4942052d-c5dc-4137-8b63-21255effde32/_query?input/webpage/url=%@&_user=77bb870e-21a8-4077-9dbc-4318cb6f07ea&_apikey=tbIruRemqfpdMqmpWhZS4PGhvD8oEv77DjkX0aKV6EGenEE10Hhb67BrFrQ6uEiiEXitgySAxCQAZ4lGUZeBYA==",[[NSString stringWithFormat:@"http://www.liveleak.com/browse?selection=popular&page=%d",pageNum] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  lowercaseLetterCharacterSet]]];
        
        
    }else if ([categoryString isEqualToString:@"3"]){
        
        urlString=[NSString stringWithFormat:@"https://api.import.io/store/data/4942052d-c5dc-4137-8b63-21255effde32/_query?input/webpage/url=%@&_user=77bb870e-21a8-4077-9dbc-4318cb6f07ea&_apikey=tbIruRemqfpdMqmpWhZS4PGhvD8oEv77DjkX0aKV6EGenEE10Hhb67BrFrQ6uEiiEXitgySAxCQAZ4lGUZeBYA==",[[NSString stringWithFormat:@"http://www.liveleak.com/browse?selection=all&page=%d",pageNum] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  lowercaseLetterCharacterSet]]];
        
        
    }else if ([categoryString isEqualToString:@"4"]){
        
        urlString=[NSString stringWithFormat:@"https://api.import.io/store/data/4942052d-c5dc-4137-8b63-21255effde32/_query?input/webpage/url=%@&_user=77bb870e-21a8-4077-9dbc-4318cb6f07ea&_apikey=tbIruRemqfpdMqmpWhZS4PGhvD8oEv77DjkX0aKV6EGenEE10Hhb67BrFrQ6uEiiEXitgySAxCQAZ4lGUZeBYA==",[[NSString stringWithFormat:@"http://www.liveleak.com/browse?rank_by=day&page=%d",pageNum] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  lowercaseLetterCharacterSet]]];
        
        
    }else if ([categoryString isEqualToString:@"5"]){
        
        urlString=[NSString stringWithFormat:@"https://api.import.io/store/data/4942052d-c5dc-4137-8b63-21255effde32/_query?input/webpage/url=%@&_user=77bb870e-21a8-4077-9dbc-4318cb6f07ea&_apikey=tbIruRemqfpdMqmpWhZS4PGhvD8oEv77DjkX0aKV6EGenEE10Hhb67BrFrQ6uEiiEXitgySAxCQAZ4lGUZeBYA==",[[NSString stringWithFormat:@"http://www.liveleak.com/browse?rank_by=week&page=%d",pageNum] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  lowercaseLetterCharacterSet]]];
        
        
    }else if ([categoryString isEqualToString:@"6"]){
        
        urlString=[NSString stringWithFormat:@"https://api.import.io/store/data/4942052d-c5dc-4137-8b63-21255effde32/_query?input/webpage/url=%@&_user=77bb870e-21a8-4077-9dbc-4318cb6f07ea&_apikey=tbIruRemqfpdMqmpWhZS4PGhvD8oEv77DjkX0aKV6EGenEE10Hhb67BrFrQ6uEiiEXitgySAxCQAZ4lGUZeBYA==",[[NSString stringWithFormat:@"http://www.liveleak.com/browse?rank_by=month&page=%d",pageNum] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  lowercaseLetterCharacterSet]]];
        
        
    }else if ([categoryString isEqualToString:@"7"]){
        
        urlString=[NSString stringWithFormat:@"https://api.import.io/store/data/4942052d-c5dc-4137-8b63-21255effde32/_query?input/webpage/url=%@&_user=77bb870e-21a8-4077-9dbc-4318cb6f07ea&_apikey=tbIruRemqfpdMqmpWhZS4PGhvD8oEv77DjkX0aKV6EGenEE10Hhb67BrFrQ6uEiiEXitgySAxCQAZ4lGUZeBYA==",[[NSString stringWithFormat:@"http://www.liveleak.com/browse?rank_by=all_time&page=%d",pageNum] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  lowercaseLetterCharacterSet]]];
        
        
    }else if ([categoryString isEqualToString:@"8"]){
        
        urlString=[NSString stringWithFormat:@"https://api.import.io/store/data/4942052d-c5dc-4137-8b63-21255effde32/_query?input/webpage/url=%@&_user=77bb870e-21a8-4077-9dbc-4318cb6f07ea&_apikey=tbIruRemqfpdMqmpWhZS4PGhvD8oEv77DjkX0aKV6EGenEE10Hhb67BrFrQ6uEiiEXitgySAxCQAZ4lGUZeBYA==",[[NSString stringWithFormat:@"http://www.liveleak.com/browse?upcoming=1&page=%d",pageNum] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  lowercaseLetterCharacterSet]]];
        
    }
    
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (pageNum==1) {
            [videosArray removeAllObjects];
        }
        

        [videosArray addObjectsFromArray:[responseObject valueForKey:@"results"]];
    
        [HUD dismissAnimated:YES];
        [_videoCollectionView reloadData];
        
        
        [_videoCollectionView.pullToRefreshView stopAnimating];
        [_videoCollectionView.infiniteScrollingView stopAnimating];
        _videoCollectionView.userInteractionEnabled=YES;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HUD dismissAnimated:YES];
        [_videoCollectionView.pullToRefreshView stopAnimating];
        [_videoCollectionView.infiniteScrollingView stopAnimating];
        _videoCollectionView.userInteractionEnabled=YES;
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection view data source

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    
    
    return [videosArray count];
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *videoInfo=[videosArray objectAtIndex:indexPath.row];
    
    static NSString *cellIdentifier = @"VideoCell";
    VideoCollectionCell *cell = (VideoCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell==nil) {
        cell = [(VideoCollectionCell *)[UICollectionViewCell alloc] init];
    }
    
    cell.videoTitle.text=@"";
    cell.videoTitle.text=[videoInfo valueForKey:@"video_title"];
    
    cell.videoImageView.image=nil;
    [self imageForURL:[videoInfo valueForKey:@"video_thumbnail"] completionBlock:^(UIImage *image) {
        
        cell.videoImageView.image=image;
        
    }];
    
    cell.ratingImageView.image=nil;
    [self imageForURL:[videoInfo valueForKey:@"video_rating_image"] completionBlock:^(UIImage *image) {
        
        cell.ratingImageView.image=image;
        
    }];
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *videoInfo=[videosArray objectAtIndex:indexPath.row];
    
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Loading";
    [HUD showInView:self.view];
    
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            NSString *urlString=[NSString stringWithFormat:@"https://api.import.io/store/data/ba3f9266-1065-4c74-bd4c-b8656fae5057/_query?input/http/wwwliveleakcom/viewi886_1415528332=%@&_user=77bb870e-21a8-4077-9dbc-4318cb6f07ea&_apikey=tbIruRemqfpdMqmpWhZS4PGhvD8oEv77DjkX0aKV6EGenEE10Hhb67BrFrQ6uEiiEXitgySAxCQAZ4lGUZeBYA==",[videoInfo valueForKey:@"video_link"]];
    
            [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [HUD dismissAnimated:YES];
                
                NSLog(@"Response:%@",responseObject);
                
                if ([[responseObject valueForKey:@"results"] count]>0) {
                    
                    MPMoviePlayerViewController *player=[[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[[[responseObject valueForKey:@"results"] objectAtIndex:0] valueForKey:@"video_url_mp4"]]];
                    [self presentViewController:player animated:YES completion:nil];
                    
                }else{
                    
                    [HUD dismissAnimated:YES];
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Sorry." message:@"We were not able to get video file. We apologize for the issue." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    
                }
                
    
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                
                [HUD dismissAnimated:YES];
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Sorry." message:@"We were not able to get video file. We apologize for the issue." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
                
            }];

    
    
}


@end
