//
//  PropertyAccessor.m
//  VideoPlayRecord
//
//  Created by Valtech UK on 07/10/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import "PropertyAccessor.h"

@implementation PropertyAccessor

@synthesize properties = _properties;

- (id) init {
    self = [super init];
    if (self != nil) {
        NSString *errorDesc = nil;
        NSPropertyListFormat format;
        NSString *plistPath;
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask, YES) objectAtIndex:0];
        plistPath = [rootPath stringByAppendingPathComponent:@"whatAmIdoing.plist"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
            plistPath = [[NSBundle mainBundle] pathForResource:@"whatAmIdoing" ofType:@"plist"];
        }
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        self.properties = (NSDictionary *)[NSPropertyListSerialization
                                              propertyListFromData:plistXML
                                              mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                              format:&format
                                              errorDescription:&errorDesc];

    }
    return self;
}

-(NSString *) getPropertyValue:(NSString *)key
{
    
    return [self.properties objectForKey:key];
    
}

@end
