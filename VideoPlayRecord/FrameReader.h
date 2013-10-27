//
//  FrameReader.h
//  VideoPlayRecord
//
//  Created by Valtech UK on 21/10/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/highgui/cap_ios.h>
#import "WhatAmIDoingWebSocket.h"
#import "WhatAmIDoingAppDelegate.h"
#import "AuthenticationToken.h"
#import "WhatAmIDoingConstants.h"
#import "UIImage+Scale.h"

@interface FrameReader : NSOperation<CvVideoCameraDelegate>{
    CvVideoCamera *videoCamera;
    WhatAmIDoingWebSocket *whatAmIdoingWebSocket;
    PropertyAccessor *propertyAccessor;
    WhatAmIDoingConstants *constants;
    AuthenticationToken *token;
    UIImageView *displayFrame;
    BOOL        executing;
    BOOL        finished;
    AVCaptureDevicePosition devicePosition;
    
}

@property (nonatomic)   AVCaptureDevicePosition devicePosition;
@property (nonatomic, strong) AuthenticationToken *token;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) PropertyAccessor *propertyAccessor;
@property (nonatomic, strong) WhatAmIDoingWebSocket *whatAmIdoingWebSocket;
@property (nonatomic, strong ) UIImageView *displayFrame;
@property (nonatomic, strong) CvVideoCamera* videoCamera;
@property (nonatomic, strong) WhatAmIDoingConstants *constants;

-(id)initWithData:(id)data;
-(void)completeOperation;
-(BOOL)getStatus;
@end
