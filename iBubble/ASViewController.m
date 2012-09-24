//
//  ASViewController.m
//  iBubble
//
//  Created by Cabin Wu on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#include <sys/time.h>
#include <math.h>
#include <stdio.h>
#include <string.h>
#import "ASViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MyPoint.h"
@implementation ASViewController

double lowPassResults;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    flag =1;
    
    //------------------------------------------------------------------------------------------------------------------
    
    //========================================
    if (player) { 
        [player release]; 
    } 
    NSString *soundPath=[[NSBundle mainBundle] pathForResource:@"8" ofType:@"mp3"]; 
    NSURL *soundUrl=[[NSURL alloc] initFileURLWithPath:soundPath];
    //==========================================
    
    //=====================================
    //Audio player initialized.
    player=[[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil]; 
    [player prepareToPlay]; 
    player.volume = 1.0;
    [soundUrl release]; 
    //======================================
    
    
    //------------------------------------------------------------------------------------------------------------------
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
	NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
							  [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
							  [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
							  [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
							  nil];
    
	NSError *error;
    
    //======================================
	recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
	if (recorder) {
		[recorder prepareToRecord];
		recorder.meteringEnabled = YES;
		[recorder record];
		levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.03 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
	} 
    //    else
    //		NSLog([error description]);	
    level =[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    [level setTextColor:[UIColor whiteColor]];
    [level setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:level];
    //====================================================================
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                             target:self 
                                           selector:@selector(check) 
                                           userInfo:nil
                                            repeats:YES];
    
//    UIImage* image1 = [UIImage imageNamed:@"1.png"];
//    UIImage* image2 = [UIImage imageNamed:@"image1.JPG"];
//    [self imageDump:image1];
//    unsigned char* data = [self requestImagePixelData:image1];
//    NSLog(@"%s",data);
//    
//    UIImage* resultImage = [self addImage:image1 toImage:image2];
//    UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
//    [imgView setImage:resultImage];
//    [self.view addSubview:imgView];
}

-(void)imageDump:(UIImage*) image
{
//    UIImage* image = [UIImage imageNamed:file];
    CGImageRef cgimage = image.CGImage;
    
    size_t width  = CGImageGetWidth(cgimage);
    size_t height = CGImageGetHeight(cgimage);
    
    size_t bpr = CGImageGetBytesPerRow(cgimage);
    size_t bpp = CGImageGetBitsPerPixel(cgimage);
    size_t bpc = CGImageGetBitsPerComponent(cgimage);
    size_t bytes_per_pixel = bpp / bpc;
    
    CGBitmapInfo info = CGImageGetBitmapInfo(cgimage);
    
    NSLog(
          @"\n"
          "===== %@ =====\n"
          "CGImageGetHeight: %d\n"
          "CGImageGetWidth:  %d\n"
          "CGImageGetColorSpace: %@\n"
          "CGImageGetBitsPerPixel:     %d\n"
          "CGImageGetBitsPerComponent: %d\n"
          "CGImageGetBytesPerRow:      %d\n"
          "CGImageGetBitmapInfo: 0x%.8X\n"
          "  kCGBitmapAlphaInfoMask     = %s\n"
          "  kCGBitmapFloatComponents   = %s\n"
          "  kCGBitmapByteOrderMask     = %s\n"
          "  kCGBitmapByteOrderDefault  = %s\n"
          "  kCGBitmapByteOrder16Little = %s\n"
          "  kCGBitmapByteOrder32Little = %s\n"
          "  kCGBitmapByteOrder16Big    = %s\n"
          "  kCGBitmapByteOrder32Big    = %s\n",
          @"1.png",
          (int)width,
          (int)height,
          CGImageGetColorSpace(cgimage),
          (int)bpp,
          (int)bpc,
          (int)bpr,
          (unsigned)info,
          (info & kCGBitmapAlphaInfoMask)     ? "YES" : "NO",
          (info & kCGBitmapFloatComponents)   ? "YES" : "NO",
          (info & kCGBitmapByteOrderMask)     ? "YES" : "NO",
          (info & kCGBitmapByteOrderDefault)  ? "YES" : "NO",
          (info & kCGBitmapByteOrder16Little) ? "YES" : "NO",
          (info & kCGBitmapByteOrder32Little) ? "YES" : "NO",
          (info & kCGBitmapByteOrder16Big)    ? "YES" : "NO",
          (info & kCGBitmapByteOrder32Big)    ? "YES" : "NO"
          );
    
    CGDataProviderRef provider = CGImageGetDataProvider(cgimage);
    NSData* data = (id)CGDataProviderCopyData(provider);
    [data autorelease];
    const uint8_t* bytes = [data bytes];
    
    printf("Pixel Data:\n");
    for(size_t row = 0; row < height; row++)
    {
        for(size_t col = 0; col < width; col++)
        {
            const uint8_t* pixel =
            &bytes[row * bpr + col * bytes_per_pixel];
            
            printf("(");
            for(size_t x = 0; x < bytes_per_pixel; x++)
            {
                printf("%.2X", pixel[x]);
                if( x < bytes_per_pixel - 1 )
                    printf(",");
            }
            
            printf(")");
            if( col < width - 1 )
                printf(", ");
        }
        
        printf("\n");
    }
}

// Return Image Pixel data as an RGBA bitmap 
//-(unsigned char *) requestImagePixelData:(UIImage *)inImage 
//{
//	CGImageRef img = [inImage CGImage]; 
//	CGSize size = [inImage size];
//	CGContextRef cgctx = CreateRGBABitmapContext(img); 
//	
//	if (cgctx == NULL) 
//		return NULL;
//	
//	CGRect rect = {{0,0},{size.width, size.height}}; 
//	CGContextDrawImage(cgctx, rect, img); 
//	unsigned char *data = CGBitmapContextGetData (cgctx); 
////    NSString* data2 = CGBitmapContextGetData (cgctx); 
//	CGContextRelease(cgctx);
//	return data;
//}

- (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2
{  
    UIGraphicsBeginImageContext(image1.size);  
    
    // Draw image1  
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];  
    
    // Draw image2  
    [image2 drawInRect:CGRectMake(0, 0, image2.size.width, image2.size.height)];  
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();  
    
    UIGraphicsEndImageContext();  
    
    return resultingImage;  
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self.view];
    
    UIView* contentView = [[UIView alloc] initWithFrame:CGRectMake(point.x-83, point.y-83, 166, 166)];
    contentView.center = point;
    
    
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = CGRectMake(0, 0, 166, 166);
    imageLayer.cornerRadius = 83;
    imageLayer.contents = (id) [UIImage imageNamed:[NSString stringWithFormat:@"%d.png",flag]].CGImage;
    imageLayer.masksToBounds = YES;
//    [self.view.layer addSublayer:imageLayer];
    [contentView.layer addSublayer:imageLayer];
//    UIImageView* back = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1.png"]];
//    [back setFrame:CGRectMake(point.x-83.5, point.y-83.5, 167, 167)];
//    [self.view addSubview:back];
    
    UIImageView* front = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Note.png"]];
    [front setFrame:CGRectMake(0, 0, 167, 167)];
    [contentView addSubview:front];
    
    [self.view addSubview:contentView];
    
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
    
    /*
    UIBezierPath* aPath = [UIBezierPath bezierPath];
    
    [aPath moveToPoint:CGPointMake(x1, y1)];
    [aPath addCurveToPoint:CGPointMake(x2, y2) controlPoint1:CGPointMake((x1-x2)/2+x2, y1-20) controlPoint2:CGPointMake((x2-x1)/2+x1, (y1-y2)/4+y2)];
    
    //        CGMutablePathRef path = CGPathCreateMutable();
    //        CGPathMoveToPoint(apath, NULL, x1, y1);
    //        CGPathAddQuadCurveToPoint(path, NULL, x1, y1, x2, y2);
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.path = [aPath CGPath];
    pathAnimation.duration = 0.7;
    [iconFlyImage.layer addAnimation:pathAnimation forKey:nil];
    */
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = [NSArray arrayWithObjects:scaleAnimation, fadeAnimation, nil];
    group.duration = 1.5;
    group.delegate = self;
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    
    
    
    [contentView.layer addAnimation:group forKey:@"animation"];
    if (flag == 57) {
        flag = 1;
    }else{
        flag++;
    }
}

//处理音频
- (void)levelTimerCallback:(NSTimer *)timer {
	[recorder updateMeters];
    
	const double ALPHA = 0.05;
	double peakPowerForChannel = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
	lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResults;	
	
    [level setText:[NSString stringWithFormat:@"%f" ,lowPassResults]];
}

//处理音频
-(void) check
{
    NSLog(@"Checked!!!!!!!!!!!!!!!!!!!!!!");
    if (lowPassResults > 0.5) {
        [player play];
        int x = arc4random()%420-50;
        int y = arc4random()%467-150;
        NSLog(@"Dest x:%d  y:%d",x,y);
        [self bubbleBlow:CGPointMake(x, y)];
    }
    else{
        [player stop];
    }
}


-(void) bubbleBlow:(CGPoint)point
{
    NSLog(@"BubbleBlow called");
    int x1=160;
    int y1=467;
    int x2 = point.x;
    int y2 = point.y;
//    int x2 = 160;
//    int y2 = 0;
    UIView* contentView = [[UIView alloc] initWithFrame:CGRectMake(x1, y1, 166, 166)];
    contentView.center = CGPointMake(x1, y1);
    
    
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = CGRectMake(0, 0, 166, 166);
    imageLayer.cornerRadius = 83;
    imageLayer.contents = (id) [UIImage imageNamed:[NSString stringWithFormat:@"%d.png",flag]].CGImage;
    imageLayer.masksToBounds = YES;
    //    [self.view.layer addSublayer:imageLayer];
    [contentView.layer addSublayer:imageLayer];
    //    UIImageView* back = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1.png"]];
    //    [back setFrame:CGRectMake(point.x-83.5, point.y-83.5, 167, 167)];
    //    [self.view addSubview:back];
    
    UIImageView* front = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Note.png"]];
    [front setFrame:CGRectMake(0, 0, 167, 167)];
    [contentView addSubview:front];
    
    [self.view addSubview:contentView];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 0.1)];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
    scaleAnimation.duration = 1.0;
    
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    fadeAnimation.toValue = [NSNumber numberWithFloat:0.0];
    fadeAnimation.beginTime = 0.75;
    fadeAnimation.duration = 0.75;
    
    //路径=======================================================
     UIBezierPath* aPath = [UIBezierPath bezierPath];
    
     [aPath moveToPoint:CGPointMake(x1, y1)];
     [aPath addCurveToPoint:CGPointMake(x2, y2) controlPoint1:CGPointMake((x1-x2)/2+x2, y1-20) controlPoint2:CGPointMake((x2-x1)/2+x1, (y1-y2)/4+y2)];
     
     //        CGMutablePathRef path = CGPathCreateMutable();
     //        CGPathMoveToPoint(apath, NULL, x1, y1);
     //        CGPathAddQuadCurveToPoint(path, NULL, x1, y1, x2, y2);
     
     CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
     pathAnimation.path = [aPath CGPath];
     pathAnimation.duration =1.5;
     [contentView.layer addAnimation:pathAnimation forKey:nil];
     //=====================================================================
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = [NSArray arrayWithObjects:scaleAnimation, fadeAnimation, nil];
    group.duration = 1.5;
    group.delegate = self;
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    
    
    
    [contentView.layer addAnimation:group forKey:@"animation"];
    if (flag == 57) {
        flag = 1;
    }else{
        flag++;
    }
}

- (void)dealloc {
	[levelTimer release];
	[recorder release];
    [super dealloc];
}

@end
