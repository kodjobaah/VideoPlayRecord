//
//  LinkedList.h
//  NSDataLinkedList
//
//  Created by Sam Davies on 26/09/2012.
//  Copyright (c) 2012 VisualPutty. All rights reserved.
//

#import <Foundation/Foundation.h>
#define FINAL_NODE_OFFSET -1

#define MAXBUFFERSIZE   3000

@interface LinkedList : NSObject

- (void)pushFront:(char *)p;

- (char *)popBack;
@end
