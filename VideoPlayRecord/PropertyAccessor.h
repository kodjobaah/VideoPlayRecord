//
//  PropertyAccessor.h
//  VideoPlayRecord
//
//  Created by Valtech UK on 07/10/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PropertyAccessor : NSObject {
    NSDictionary *properties;
}


@property (weak) NSDictionary *properties;
- (NSString *) getPropertyValue:(NSString *)key;
@end
