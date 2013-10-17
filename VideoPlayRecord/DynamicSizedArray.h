//
//  DynamicSizedArray.h
//  NSDataLinkedList
//
//  Created by Sam Davies on 27/09/2012.
//  Copyright (c) 2012 VisualPutty. All rights reserved.
//

#import <Foundation/Foundation.h>

#define INVALID_NODE_CONTENT INT_MIN

@protocol DynamicSizedArray <NSObject>

@required
- (id)initWithCapacity:(int)capacity;

- (void)pushBack:(const char *)p;
- (void)pushFront:(const char *)p;

- (const char *)popBack;
- (const int)popFront;

@end
