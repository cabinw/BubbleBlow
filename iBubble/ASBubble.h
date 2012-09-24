//
//  ASBubble.h
//  iBubble
//
//  Created by Cabin Wu on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#define MODE_NORMAL 1
#define MODE_BLOW   2

@interface ASBubble : UIView
{
    int flag;
    int mode;
}

- (id)initWithFrame:(CGRect)frame andMode:(int)mode;

@end
