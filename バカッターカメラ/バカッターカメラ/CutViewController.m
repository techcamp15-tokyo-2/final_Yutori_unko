//
//  CutViewController.m
//  バカッターカメラ
//
//  Created by Mizuki Kobayashi on 2013/09/09.
//  Copyright (c) 2013年 Hiroyuki Mizukami. All rights reserved.
//

#import "CutViewController.h"
#import "CustomScrollView.h"
#import "CameraViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Social/Social.h>

@interface CutViewController ()
{
    __weak IBOutlet UIImageView *bgView;
    __weak IBOutlet UIImageView *kabeGazo;
    __weak IBOutlet UIButton *aButton;
    __weak IBOutlet UIButton *bButton;
    __weak IBOutlet UISlider *aSlider;
    IBOutlet UITableView *tableMenu;
    CustomScrollView *sView;
    NSMutableArray *uStack;
    UIImage *kabeimg;
    NSMutableArray *points;
    CGPoint lastPoint;
    CGFloat brush;
    BOOL isCut;
    BOOL isMove;
    float zScale;
    float contentScale;
    float contentRotation;
    float contentTranslationX;
    float contentTranslationY;
    float thin;
    NSMutableArray *activeTouches;
    
}
@end

@implementation CutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.view setMultipleTouchEnabled:YES];
        
    }
    return self;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidLoad
{
    [super viewDidLoad];
        
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    points = [NSMutableArray array];
    uStack = [NSMutableArray array];
    //kabeGazo.alpha = 0;
    //kabeimg = [UIImage imageNamed:@"sakamoto.jpg"];
    
    kabeimg = [[UIImage alloc]initWithCGImage:self.itemImage.CGImage];
    if (kabeimg.size.width > kabeimg.size.height) {
        NSLog(@"縦:%f\n横:%f",kabeimg.size.height,kabeimg.size.width);
        kabeimg = [UIImage imageWithCGImage:kabeimg.CGImage scale:kabeimg.scale orientation:UIImageOrientationRight];
        NSLog(@"縦:%f\n横:%f",kabeimg.size.height,kabeimg.size.width);
    }
    if (_bgImage.size.width > _bgImage.size.height) {
        _bgImage = [UIImage imageWithCGImage:_bgImage.CGImage scale:_bgImage.scale orientation:UIImageOrientationRight];
    }
    //sView.alpha = 0.0f;
    //[kabeGazo setContentMode:UIViewContentModeScaleAspectFit];
    [kabeGazo setImage:kabeimg];
    [bgView setImage:_bgImage];
    [bgView setContentMode:UIViewContentModeScaleAspectFit];
        
    //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction :)];
    //[kabeGazo addGestureRecognizer:tap];
    brush = 16.0f;
    bgView.alpha = 0.0f;
    isCut = NO;
    isMove = NO;
    thin = 1.0f;
    zScale = 1.0f;
    contentScale = 1.0f;
    contentTranslationX = 0.f;
    contentTranslationY = 0.f;
    contentRotation = 0.0f;
    aSlider.alpha = 0.0f;
    aSlider.minimumValue = 1;
    aSlider.maximumValue = 50;
    aSlider.value = brush;
    [self setScrollView];
    
    [self.view bringSubviewToFront:aButton];
    [self.view bringSubviewToFront:bButton];
    [self.view bringSubviewToFront:aSlider];
    
    tableMenu.delegate = self;
    tableMenu.dataSource = self;
    tableMenu.alpha = 0.7f;
    tableMenu.frame = CGRectMake(0,self.view.frame.size.height - 160,160,160);
    //tableMenu.center = self.view.center;
    
    
    NSLog(@"selfHeigt:%f\n kabegazoHeight:%f\n kabeimgHeight:%f",self.view.frame.size.height,kabeGazo.frame.size.height,kabeimg.size.height);
    NSLog(@"selfWidth:%f\n kabegazoWidth:%f\n kabeimgWidth:%f",self.view.frame.size.width,kabeGazo.frame.size.width,kabeimg.size.width);

    activeTouches = [[NSMutableArray alloc]initWithCapacity:2];

}
- (void)setScrollView
{
    //スクロールビューの初期化
    sView = [[CustomScrollView alloc] init];
    sView.frame = kabeGazo.bounds;
    //sView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [sView addSubview:kabeGazo];
    sView.contentSize = kabeGazo.bounds.size;
    
    [self.view addSubview:sView];
    
    [sView setDelegate:self];
    
    sView.delaysContentTouches = NO;
	sView.CanCancelContentTouches = NO;
    sView.showsHorizontalScrollIndicator = NO;
    sView.showsVerticalScrollIndicator = NO;
    
    sView.Bounces = NO;
    sView.bouncesZoom = NO;
    sView.minimumZoomScale = 1.0f;
    sView.maximumZoomScale = 5.0f;
    
}

//拡大/縮小対応
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    for (id subview in scrollView.subviews) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            return subview;
        }
    }
    return nil;
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale{
    zScale=scale;
}


- (void)pathMake {
    NSLog(@"pathMake");
    
    if (!(points.count >= 3)) {
        return;
    }
    CGRect rect = CGRectZero;
    //rect.size = kabeGazo.frame.size;
    rect.size = kabeimg.size;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    
    for (NSValue *aPointValue in points) {
        CGPoint aPoint = [aPointValue CGPointValue];
        CGPoint bPoint = [self convertPoint:aPoint forImageSize:kabeimg.size];
        //CGPoint cPoint = [self convertPoint:bPoint forImageSize:jotaro.size];
        //CGPoint toPoint = CGPointMake(bPoint.x, kabeimg.size.height - bPoint.y);
        CGPoint toPoint = CGPointMake(bPoint.x, kabeimg.size.height - bPoint.y);
        
        if ([bezierPath isEmpty]) {
            [bezierPath moveToPoint:toPoint];
        }else{
            [bezierPath addLineToPoint:toPoint];
        }
    }
    [bezierPath closePath];
    
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
    [[UIColor blackColor] setFill];
    UIRectFill(rect);
    
    [[UIColor whiteColor] setFill];
    [bezierPath fill];
    
    UIImage *mask = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextClipToMask(UIGraphicsGetCurrentContext(), rect, mask.CGImage);
    [kabeimg drawAtPoint:CGPointZero];
    UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    for (UIImageView* subview in kabeGazo.subviews) {
        [subview removeFromSuperview];
    }
    
    //[kabeGazo setContentMode:UIViewContentModeScaleAspectFit];
    [kabeGazo setImage:maskedImage];
    [self.view addSubview:kabeGazo];
    [self.view bringSubviewToFront:aButton];
    [self.view bringSubviewToFront:bButton];
    [self.view bringSubviewToFront:aSlider];
    [sView removeFromSuperview];
    //bButton.alpha = 0.0f;
    aSlider.alpha = 1.0f;
    
    //一度UIGraphicで描画してまう
    UIGraphicsBeginImageContext(kabeGazo.frame.size);
    [kabeGazo.image drawInRect:CGRectMake(0, 0, kabeGazo.frame.size.width, kabeGazo.frame.size.height)];
    kabeGazo.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [sView removeFromSuperview];
    
    points = [NSMutableArray array];
    isCut = YES;

}


#pragma mark --touch--

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan");
    if(!isMove){
        UITouch *touch = [touches anyObject];
        if (!isCut) {
        lastPoint = [touch locationInView:kabeGazo];
        }else{
            for(UITouch *tc in touches){
                [activeTouches addObject:tc];
            }
            if (activeTouches.count==1) {
                UIGraphicsBeginImageContext(kabeGazo.bounds.size);
                [kabeGazo.layer renderInContext:UIGraphicsGetCurrentContext()];
                UIImage *bitmap = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                [uStack addObject:bitmap];
                lastPoint = [touch locationInView:kabeGazo];
            }
        }
    }else if(isMove){

        for(UITouch *tc in touches){
            [activeTouches addObject:tc];
            NSLog(@"activeTouche:%d",activeTouches.count);
            
        }
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (isCut) {
        UITouch *touch = [touches anyObject];
        CGPoint currentPoint = [touch locationInView:kabeGazo];
        UIGraphicsBeginImageContext(kabeGazo.frame.size);
        [kabeGazo.image drawInRect:CGRectMake(0, 0, kabeGazo.frame.size.width, kabeGazo.frame.size.height)];
        
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
        // 透明の描画
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeClear);
        
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        kabeGazo.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        lastPoint = currentPoint;
    }else if(isMove)
    {
        if([activeTouches count]>2){
            return;
        }
        float dx = 0.0;
        float dy = 0.0;
        float dr = 0.0;
        float ds = 1.0;
        
        if([activeTouches count]==1){
            UITouch *t0 = [activeTouches objectAtIndex:0];
            CGPoint crntPt = [t0 locationInView:kabeGazo];
            CGPoint prevPt = [t0 previousLocationInView:kabeGazo];
            dx = crntPt.x - prevPt.x;
            dy = crntPt.y - prevPt.y;
            dr = 0;
            ds = 1.0;
        }else if([activeTouches count]==2){
            UITouch *t0 = [activeTouches objectAtIndex:0];
            UITouch *t1 = [activeTouches objectAtIndex:1];
            CGPoint crntPt0 = [t0 locationInView:self.view];
            CGPoint prevPt0 = [t0 previousLocationInView:self.view];
            CGPoint crntPt1 = [t1 locationInView:self.view];
            CGPoint prevPt1 = [t1 previousLocationInView:self.view];
            
            //Translation
            CGPoint crntPt = CGPointMake((crntPt0.x+crntPt1.x) * 0.5f, (crntPt0.y+crntPt1.y)*0.5f);
            CGPoint prevPt = CGPointMake((prevPt0.x+prevPt1.x) * 0.5f, (prevPt0.y+prevPt1.y)*0.5f);
            dx = crntPt.x - prevPt.x;
            dy = crntPt.y - prevPt.y;
            
            //Rotation
            float prevRad = atan2f(prevPt0.y-prevPt1.y, prevPt0.x-prevPt1.x);
            float crntRad = atan2f(crntPt0.y-crntPt1.y, crntPt0.x-crntPt1.x);
            dr = crntRad - prevRad;
            
            //Scale)
            float prevDist = sqrt((prevPt0.x-prevPt1.x)*(prevPt0.x-prevPt1.x)+(prevPt0.y-prevPt1.y)*(prevPt0.y-prevPt1.y));
            float crntDist = sqrt((crntPt0.x-crntPt1.x)*(crntPt0.x-crntPt1.x)+(crntPt0.y-crntPt1.y)*(crntPt0.y-crntPt1.y));
            ds = crntDist / prevDist;
        }
        contentTranslationX += dx;
        contentTranslationY += dy;
        contentRotation += dr;
        contentScale *= ds;
        
        [self updateTransform];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchEnd");
    UITouch *touch = [touches anyObject];
    CGPoint pos = [touch locationInView:kabeGazo];
//    sView.scrollEnabled = YES;
    //scaleに合わせてタップの許容範囲を広げる
    if (!isCut && !isMove && fabs(lastPoint.x - pos.x) + fabs(lastPoint.y - pos.y) <= 10.0/zScale ){
        NSLog(@"CutViewtouch");
        //        CGPoint pos = [[touches anyObject] locationInView:self.view];
        //CGPoint pos = [[touches anyObject] locationInView:kabeGazo];
        //CGPoint pos;
        //pos.x = (lastPoint.x + currentPoint.x)/2;
        //pos.y = (lastPoint.x + currentPoint.y)/2;
        NSValue *val = [NSValue valueWithCGPoint:pos];
        [points addObject:val];
        NSLog(@"%d",points.count);
        NSLog(@"x:%f \n y:%f",pos.x,pos.y);
        //配置する画像を設定
        NSString *Path = [[NSBundle mainBundle] pathForResource:@"pin" ofType:@"png"];
        UIImage *pin = [[UIImage alloc]initWithContentsOfFile:Path];
        //50*50の画像の中心点をタップした座標に設定
        CGRect rect = CGRectMake( pos.x-8 , pos.y-16, 16 , 16 );
        //imgを格納したimageviewをタップした座標に配置
        UIImageView *pinView = [[UIImageView alloc] initWithFrame:rect];
        pinView.backgroundColor= [UIColor clearColor];
        pinView.image = pin;
        [kabeGazo addSubview:pinView];
    }
    
    for(UITouch *touch in touches){
        [activeTouches removeObject:touch];
        NSLog(@"touchremove");
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    
    for(UITouch *touch in touches){
        [activeTouches removeObject:touch];
    }
    
}

-(CGPoint)convertPoint:(CGPoint)point forImageSize:(CGSize)imageSize{
    return CGPointMake((point.x * imageSize.width) / kabeGazo.frame.size.width,(point.y * imageSize.height) / kabeGazo.frame.size.height);
}

- (void)updateTransform{
    CGAffineTransform t = CGAffineTransformIdentity;
    t = CGAffineTransformTranslate(t, contentTranslationX, contentTranslationY);
    t = CGAffineTransformRotate(t, contentRotation);
    t = CGAffineTransformScale(t, contentScale * thin, contentScale);
    kabeGazo.transform = t;
}





#pragma mark --Extention--



//進むボタン
- (IBAction)pushAButton:(id)sender {
    if (!isMove) {
        
        if(!isCut){// トリミング→消しゴム
            [sView setZoomScale:1.0f];
            [self pathMake];
            sView.alpha = 1.0f;
            UIImageView *lView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16.0f, 16.0f)];
            
            // labelの細かい設定は省略
            
            [lView setUserInteractionEnabled:NO];
            [lView setTag:100]; // *1
            lView.hidden = YES;
            
            [aSlider addSubview:lView];
            
        }else{//消しゴム→移動
            aSlider.value = 1.0;
            aSlider.minimumValue = -2.0f;
            aSlider.maximumValue = 2.0f;
            isMove = YES;
            isCut = NO;
            NSString *Path = [[NSBundle mainBundle] pathForResource:@"bakatter_edit_end" ofType:@"jpg"];
            [aButton setBackgroundImage:[[UIImage alloc]initWithContentsOfFile:Path] forState:UIControlStateNormal];
            Path = [[NSBundle mainBundle] pathForResource:@"bakatter_edit_post" ofType:@"jpg"];
            [bButton setBackgroundImage:[[UIImage alloc]initWithContentsOfFile:Path] forState:UIControlStateNormal];
            bgView.alpha = 1.0;
            [bgView addSubview:kabeGazo];
        }
    }else{//end
        //tableMenu.center = self.view.center;
        
        //aSlider.alpha = 0.0f;
        //aButton.alpha = 0.0f;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

//undoボタン
- (IBAction)pushBButton:(id)sender {
    if (!isCut && !isMove && kabeGazo.subviews.count > 0) {//トリミング中
        [kabeGazo.subviews[kabeGazo.subviews.count-1] removeFromSuperview];
        [points removeObjectAtIndex:points.count -1];
        
    }else if(isCut && !isMove &&uStack.count > 0){//消しゴム中
        kabeGazo.image = [uStack lastObject];
        [uStack removeLastObject];
    
    }else if(isMove){//post
        [self.view addSubview:tableMenu];

    }
}
- (IBAction)slideAction:(id)sender {
    if(isCut){
        brush = aSlider.value;
        CGFloat ind_x = [[aSlider.subviews objectAtIndex:2] center].x;
        // Tag100がオブジェクト
        UIImageView *lView = (UIImageView *)[aSlider viewWithTag:100];
//        lView.center = (CGPoint){ind_x, -30.f};
        [lView setFrame:CGRectMake(ind_x - aSlider.value/2, -30-aSlider.value/2, aSlider.value, aSlider.value)];
        lView.hidden = NO;
        lView.image = [self sliderCtlMake:aSlider.value];
        //[aSlider setThumbImage:[self sliderCtlMake:aSlider.value] forState:UIControlStateNormal];
                }else if(isMove){
        thin = aSlider.value;
        [self updateTransform];
    }
}
- (IBAction)slideDidChange:(id)sender {
    [[sender viewWithTag:100] setHidden:YES];
}

- (UIImage *)sliderCtlMake:(float)value{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(value, value),NO, 0);
    //描画
//    CGContextRef context = UIGraphicsGetCurrentContext();
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0,0,value,value)];
    [[UIColor blackColor] setFill];
    [path fill];
    UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenImage;
}






#pragma mark --tableMenu(炎上)--



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//テーブルビューのrowの数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

//テーブルビューに表示されるセルの設定
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSArray *MenuTexts = @[@"Twitter",@"FaceBook",@"CameraRoll",@"Cancel"];
    NSString *MenuText = MenuTexts[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = MenuText;
    cell.textLabel.font = [UIFont systemFontOfSize:25];
    cell.textLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1.0 alpha:1];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row>3) {
        [tableMenu removeFromSuperview];
    }
    
    NSString* postContent = [NSString stringWithFormat:@"これマジやばない！？ #techcamp_tokyo"];
    UIGraphicsBeginImageContext(bgView.bounds.size);
    [bgView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *bitmap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(indexPath.row==0){//twitter
        SLComposeViewController *twitterPostVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [twitterPostVC setInitialText:postContent];
        [twitterPostVC addImage:bitmap];
        [self presentViewController:twitterPostVC animated:YES completion:nil];
    }else if(indexPath.row==1){//facebook
        SLComposeViewController *facebookPostVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [facebookPostVC setInitialText:postContent];
        [facebookPostVC addURL:[NSURL URLWithString:@"http://www.cyberagent.co.jp/recruit/special/internship/"]];
        [facebookPostVC addImage:bitmap];
        [self presentViewController:facebookPostVC animated:YES completion:nil];
    }
    else if(indexPath.row==2){
        SEL selector = @selector(onCompleteCapture:didFinishSavingWithError:contextInfo:);
        //画像を保存する
        UIImageWriteToSavedPhotosAlbum(bitmap, self, selector, NULL);
    }
    [tableMenu removeFromSuperview];

}


- (void)onCompleteCapture:(UIImage *)screenImage
 didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *message = @"画像を保存しました";
    if (error) message = @"画像の保存に失敗しました";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @""
                                                    message: message
                                                   delegate: nil
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles: nil];
    [alert show];
    //aSlider.alpha = 1.0f;
    //aButton.alpha = 1.0f;    
    
}
@end
