//
//  InvitePickerDataSource.h
//  VideoPlayRecord
//
//  Created by Valtech UK on 14/10/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InvitePickerDataSource : NSObject<UIPickerViewDataSource>{
  
    NSArray * data;
}
@property (nonatomic, retain) NSArray *data;

-(InvitePickerDataSource*) initWithData:(NSArray *) theData;
@end
