//
//  ASBubble.m
//  iBubble
//
//  Created by Cabin Wu on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ASBubble.h"
#import <QuartzCore/QuartzCore.h>

@implementation ASBubble

- (id)initWithFrame:(CGRect)frame andMode:(int)mode
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        flag = 1;
    }
    return self;
}

-(void) viewDidLoad
{
    NSLog(@"Bubble view did load");  
    
    //====================================
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = CGRectMake(0, 0, 166, 166);
    imageLayer.cornerRadius = 83;
    imageLayer.contents = (id) [UIImage imageNamed:[NSString stringWithFormat:@"%d.png",flag]].CGImage;
    imageLayer.masksToBounds = YES;
    
    [self.layer addSublayer:imageLayer];
    
    UIImageView* front = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Note.png"]];
    [front setFrame:CGRectMake(0, 0, 167, 167)];
    [self addSubview:front];
    //====================================
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 0.1)];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
    scaleAnimation.duration = 1.5;
    
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    fadeAnimation.toValue = [NSNumber numberWithFloat:0.0];
    fadeAnimation.beginTime = 0.75;
    fadeAnimation.duration = 0.75;
    
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = [NSArray arrayWithObjects:scaleAnimation, fadeAnimation, nil];
    group.duration = 1.5;
    group.delegate = self;
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    
    
    
    [self.layer addAnimation:group forKey:@"animation"];
    
    //=======================
    if (flag == 57) {
        flag = 1;
    }else{
        flag++;
    }//=======================
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
