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
#import "WhatAmIDoingAppDelegate.h"
#import "PropertyAccessor.h"
#import "WhatAmIDoingViewController.h"
#import "InviteEmailList.h"
#import "NSData+Base64.h"


using namespace cv;

@interface RecordVideoViewController ()

@end

@implementation RecordVideoViewController

@synthesize whatAmIdoingPort = _whatAmIdoingPort;
@synthesize whatAmIdoingWebSocket = _whatAmIdoingWebSocket;
@synthesize sendInvite = _sendInvite;
@synthesize constants = _constants;
@synthesize action = _action;
@synthesize token = _token;
@synthesize responseData = _responseData;
@synthesize publishVideoUrl = _publishVideoUrl;
@synthesize startRecording = _startRecording;
@synthesize videoCamera = _videoCamera;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize propertyAccessor = _propertyAccessor;
@synthesize errorOccured = _errorOccured;
@synthesize logout = _logout;
@synthesize actionSheet = _actionSheet;
@synthesize pickerView = _pickerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.emal resignFirstResponder];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.propertyAccessor = [[PropertyAccessor alloc] init];
    self.constants = [[WhatAmIDoingConstants alloc] init];
    self.action = [self.constants nothing];
    self.errorOccured = NO;
    self.startRecording = 0;
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
    NSString *whatAmIdoingUrl = [self.propertyAccessor getPropertyValue:@"WHAT_AM_I_DOING_URL"];
    NSString *url = [NSString stringWithFormat:@"ws://%@/publishVideo?token=%@",whatAmIdoingUrl,self.token.playSession];
    self.publishVideoUrl = url;
    self.whatAmIdoingPort= [[self.propertyAccessor getPropertyValue:@"WHAT_AM_I_DOING_PORT"] intValue];
    
    
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
    
    /*
     * Creating the websocket request used to publish the movie
     */
    self.whatAmIdoingWebSocket = [[WhatAmIDoingWebSocket alloc] initWithCamera:self.videoCamera];
    self.whatAmIdoingWebSocket.recordingStatus = 0;
    self.whatAmIdoingWebSocket.startVideoButton = self.startVideoButton;
    self.whatAmIdoingWebSocket.stopVideoButton = self.stopVideoButton;
    
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
    // NSLog(@"PROCED IAMGE 1");
    if ([self.whatAmIdoingWebSocket connectionStatus]) {
        
        @autoreleasepool {
            
            Mat image_copy;
            UIImage *resultUIImage = [self UIImageFromCVMat:image];
            NSData *tempData = [NSData dataWithData:UIImageJPEGRepresentation(resultUIImage,1.0)];
            [self.whatAmIdoingWebSocket send:tempData];
            tempData = nil;
            resultUIImage = nil;
        }
        
        
    }
    
}
#endif
- (IBAction)invite:(id)sender {
    
    if([[self.emal.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] == 0) {
        NSString *title = @"Invite";
        NSString *message = @"Please enter an Email";
        UIAlertView* mes=[[UIAlertView alloc]
                          initWithTitle: title
                          message: message
                          delegate:self
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles: nil];
        [mes show];
    }else if([self.whatAmIdoingWebSocket connectionStatus] == 1) {
        self.action = [self.constants inviteAction];
        [self.sendInvite sendInvitation:self.token.playSession];
    } else {
        NSString *title = @"Invite";
        NSString *message = @"You need start recording..before you can invite someone to watch";
        UIAlertView* mes=[[UIAlertView alloc]
                          initWithTitle: title
                          message: message
                          delegate:self
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles: nil];
        [mes show];
    }
}

- (IBAction)recordVideo:(id)sender {
    
    [self.videoCamera start];
    [self.whatAmIdoingWebSocket open:self.token.playSession];
    
    
}

-(IBAction) stopVideo:(id)sender
{
    if (self.whatAmIdoingWebSocket.connectionStatus == 1) {
        _startVideoButton.enabled = YES;
        _stopVideoButton.enabled = NO;
        [self.videoCamera stop];
        [self.whatAmIdoingWebSocket close];
        self.startRecording = NO;
    }
    
}
- (IBAction)logout:(id)sender {
    
    
    if (self.whatAmIdoingWebSocket.connectionStatus == 1) {
        [self.videoCamera stop];
        [self.whatAmIdoingWebSocket close];
        
        _startVideoButton.enabled = NO;
        _stopVideoButton.enabled = NO;
        self.startRecording = NO;
    }
    
    self.action = [self.constants logoutAction];
    [self.logout logout:self.token.playSession];
    
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

- (IBAction)displayInvitePicker:(id)sender {
    
    InviteEmailList *inviteEmailList = [[InviteEmailList alloc] initWithData:self.emal];
    
    [inviteEmailList displayInvites:sender theToken:self.token.playSession];
    
    
}

@end
