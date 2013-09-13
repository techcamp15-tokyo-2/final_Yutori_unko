//
//  CustomCameraController.m
//  bakattercamgazo
//
//  Created by Mizuki Kobayashi on 2013/09/12.
//  Copyright (c) 2013年 Hiroyuki Mizukami. All rights reserved.
//

#import "CustomCameraController.h"
#import "MainViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface CustomCameraController ()
{
    __weak IBOutlet UISlider *sukeSlider;
    float sukedo;
}
@end

@implementation CustomCameraController

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
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [self becomeFirstResponder];

    NSLog(@"_rand : %d",_rand);

    if (_rand || _item) {
        if (_rand) {
            NSString *bgname = [[NSString alloc]initWithFormat:@"bg%d",rand()%5];
            NSString *Path = [[NSBundle mainBundle] pathForResource:bgname ofType:@"jpg"];
            _sukeImage = [[UIImage alloc]initWithContentsOfFile:Path];
            
            }
//        if (_sukeImage.size.width > _sukeImage.size.height) {
//            _sukeImage = [UIImage imageWithCGImage:_sukeImage.CGImage scale:_sukeImage.scale orientation:UIImageOrientationRight];
//        }
        [self imageSetting];
    }
}
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (_rand && motion == UIEventSubtypeMotionShake) {
        NSLog(@"height!! : %f",self.view.frame.size.height);
            NSString *bgname = [[NSString alloc]initWithFormat:@"bg%d",rand()%5];
            NSString *Path = [[NSBundle mainBundle] pathForResource:bgname ofType:@"jpg"];
            _sukeImage = [[UIImage alloc]initWithContentsOfFile:Path];
//        if (_sukeImage.size.width > _sukeImage.size.height) {
//            _sukeImage = [UIImage imageWithCGImage:_sukeImage.CGImage scale:_sukeImage.scale orientation:UIImageOrientationRight];
//        }
        [self imageSetting];
            }
}
- (void)imageSetting{
    if(self.view.frame.size.height >= 500)
    {
        CGFloat rHeight = self.view.frame.size.width*945.f/640.f;
        UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, rHeight * 3.0f/4.0f, rHeight  )];
        CGPoint pt = imgV.center;
        pt.x =self.view.center.x;
        imgV.center = pt;
        imgV.image = _sukeImage;
        imgV.alpha = 0.3f;
        [imgV setContentMode:UIViewContentModeScaleAspectFit];
        [self setCameraOverlayView:imgV];
        
    }else{
        UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , self.view.frame.size.width * 4.0/3.0  )];
        imgV.image = _sukeImage;
        imgV.alpha = 0.3f;
        [imgV setContentMode:UIViewContentModeScaleAspectFit];
        [self setCameraOverlayView:imgV];
    }
    
}
//- (IBAction)sliderAction:(id)sender {
//    UIImageView *imgV = [self.view.subviews objectAtIndex:0];
//    imgV.alpha = sukeSlider.value;
//}
//
@end
