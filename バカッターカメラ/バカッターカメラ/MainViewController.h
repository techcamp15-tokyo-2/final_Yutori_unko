//
//  MainViewController.h
//  バカッターカメラ
//
//  Created by Mizuki Kobayashi on 2013/09/05.
//  Copyright (c) 2013年 Hiroyuki Mizukami. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (strong,nonatomic) UIImage *bgImage;
@end
