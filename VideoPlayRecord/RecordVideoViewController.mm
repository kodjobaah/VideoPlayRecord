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
#import "WhatAmIDoingViewController.h"

using namespace cv;

@interface RecordVideoViewController ()



@end

@implementation RecordVideoViewController

@synthesize sendInvite = _sendInvite;
@synthesize constants = _constants;
@synthesize action = _action;
@synthesize token = _token;
@synthesize responseData = _responseData;
@synthesize publishVideoUrl = _publishVideoUrl;
@synthesize webSocket = _webSocket;
@synthesize webSocketRequest = _webSocketRequest;
@synthesize startRecording = _startRecording;
@synthesize videoCamera = _videoCamera;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize propertyAccessor = _propertyAccessor;
@synthesize errorOccured = _errorOccured;

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
    self.constants = [[WhatAmIDoingConstants alloc] init];
    self.action = [self.constants nothing];
    self.errorOccured = NO;
    _startVideoButton.enabled = YES;
    _stopVideoButton.enabled = NO;
    self.sendInvite = [[SendInvite alloc] initWithEmail: self.emal];
    self.logout = [[Logout alloc] initWithController:self];

    
    /*
     * Getting the authentication token from core data
     */
    WhatAmIDoingAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[self.constants authenticationToken]
                                              inManagedObjectContext:appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *fetchedObjects = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    self.token  =  [fetchedObjects objectAtIndex: 0];
    
    /*
     * Create the url used to publish videos
     */
    self.propertyAccessor = [[PropertyAccessor alloc] init];
    NSString * url = [NSString stringWithFormat:@"ws://5.79.24.141:9000/publishVideo?token=%@",self.token.playSession];
    self.publishVideoUrl = url;
   
    NSLog(@"---------publishurl-%@--",self.publishVideoUrl);
    /*
     * Creating the websocket request used to publish the movie
     */
    NSURL *urlNew = [NSURL URLWithString:self.publishVideoUrl];
    self.webSocketRequest = [NSMutableURLRequest requestWithURL:urlNew];
    NSLog(@"---------prequest url-%@--",self.webSocketRequest.URL);
    
    /*
     * Setting the video camera
     */
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:_displayImage];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.delegate = self;
    self.videoCamera.grayscaleMode = NO;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"---------------------------- RECEIVED MEMORY WARNING ---------");
    // Dispose of any resources that can be recreated.
}

#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus
- (void)processImage:(Mat&)image;
{
    if (self.startRecording == YES) {
        Mat image_copy;
        UIImage *resultUIImage = [self UIImageFromCVMat:image];
        NSData *tempData = [NSData dataWithData:UIImageJPEGRepresentation(resultUIImage,1.0)];
        NSString* ns = [tempData base64EncodedString];
        
        
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        [parameters setObject:ns forKey:@"frame"];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters  options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString * converted =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        //NSLog(@"Data =%@",converted);
        [self.webSocket send:converted];

        
    }
    
}
#endif
- (IBAction)invite:(id)sender {
    self.action = [self.constants inviteAction];
    [self.sendInvite sendInvitation:self.token.playSession];
    
}

- (IBAction)recordVideo:(id)sender {
    
    if (self.webSocket == nil) {
        NSLog(@"---request-url:%@:",self.webSocketRequest.URL);
        self.webSocket = [[SRWebSocket alloc]  initWithURLRequest:self.webSocketRequest];
        self.webSocket.delegate = self;
        
        self.title = @"Opening Connection...";
        [self.webSocket open];
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
    [self.webSocket close];
    self.webSocket.delegate = nil;
    self.webSocket = nil;
    
    self.startRecording = NO;
    
}
- (IBAction)logout:(id)sender {
    
    [self.videoCamera stop];
    [self.webSocket close];
    self.webSocket.delegate = nil;
    self.webSocket = nil;
    _startVideoButton.enabled = NO;
    _stopVideoButton.enabled = NO;
    self.startRecording = NO;
    
    self.action = [self.constants logoutAction];
    
    [self.logout logout:self.token.playSession];
    
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
    self.webSocket = nil;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    WhatAmIDoingViewController *viewController = (WhatAmIDoingViewController *)[storyboard instantiateViewControllerWithIdentifier:@"RegisterOrLogin"];
    [self presentViewController:viewController animated:YES completion:nil];
    
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    NSLog(@"Received \"%@\"", message);
    
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed");
    self.title = @"Connection Closed! (see logs)";
    self.webSocket = nil;
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


@end
