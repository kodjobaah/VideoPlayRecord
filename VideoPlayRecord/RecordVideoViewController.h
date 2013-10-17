//
//  RecordVideoViewController.h
//  VideoPlayRecord
//
//  Created by Valtech UK on 26/08/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRWebSocket.h"
#import <opencv2/highgui/cap_ios.h>
#import "AuthenticationToken.h"
#import "PropertyAccessor.h"
#import "WhatAmIDoingConstants.h"
#import "SendInvite.h"
#import "Logout.h"
#import "InvitePickerDelegate.h"
#import "WhatAmIDoingWebSocket.h"
#import "InvitePickerDataSource.h"



@interface RecordVideoViewController : UIViewController<CvVideoCameraDelegate,SRWebSocketDelegate,NSURLConnectionDelegate> {
    SRWebSocket *webSocket;
    NSMutableArray *_messages;
    CvVideoCamera *videoCamera;
    NSMutableData *responseData;
    AuthenticationToken *authenticationToken;
    NSManagedObjectContext *managedObjectContext;
    NSMutableURLRequest *webSocketRequest;
    BOOL startRecording;
    BOOL *errorOccurred;
    NSString *publishVideoUrl;
    PropertyAccessor *propertyAccessor;
    AuthenticationToken *token;
    NSString *action;
    WhatAmIDoingConstants *constants;
    SendInvite *sendInvite;
    Logout *logout;
    UIActionSheet *actionSheet; // in which we open picker dynamically
    UIPickerView *pickerView;
    WhatAmIDoingWebSocket *whatAmIdoingWebSocket;
    
}

@property (nonatomic, strong) WhatAmIDoingWebSocket *whatAmIdoingWebSocket;
@property (nonatomic, retain) UIPickerView *pickerView;
@property (nonatomic,retain) IBOutlet UIActionSheet *actionSheet;
@property (nonatomic, strong) Logout *logout;
@property (nonatomic, strong) SendInvite *sendInvite;
@property (nonatomic, strong) WhatAmIDoingConstants *constants;
@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) AuthenticationToken *token;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic) BOOL *errorOccured;
@property (nonatomic, strong) PropertyAccessor *propertyAccessor;
@property (nonatomic, strong) NSString *publishVideoUrl;
@property (nonatomic, strong) SRWebSocket *webSocket;
@property (strong, nonatomic) NSMutableURLRequest *webSocketRequest;
@property (nonatomic) BOOL startRecording;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSString *message;
@property (nonatomic, strong) CvVideoCamera* videoCamera;
@property (weak, nonatomic) IBOutlet UIImageView *displayImage;
@property (weak, nonatomic) IBOutlet UIButton *startVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *stopVideoButton;
@property (weak, nonatomic) IBOutlet UITextField *emal;
- (IBAction)stopVideo:(UIButton *)sender;
- (IBAction)recordVideo:(id)sender;
- (IBAction)invite:(id)sender;
- (IBAction)logout:(id)sender;
- (IBAction)displayInvitePicker:(id)sender;

@end
