//
//  Logout.h
//  VideoPlayRecord
//
//  Created by Valtech UK on 14/10/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WhatAmIDoingConstants.h"

@interface Logout : NSObject<NSURLConnectionDelegate> {
}

@property (nonatomic, strong) UIViewController * recordVideoViewController;
@property (nonatomic, strong) WhatAmIDoingConstants *constants;
@property (nonatomic, strong) NSMutableData *responseData;
-(Logout*) initWithController:(UIViewController *) rccv;
-(void) logout:(NSString *) token;
@end
