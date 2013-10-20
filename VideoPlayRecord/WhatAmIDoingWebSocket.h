//
//  WhatAmIDoingWebSocket.h
//  VideoPlayRecord
//
//  Created by Valtech UK on 17/10/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "libwebsockets/libwebsockets.h"
#import "NSLinkedList.h"
#import <opencv2/highgui/cap_ios.h>
#import "NSLinkedList.h"
#include <openssl/bio.h>
#include <openssl/evp.h>
#import "NSLinkedList.h"

@interface WhatAmIDoingWebSocket : NSObject{

    CvVideoCamera *camera;
    NSInteger *recordingStatus;
    UIButton *startVideoButton;
    UIButton *stopVideoButton;

 
}
@property (weak, nonatomic) UIButton *startVideoButton;
@property (weak, nonatomic) UIButton *stopVideoButton;

@property (nonatomic,assign) NSInteger recordingStatus;
@property (nonatomic,assign) CvVideoCamera *camera;

static int callback_http(struct libwebsocket_context *context,
                         struct libwebsocket *wsi,
                         enum libwebsocket_callback_reasons reason, void *user,
                         void *in, size_t len);

-(void)remove;
-(void)open:(NSString *)token;
-(void) send:(NSString *)data;
-(WhatAmIDoingWebSocket *) initWithCamera:(CvVideoCamera *)theCamera;
-(void)close;
-(int) connectionStatus;
- (CFStringRef *)base64EncodedString: data;
@end
