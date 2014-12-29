//
//  FeaturedVideos.h
//  Clipz
//
//  Created by Dony George on 10/11/14.
//  Copyright (c) 2014 Dony George. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JGProgressHUD.h"
#import "AFHTTPRequestOperationManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AAShareBubbles.h"
#import "Social/Social.h"
#import <MessageUI/MessageUI.h>

@class GADBannerView;

@interface FeaturedVideos : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UIGestureRecognizerDelegate,AAShareBubblesDelegate,MFMailComposeViewControllerDelegate>{
    NSMutableArray *videosArray;
    NSString *categoryString;
    MFMailComposeViewController *mailComposer;
}

-(void)loadVideos:(int)pageNo;
-(void)shareVideo:(int)index;

@property(nonatomic,retain) NSMutableArray *videosArray;
@property(nonatomic,retain) NSString *categoryString;
@property (weak, nonatomic) IBOutlet UICollectionView *videoCollectionView;
@property (weak, nonatomic) IBOutlet GADBannerView *adBanner;

@end
