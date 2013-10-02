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
}

@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *repeatPassword;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;

@end
