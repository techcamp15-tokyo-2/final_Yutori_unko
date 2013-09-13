//
//  CustomScrollView.m
//  バカッターカメラ
//
//  Created by Mizuki Kobayashi on 2013/09/11.
//  Copyright (c) 2013年 Hiroyuki Mizukami. All rights reserved.
//

#import "CustomScrollView.h"

@implementation CustomScrollView

- (id)initWithFrame:(CGRect)frame

{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setDelaysContentTouches:NO];
        [self setCanCancelContentTouches:NO];
        [self setClipsToBounds:NO];

    }
    return self;
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event

{
    
    [self.nextResponder touchesBegan:touches withEvent:event];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self.nextResponder touchesMoved:touches withEvent:event];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event

{
    
    [self.nextResponder touchesEnded:touches withEvent:event];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
