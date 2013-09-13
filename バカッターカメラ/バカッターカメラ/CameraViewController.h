//
//  ViewController.h
//  バカッターカメラ
//
//  Created by Mizuki Kobayashi on 2013/09/11.
//  Copyright (c) 2013年 Hiroyuki Mizukami. All rights reserved.
//

#import <UIKit/UIKit.h>

//デリゲート指定
/*@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
 
 //カメラを開く
 - (IBAction)pictureFromCamera;
 
 //フォトライブラリを開く
 - (IBAction)pictureFromRoll;
 
 @interface ViewController : UIViewController
 <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
 {
 IBOutlet UIImageView* _ImageView;
 }*/

@interface CameraViewController : UIViewController
<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong,nonatomic) UIImageView *imageView;
@property (strong,nonatomic) UIImage *img;
@property BOOL isItemSetting;

@end
