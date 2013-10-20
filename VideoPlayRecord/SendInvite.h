//
//  SendInvite.h
//  VideoPlayRecord
//
//  Created by Valtech UK on 14/10/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PropertyAccessor.h"
@interface SendInvite : NSObject<NSURLConnectionDelegate>{
     PropertyAccessor *propertyAccessor;   
    
}
@property (atomic,strong) PropertyAccessor *propertyAccessor;
@property (nonatomic, retain) UITextField *emal;
@property (nonatomic, retain) NSMutableData *responseData;
-(SendInvite*) initWithEmail:(UITextField*) email;
-(void) sendInvitation:(NSString *) token;
@end
