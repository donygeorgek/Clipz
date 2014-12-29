//
//  VideoCollectionCell.h
//  Clipz
//
//  Created by Dony George on 10/11/14.
//  Copyright (c) 2014 Dony George. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *videoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *ratingImageView;
@property (weak, nonatomic) IBOutlet UILabel *videoTitle;

@end
