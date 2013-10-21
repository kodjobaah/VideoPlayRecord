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




static NSDate * theDate = nil;


@interface RecordVideoViewController ()

@end


@implementation RecordVideoViewController

@synthesize queue = _queue;
@synthesize frameReader = _frameReader;
@synthesize sendInvite = _sendInvite;
@synthesize constants = _constants;
@synthesize action = _action;
@synthesize token = _token;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize propertyAccessor = _propertyAccessor;
@synthesize errorOccured = _errorOccured;
@synthesize logout = _logout;
@synthesize actionSheet = _actionSheet;
@synthesize pickerView = _pickerView;

static int counter = 0;

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
    self.queue = [[NSOperationQueue alloc] init];
    self.errorOccured = NO;
   
    _startVideoButton.enabled = YES;
    _stopVideoButton.enabled = NO;
    self.sendInvite = [[SendInvite alloc] initWithEmail: self.emal];
    self.logout = [[Logout alloc] initWithController:self];
    
    frameReader = [[FrameReader alloc] initWithData:_displayImage];
    
    
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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"---------------------------- RECEIVED MEMORY WARNING ---------");
    // Dispose of any resources that can be recreated.
}

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
    }else if([self.frameReader getStatus] == 1) {
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
    
    [self.queue addOperation:frameReader];
    _startVideoButton.enabled = NO;
    _stopVideoButton.enabled = YES;
}

-(IBAction) stopVideo:(id)sender
{
    if (self.frameReader.getStatus == 1) {
        _startVideoButton.enabled = YES;
        _stopVideoButton.enabled = NO;
    }
    
}
- (IBAction)logout:(id)sender {
    
    
    if (self.frameReader.getStatus == 1) {
        [self.frameReader completeOperation];
        _startVideoButton.enabled = NO;
        _stopVideoButton.enabled = NO;
    }
    
    self.action = [self.constants logoutAction];
    [self.logout logout:self.token.playSession];
    
}

- (IBAction)displayInvitePicker:(id)sender {
    
    InviteEmailList *inviteEmailList = [[InviteEmailList alloc] initWithData:self.emal];
    
    [inviteEmailList displayInvites:sender theToken:self.token.playSession];
    
    
}

@end
