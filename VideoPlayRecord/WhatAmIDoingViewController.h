//
//  WhatAmIDoingViewController.h
//  VideoPlayRecord
//
//  Created by Valtech UK on 26/08/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PropertyAccessor.h"

@interface WhatAmIDoingViewController : UIViewController<NSURLConnectionDelegate> {
    NSMutableData *responseData;
    NSManagedObjectContext *managedObjectContext;
    NSString *whatAmIdoingUrl;
    NSString *registerUrl;
    PropertyAccessor *propertyAccessor;
    NSString *playSession;
    
}

@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSString *playSession;
@property (nonatomic, strong) PropertyAccessor *propertyAccessor;
@property (nonatomic, strong) NSString *registerUrl;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSString *whatAmIdoingUrl;

@property (weak, nonatomic) IBOutlet UIButton *registerOrJoin;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;

@end
