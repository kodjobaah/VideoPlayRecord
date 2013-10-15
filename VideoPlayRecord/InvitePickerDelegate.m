//
//  InvitePickerDelegate.m
//  VideoPlayRecord
//
//  Created by Valtech UK on 14/10/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import "InvitePickerDelegate.h"

@implementation InvitePickerDelegate

@synthesize email = _email;
@synthesize pickerData = _pickerData;

-(InvitePickerDelegate *) initWithData:(NSArray *)data email:(UITextField *)theEmail {
    self = [super init];
    
    if(self) {
        _pickerData = data;
        _email = theEmail;
    }
    return self;
}



#pragma mark Picker Delegate Methods 
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component{
    
    //NSLog(@"Selected Row %d", row);
   // self.email.text = [self.pickerData objectAtIndex:row];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component  {
    return [self.pickerData objectAtIndex:row];
}
@end
