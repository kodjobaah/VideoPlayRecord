//
//  WhatAmIDoingViewController.h
//  VideoPlayRecord
//
//  Created by Valtech UK on 26/08/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WhatAmIDoingViewController : UIViewController<NSURLConnectionDelegate> {
    NSMutableData *_responseData;
    NSManagedObjectContext *managedObjectContext;
    NSString *_playSession;
    NSString *whatAmIdoingUrl;
    NSString *registerUrl;

}

@property (nonatomic, retain) NSString *registerUrl;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSString *whatAmIdoingUrl;
@property (nonatomic, retain) NSString *_playSession;

@property (weak, nonatomic) IBOutlet UIButton *registerOrJoin;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;

@end
