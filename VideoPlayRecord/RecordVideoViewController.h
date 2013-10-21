//
//  RecordVideoViewController.h
//  VideoPlayRecord
//
//  Created by Valtech UK on 26/08/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/highgui/cap_ios.h>

#import "AuthenticationToken.h"
#import "PropertyAccessor.h"
#import "WhatAmIDoingConstants.h"
#import "SendInvite.h"
#import "Logout.h"
#import "InvitePickerDelegate.h"
#import "InvitePickerDataSource.h"
#import "NSLinkedList.h"
#import "FrameReader.h"



@interface RecordVideoViewController : UIViewController {
    
    NSMutableArray *_messages;
    NSMutableData *responseData;
    NSManagedObjectContext *managedObjectContext;
    NSOperationQueue *queue;
    
    BOOL *errorOccurred;
    NSString *action;
  
    UIActionSheet *actionSheet; // in which we open picker dynamically
    UIPickerView *pickerView;
    
    AuthenticationToken *authenticationToken;
    PropertyAccessor *propertyAccessor;
    AuthenticationToken *token;
    WhatAmIDoingConstants *constants;
    SendInvite *sendInvite;
    Logout *logout;
    FrameReader *frameReader;
    
}

//Framework guis
@property (nonatomic, retain) UIPickerView *pickerView;
@property (nonatomic,retain) IBOutlet UIActionSheet *actionSheet;

//Actions
@property (nonatomic, strong) NSString *action;
@property (nonatomic) BOOL *errorOccured;
@property (nonatomic, strong, readonly) NSString *message;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) CvVideoCamera* videoCamera;
@property (nonatomic, strong) NSOperationQueue *queue;

@property (weak, nonatomic) IBOutlet UIImageView *displayImage;
@property (weak, nonatomic) IBOutlet UIButton *startVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *stopVideoButton;
@property (weak, nonatomic) IBOutlet UITextField *emal;

@property (nonatomic, retain) FrameReader *frameReader;
@property (nonatomic, strong) Logout *logout;
@property (nonatomic, strong) SendInvite *sendInvite;
@property (nonatomic, strong) WhatAmIDoingConstants *constants;
@property (nonatomic, strong) AuthenticationToken *token;
@property (nonatomic, strong) PropertyAccessor *propertyAccessor;

- (IBAction)stopVideo:(UIButton *)sender;
- (IBAction)recordVideo:(id)sender;
- (IBAction)invite:(id)sender;
- (IBAction)logout:(id)sender;
- (IBAction)displayInvitePicker:(id)sender;


@end
