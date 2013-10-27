//
//  FrameReader.m
//  VideoPlayRecord
//
//  Created by Valtech UK on 21/10/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import "FrameReader.h"

using namespace cv;

@implementation FrameReader

@synthesize displayFrame = _displayFrame;
@synthesize constants = _constants;
@synthesize videoCamera = _videoCamera;
@synthesize whatAmIdoingWebSocket = _whatAmIdoingWebSocket;
@synthesize propertyAccessor = _propertyAccessor;
@synthesize token = _token;
@synthesize devicePosition = _devicePosition;

static int counter = 0;
static NSDate * theDate = nil;
static BOOL isDone = NO;
static BOOL startWebsocket = YES;

- (id)initWithData:(UIImageView *)displayImage {
    
    isDone = NO;
    startWebsocket = YES;
    if (self = [super init])
        
    _displayFrame = displayImage;
    _propertyAccessor = [[PropertyAccessor alloc] init];
    _constants = [[WhatAmIDoingConstants alloc] init];
    
    WhatAmIDoingAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[_constants authenticationToken]
                                              inManagedObjectContext:appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *fetchedObjects = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    _token  =  [fetchedObjects objectAtIndex: 0];
    return self;
}

#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus
- (void)processImage:(Mat&)image;
{
    // NSLog(@"PROCED IAMGE 1");
    
        @autoreleasepool {
            
            if (counter == 0) {
                theDate = [NSDate date];
                
            }
            counter = counter + 1;
            
            if (counter == 30) {
               // NSLog(@" Time to transmit 30 frames: %g",[theDate timeIntervalSinceNow]*-1);
                counter = 0;
            }
            Mat image_copy;
            @autoreleasepool {
                
                
                //UIImage *resultUIImage = MatToUIImage(image);
                
                UIImage *resultUIImage = [self UIImageFromCVMat:image];
                UIImage *resized = [resultUIImage  imageScaledToScale:0.9f withInterpolationQuality:kCGInterpolationHigh];
                
                
                NSData  __weak *tempData =  UIImageJPEGRepresentation(resized,1.0);
                
                //NSData *tempData = [NSData dataWithData:UIImageJPEGRepresentation(resultUIImage,1.0)];
               // NSLog(@"0 reference count = %ld", CFGetRetainCount((__bridge CFTypeRef)tempData));
                if (startWebsocket == YES) {
                    NSLog(@"---------- starting websockets");
                    [self.whatAmIdoingWebSocket open:self.token.playSession];
                    startWebsocket = NO;
                }

                if ([self.whatAmIdoingWebSocket connectionStatus] == YES) {
                    [self.whatAmIdoingWebSocket send:tempData];
                }
                
                //NSLog(@"0 reference count = %ld", CFGetRetainCount((__bridge CFTypeRef)tempData));
                tempData = nil;
                resultUIImage = nil;
                
                            }
        
        
    }
    
}
#endif

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    
    @autoreleasepool {
        
        NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
        CGColorSpaceRef colorSpace;
        
        if (cvMat.elemSize() == 1) {
            colorSpace = CGColorSpaceCreateDeviceGray();
        } else {
            colorSpace = CGColorSpaceCreateDeviceRGB();
        }
        
        CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
        
        bool alpha = cvMat.channels() == 4;
      //  CGBitmapInfo bitMapInfo = (alpha ? kCGImageAlphaLast : kCGImageAlphaNone) | kCGBitmapByteOrderDefault;
        
        
        CGBitmapInfo bitMapInfo = alpha ? kCGImageAlphaPremultipliedLast : kCGImageAlphaNoneSkipLast;
        // Creating CGImage from cv::Mat
        CGImageRef imageRef = CGImageCreate(cvMat.cols,  //width
                                            cvMat.rows,                      //height
                                            8,                               //bits per component
                                            8 * cvMat.elemSize(),            //bits per pixel
                                            cvMat.step[0],                   //bytesPerRow
                                            colorSpace,                      //colorspace
                                            bitMapInfo,                      // bitmap info
                                            provider,                        // CGDataProviderRef
                                            NULL,                            //decode
                                            false,                           //should interpolate
                                            kCGRenderingIntentDefault        //intent
                                            );
        
        
        // Getting UIImage from CGImage
        UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        CGDataProviderRelease(provider);
        CGColorSpaceRelease(colorSpace);
        data = nil;
        return finalImage;
    }
}

- (void)start {
    
    NSLog(@"START THE THREAD");
    
    // Always check for cancellation before launching the task.
    if ([self isCancelled])
    {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.displayFrame];
    self.videoCamera.defaultAVCaptureDevicePosition = self.devicePosition;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.delegate = self;
    self.videoCamera.grayscaleMode = NO;
    
    
    /*
     * Creating the websocket request used to publish the movie
     */
    self.whatAmIdoingWebSocket = [[WhatAmIDoingWebSocket alloc] init];
    
    
    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self.videoCamera start];

}



- (void)main {
    @try {
       
        
        while (![self isCancelled] && !isDone) {
            // Do some work and set isDone to YES when finished
        }
    }
    @catch(NSException *e ) {
        NSLog(@"Something went wrong:%@",e);
    }
}

-(BOOL)getStatus {
    return isDone;
}


- (void) stopVideo {
    [self.videoCamera stop];
}
- (void)completeOperation {
    NSLog(@"--done");
    isDone = YES;
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    [self.videoCamera stop];
    [self.whatAmIdoingWebSocket close];
    
    self.whatAmIdoingWebSocket = nil;
    self.videoCamera = nil;
  
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return executing;
}

- (BOOL)isFinished {
    return finished;
}

@end
