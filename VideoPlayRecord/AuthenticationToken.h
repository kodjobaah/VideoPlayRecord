//
//  AuthenticationToken.h
//  VideoPlayRecord
//
//  Created by Valtech UK on 06/10/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AuthenticationToken : NSManagedObject

@property (nonatomic, retain) NSString * playSession;

@end
