//
//  TweetLikeUserCCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-8.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface TweetLikeUserCCell : UICollectionViewCell

- (void)configWithUser:(User *)user likesNum:(NSNumber *)likes;

@end
