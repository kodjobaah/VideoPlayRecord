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
#import "WhatAmIDoingAppDelegate.h"
#import "PropertyAccessor.h"

using namespace cv;

@interface RecordVideoViewController ()



@end

@implementation RecordVideoViewController

@synthesize publishVideoUrl = _publishVideoUrl;
@synthesize webSocket = _webSocket;
@synthesize webSocketRequest = _webSocketRequest;
@synthesize startRecording = _startRecording;
@synthesize videoCamera = _videoCamera;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize propertyAccessor = _propertyAccessor;

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
    
    
    self.propertyAccessor = [[PropertyAccessor alloc] init];
    
    _startVideoButton.enabled = NO;
    _stopVideoButton.enabled = NO;
	
    WhatAmIDoingAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:_displayImage];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.delegate = self;
    self.videoCamera.grayscaleMode = NO;
    
    _startVideoButton.enabled = YES;
    _stopVideoButton.enabled = NO;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AuthenticationToken"
                                              inManagedObjectContext:appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *fetchedObjects = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    AuthenticationToken *token =  [fetchedObjects objectAtIndex: 0];
    
    self.publishVideoUrl = [self.propertyAccessor getPropertyValue:@"WHAT_AM_I_DOING_PUBLISH_VIDEO"];
    if (self.publishVideoUrl == nil) {
        self.publishVideoUrl = @"http://5.79.24.141:9000/publishVideo";
    }
    
    
    NSURL *urlNew = [NSURL URLWithString:self.publishVideoUrl];
    self.webSocketRequest = [NSMutableURLRequest requestWithURL:urlNew];

    NSString *domain = [self.propertyAccessor getPropertyValue:@"WHAT_AM_I_DOING_DOMAIN"];
    NSDictionary *cookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                      domain, NSHTTPCookieDomain,
                                      @"\\", NSHTTPCookiePath,
                                      @"PLAY_SESSION", NSHTTPCookieName,
                                      token.playSession, NSHTTPCookieValue,
                                      nil];
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    NSArray* cookieArray = [NSArray arrayWithObjects: cookie, nil];
    NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookieArray];
   [self.webSocketRequest setAllHTTPHeaderFields:headers];
    
    _webSocket.delegate = nil;
    [_webSocket close];
    
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:self.webSocketRequest];
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
    NSData *tempData = [NSData dataWithData:UIImageJPEGRepresentation(resultUIImage,1.0)];
    NSString* ns = [tempData base64EncodedString];
    [_webSocket send:ns];
    
}
#endif
- (IBAction)invite:(id)sender {
    
    
    NSString *hostUrlString = @"http://5.79.24.141:9000/invite?email=";
    NSString *hostMessage = [hostUrlString stringByAppendingString:self.emal.text];
    
    NSURL *url=[NSURL URLWithString:hostMessage];
    NSString *post =[[NSString alloc] initWithFormat:@"email=%@",self.emal.text];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    
}

- (IBAction)recordVideo:(id)sender {
    
    if (_webSocket == nil) {
        _webSocket = [[SRWebSocket alloc] initWithURLRequest:self.webSocketRequest];
        _webSocket.delegate = self;
    
        self.title = @"Opening Connection...";
        [_webSocket open];
        _stopVideoButton.enabled = NO;
        self.startRecording = YES;
    } else {
        [self.videoCamera start];
        _stopVideoButton.enabled = YES;

    }
    _startVideoButton.enabled = NO;
}

-(IBAction) stopVideo:(id)sender
{
    _startVideoButton.enabled = YES;
    _stopVideoButton.enabled = NO;
    [self.videoCamera stop];
    [_webSocket close];
    _webSocket.delegate = nil;
    _webSocket = nil;
 
    self.startRecording = NO;
   ;
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
    self.title = @"Connected!";
    if (self.startRecording) {
        [self.videoCamera start];
        _stopVideoButton.enabled = YES;
    }
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
    _startVideoButton.enabled = YES;
    _stopVideoButton.enabled = NO;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.emal resignFirstResponder];
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

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    
    
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
    
    NSString *sentEmailString = @"Email Sent to ";
    NSString *message = [sentEmailString stringByAppendingString:self.emal.text];
    
    UIAlertView* mes=[[UIAlertView alloc]
                      initWithTitle: message
                      message: @""
                      delegate:self
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles: nil];
     [mes show];
    
    self.emal.text = @"";
    
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

@end
