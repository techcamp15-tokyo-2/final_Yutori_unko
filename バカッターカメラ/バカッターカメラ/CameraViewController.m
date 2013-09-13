//
//  ViewController.m
//  バカッターカメラ
//
//  Created by Mizuki Kobayashi on 2013/09/11.
//  Copyright (c) 2013年 Hiroyuki Mizukami. All rights reserved.
//

#import "CameraViewController.h"
#import "CustomCameraController.h"
#import "CutViewController.h"

@interface CameraViewController ()
{
    BOOL photo;
    __weak IBOutlet UIButton *camButton;
    __weak IBOutlet UIButton *libButton;
    __weak IBOutlet UIButton *bacButton;
    __weak IBOutlet UIImageView *BackGround;
}
@end

@implementation CameraViewController

//初期化
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%d",_isItemSetting);
    
    
    if (_isItemSetting) {
        NSString *Path = [[NSBundle mainBundle] pathForResource:@"bakatter_items" ofType:@"png"];
        BackGround.image = [[UIImage alloc]initWithContentsOfFile:Path];
        if (_img.size.width >= _img.size.height) {
            _img = [UIImage imageWithCGImage:_img.CGImage scale:_img.scale orientation:UIImageOrientationRight];
        }
        //イメージビューの生成
//        _imageView= [self makeImageView:CGRectMake(self.view.center.x - 100, 100, 200, 200)
//                                  image:nil];
//        _imageView.image = _img;
//        [self.view addSubview:_imageView];
    }
}




//アラートの表示
- (void)showAlert:(NSString *)title text:(NSString *)text {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:text
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

//テキストボタンの生成
- (UIButton *)makeButton:(CGRect)rect text:(NSString *)text tag:(int)tag {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:text forState:UIControlStateNormal];
    [button setFrame:rect];
    [button setTag:tag];
    [button addTarget:self
               action:@selector(clickButton:)
     forControlEvents:UIControlEventTouchUpInside];
    return button;
}

//イメージビューの生成
- (UIImageView *)makeImageView:(CGRect)rect image:(UIImage *)image {
    UIImageView *imageView= [[UIImageView alloc] init];
    [imageView setFrame:rect];
    [imageView setImage:image];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    return imageView;
}

//イメージピッカーのオープン
- (void)openPicker:(UIImagePickerControllerSourceType)sourceType {
    //カメラとフォトアルバムの利用可能チェック
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        [self showAlert:@"" text:@"利用できません"];
        return;
    }
    //イメージピッカー
    CustomCameraController *picker = [[CustomCameraController alloc] init];
    picker.sourceType = sourceType;
    picker.delegate = self;
    picker.item = NO;
    if (_isItemSetting && sourceType == UIImagePickerControllerSourceTypeCamera) {
        
        picker.sukeImage = [[UIImage alloc]initWithCGImage:_img.CGImage];
        picker.item = YES;
    }
    
    //ビューコントローラのビューを開く
    picker.rand = NO;
    
    [self presentViewController:picker animated:YES completion:nil];
}

//イメージピッカーのイメージ取得時に呼ばれる
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //イメージの指定
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if(image.size.height * image.size.width >500000) {
        image = [self resizeImage:image withQuality:kCGInterpolationDefault rate:0.5f];
    }
    
    if (!_isItemSetting) {
        CameraViewController *camView = [CameraViewController new];
        camView.img = [[UIImage alloc]initWithCGImage:image.CGImage];
        camView.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.center.x - 100, 320, 200, 200)];
        //camView.imageView.image = image;
        camView.isItemSetting = YES;
        //[camView.view addSubview:camView.imageView];
        [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController pushViewController:camView animated:NO];
    }else{
        CutViewController *cutView = [CutViewController new];
        
        cutView.itemImage = [[UIImage alloc]initWithCGImage:image.CGImage];
        cutView.bgImage = [[UIImage alloc]initWithCGImage:_img.CGImage];
        
        [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController pushViewController:cutView animated:NO];
    }
    //}
    //[_imageView setImage:image];
    //ビューコントローラのビューを閉じる
}

//イメージピッカーのキャンセル時に呼ばれる
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)pickerCtl {
    //ビューコントローラのビューを閉じる
    [[pickerCtl presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)pushCamButton:(id)sender {
    photo = YES;
    [self openPicker:UIImagePickerControllerSourceTypeCamera];
}
- (IBAction)pushLibButton:(id)sender {
    photo = NO;
    [self openPicker:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (IBAction)pushBacButton:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}


//Resize
- (UIImage *)resizeImage:(UIImage *)image
             withQuality:(CGInterpolationQuality)quality
                    rate:(CGFloat)rate
{
	NSDate *timer = nil;
	UIImage *resized = nil;
	CGFloat width = image.size.width * rate;
	CGFloat height = image.size.height * rate;
	
	timer = [NSDate date];
	UIGraphicsBeginImageContext(CGSizeMake(width, height));
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetInterpolationQuality(context, quality);
	[image drawInRect:CGRectMake(0, 0, width, height)];
	resized = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	NSLog(@"time: %f", [[NSDate date] timeIntervalSinceDate:timer]);
	return resized;
    
}


@end
