//
//  InviteEmailList.h
//  VideoPlayRecord
//
//  Created by Valtech UK on 14/10/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PropertyAccessor.h"

@interface InviteEmailList : NSObject<NSURLConnectionDelegate> {
    
    UITextField *email;
    NSMutableData *responseData;
    id sender;
    PropertyAccessor *propertyAccessor;
}

@property (atomic,strong) PropertyAccessor *propertyAccessor;
@property(nonatomic, retain) id sender;
@property(nonatomic,retain) NSMutableData *responseData;
@property(nonatomic,retain) UITextField *email;

-(InviteEmailList *) initWithData:(UITextField *)theEmail;
-(void) displayInvites:(id)theSender theToken:(NSString *) token;
@end
