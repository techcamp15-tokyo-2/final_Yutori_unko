//
//  CutViewController.h
//  バカッターカメラ
//
//  Created by Mizuki Kobayashi on 2013/09/09.
//  Copyright (c) 2013年 Hiroyuki Mizukami. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CutViewController : UIViewController<UIGestureRecognizerDelegate,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic) UIImage *itemImage;
@property (strong,nonatomic) UIImage *bgImage;

@end
