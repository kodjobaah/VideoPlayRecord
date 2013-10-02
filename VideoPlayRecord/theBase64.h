//
//  myBase64.h
//  VideoPlayRecord
//
//  Created by Valtech UK on 29/08/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <stdio.h>
#import <opencv2/highgui/cap_ios.h>

@interface theBase64 : NSObject {
    
}

+ (NSString *) theBase64Representation:(const uchar*)input;

@end
