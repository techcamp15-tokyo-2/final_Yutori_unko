//
//  MainViewController.m
//  バカッターカメラ
//
//  Created by Mizuki Kobayashi on 2013/09/05.
//  Copyright (c) 2013年 Hiroyuki Mizukami. All rights reserved.
//

#import "MainViewController.h"
#import "CameraViewController.h"
#import "CutViewController.h"
#import "CustomCameraController.h"

@interface MainViewController (){
    __weak IBOutlet UIButton *qButton;
    __weak IBOutlet UIButton *mButton;
}
@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushQButton:(id)sender {
    [self openPicker:UIImagePickerControllerSourceTypeCamera];
}

- (IBAction)pushMButton:(id)sender {
    CameraViewController *camCon = [CameraViewController new];
    [self.navigationController pushViewController:camCon animated:NO];
//    [self.navigationController PushToViewController:camCon animated:YES];

}

- (void)showAlert:(NSString *)title text:(NSString *)text {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:text
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)openPicker:(UIImagePickerControllerSourceType)sourceType {
    //カメラとフォトアルバムの利用可能チェック
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        [self showAlert:@"" text:@"利用できません"];
        return;
    }
    //イメージピッカー
    CustomCameraController *picker = [CustomCameraController new];
    picker.sourceType = sourceType;
    picker.delegate = self;
    picker.rand = YES;
    //ビューコントローラのビューを開く
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(CustomCameraController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //イメージの指定
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    image = [self resizeImage:image withQuality:kCGInterpolationDefault rate:0.5f];
    
        CutViewController *cutView = [CutViewController new];
        cutView.itemImage = [[UIImage alloc]initWithCGImage:image.CGImage];
        cutView.bgImage = [[UIImage alloc]initWithCGImage:picker.sukeImage.CGImage];
        [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController pushViewController:cutView animated:NO];
}

//イメージピッカーのキャンセル時に呼ばれる
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)pickerCtl {
    //ビューコントローラのビューを閉じる
    [[pickerCtl presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

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
