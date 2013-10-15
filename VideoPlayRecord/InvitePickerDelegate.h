//
//  InvitePickerDelegate.h
//  VideoPlayRecord
//
//  Created by Valtech UK on 14/10/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InvitePickerDelegate : NSObject<UIPickerViewDelegate> {
    NSArray *pickerData; // Array to keep items of dropdown
    UITextField *email;

}

@property(nonatomic,retain)  NSArray *pickerData;
@property(nonatomic, retain) UITextField *email;

-(InvitePickerDelegate *) initWithData:(NSArray *)data email:(UITextField *)theEmail;

@end
