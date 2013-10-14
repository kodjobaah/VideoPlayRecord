//
//  WhatAmIDoingConstants.m
//  VideoPlayRecord
//
//  Created by Valtech UK on 14/10/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import "WhatAmIDoingConstants.h"

static WhatAmIDoingConstants * instance;

@implementation WhatAmIDoingConstants


@dynamic logoutAction;
@dynamic nothing;
@dynamic authenticationToken;
@dynamic inviteAction;
@dynamic registerOrLoginId;



- (NSString *)registerOrLoginId
{
    return @"RegisterOrLogin";
};

- (NSString *)authenticationToken
{
    return @"AuthenticationToken";
};


- (NSString *)nothing
{
    return @"NOTHING_ACTION";
};


- (NSString *)inviteAction
{
    return @"INVITE_ACTION";
};

- (NSString *)logoutAction
{
    return @"LOGOUT_ACTION";
};

+ (void)initialize
{
    if (!instance) {
        instance = [[super allocWithZone:NULL] init];
    }
}

+ (id)allocWithZone:(NSZone * const)notUsed
{
    return instance;
}

@end
