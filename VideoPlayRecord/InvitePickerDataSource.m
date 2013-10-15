//
//  InvitePickerDataSource.m
//  VideoPlayRecord
//
//  Created by Valtech UK on 14/10/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import "InvitePickerDataSource.h"

@implementation InvitePickerDataSource

@synthesize data = _data;

-(InvitePickerDataSource*) initWithData:(NSArray *) theData {
    self = [super init];
    
    if(self) {
        _data = theData;
    }
    return self;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.data count];
}

@end
