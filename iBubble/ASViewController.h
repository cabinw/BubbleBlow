//
//  ASViewController.h
//  iBubble
//
//  Created by Cabin Wu on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <UIKit/UIKit.h>

@interface ASViewController : UIViewController
{
    int flag;
     UILabel* level;
    NSTimer* timer;
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
	NSTimer *levelTimer;
//	double lowPassResults;
}

- (void)levelTimerCallback:(NSTimer *)timer;
-(void) bubbleBlow:(CGPoint)point;
-(void) check;
- (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2;
//-(unsigned char *) requestImagePixelData:(UIImage *)inImage ;
-(void)imageDump:(UIImage*) image;
@end
