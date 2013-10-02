//
//  RecordVideoViewController.m
//  VideoPlayRecord
//
//  Created by Valtech UK on 26/08/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import "RecordVideoViewController.h"
#include <string.h>
#include <stdio.h>
#include <math.h>
#include "SRWebSocket.h"
#import "NSData+Base64.h"



@interface RecordVideoViewController ()

@end

@implementation RecordVideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:_displayImage];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.delegate = self;
    self.videoCamera.grayscaleMode = NO;
    
    _startVideoButton.enabled = YES;
    _stopVideoButton.enabled = NO;
    
    _webSocket.delegate = nil;
    [_webSocket close];
    
    _webSocket = [[SRWebSocket alloc]
                  initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://5.79.24.141:9000/publishVideo?username=javapp"]]];
    _webSocket.delegate = self;
    
    self.title = @"Opening Connection...";
    [_webSocket open];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus
- (void)processImage:(Mat&)image;
{
    Mat image_copy;
    UIImage *resultUIImage = [self UIImageFromCVMat:image];
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [path objectAtIndex:0];
    
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"myFile.jpg"];
    NSData *tempData = [NSData dataWithData:UIImageJPEGRepresentation(resultUIImage,0.8)];
   // BOOL result = [tempData writeToFile:appFile atomically:YES];
    NSString* ns = [tempData base64EncodedString];
    NSUInteger characterCount = [ns length];
    NSLog (@" path [%@]",appFile);
    NSLog (@" before 64 bit encoding[%lu]",(unsigned long)characterCount);
   
    [_webSocket send:ns];

    
}
#endif
- (IBAction)invite:(id)sender {
    
   
    NSString *post =[[NSString alloc] initWithFormat:@"email=%@",self.emal.text];
    
    NSLog(@"post ==> %@", post);
    
    NSURL *url=[NSURL URLWithString:@"http://5.79.24.141:9000/invite"];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    //NSLog(@" route id is :%@",postLength);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *response = nil;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if ([response statusCode] >=200 && [response statusCode] <300)
    {
        NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
        NSLog(@"Response ==> %@", responseData);
    } else {
        if (error) NSLog(@"Error: %@", error);
    }
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"hello"
                                                   message: self.emal.text
                                                  delegate: self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"OK",nil];
    
    
    [alert show];
       
}



- (IBAction)recordVideo:(id)sender {
    _startVideoButton.enabled = NO;
    _stopVideoButton.enabled = YES;
    [self.videoCamera start];
}

-(IBAction) stopVideo:(id)sender
{
    _startVideoButton.enabled = YES;
    _stopVideoButton.enabled = NO;
    [self.videoCamera stop];
    NSLog(@"Button Touch Down Event Fired.");
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
    self.title = @"Connected!";
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@":( Websocket Failed With Error %@", error);
    
    self.title = @"Connection Failed! (see logs)";
    _webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    NSLog(@"Received \"%@\"", message);
   
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed");
    self.title = @"Connection Closed! (see logs)";
    _webSocket = nil;
}



-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    bool alpha = cvMat.channels() == 4;
    CGBitmapInfo bitMapInfo = (alpha ? kCGImageAlphaLast : kCGImageAlphaNone) | kCGBitmapByteOrderDefault;
   
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                      cvMat.rows,                                 //height
                      8,                                  //bits per component
                      8 * cvMat.elemSize(),                       //bits per pixel
                      cvMat.step[0],                            //bytesPerRow
                      colorSpace,                                 //colorspace
                      bitMapInfo,// bitmap info
                      provider,                              // CGDataProviderRef
                      NULL,                                       //decode
                      false,                              //should interpolate
                      kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

@end
