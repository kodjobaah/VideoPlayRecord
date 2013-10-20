//
//  NSLinkedList.m
//
//  Created by Matt Schettler on 5/30/10.
//  Copyright 2010-2013 mschettler@gmail.com. All rights reserved.
//
//  V1.4.2
//


#import "NSLinkedList.h"

// 100% Support for both ARC and non-ARC projects
#if __has_feature(objc_arc)
#define SAFE_ARC_PROP_RETAIN strong
#define SAFE_ARC_RETAIN(x) (x)
#define SAFE_ARC_RELEASE(x)
#define SAFE_ARC_AUTORELEASE(x) (x)
#define SAFE_ARC_BLOCK_COPY(x) (x)
#define SAFE_ARC_BLOCK_RELEASE(x)
#define SAFE_ARC_SUPER_DEALLOC()
#define SAFE_ARC_AUTORELEASE_POOL_START() @autoreleasepool {
#define SAFE_ARC_AUTORELEASE_POOL_END() }
#else
#define SAFE_ARC_PROP_RETAIN retain
#define SAFE_ARC_RETAIN(x) ([(x) retain])
#define SAFE_ARC_RELEASE(x) ([(x) release])
#define SAFE_ARC_AUTORELEASE(x) ([(x) autorelease])
#define SAFE_ARC_BLOCK_COPY(x) (Block_copy(x))
#define SAFE_ARC_BLOCK_RELEASE(x) (Block_release(x))
#define SAFE_ARC_SUPER_DEALLOC() ([super dealloc])
#define SAFE_ARC_AUTORELEASE_POOL_START() NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
#define SAFE_ARC_AUTORELEASE_POOL_END() [pool release];
#endif


@implementation TNode

@synthesize next,prev;
@synthesize obj;

@end

@implementation NSLinkedList
@synthesize first, last;


- (id)init {
    
    if ((self = [super init]) == nil) return nil;
    
    first = last = nil;
    size = 0;
    
    return self;
}

- (void)pushFront:(id)anObject {
    
    if (anObject == nil) return;
    TNode *n = TNodeMake(anObject, first, nil);
    
    if (size == 0) {
        first = last = n;
    } else {
        first.prev = n;
        first = n;
    }
    
    anObject =  nil;
    size++;
   // NSLog(@"this is the size:%u",size);
    
}



- (id)popBack {
    
    if (size == 0) return nil;
    
    id ret = SAFE_ARC_RETAIN(last.obj);
    last.obj = nil;
    [self removeNode:last];
    
    return SAFE_ARC_AUTORELEASE(ret);
    
}

- (void)removeNode:(TNode *)aNode {
    
    @autoreleasepool {
        
        if (size == 0) return;
        
        if (size == 1) {
            // delete first and only
            first = last = nil;
        } else if (aNode.prev == nil) {
            // delete first of many
            first = first.next;
            first.prev = nil;
        } else if (aNode.next == nil) {
            // delete last
            last = last.prev;
            last.next.obj = nil;
            last.next = nil;
        } else {
            // delete in the middle
            TNode *tmp = aNode.prev;
            tmp.next = aNode.next;
            tmp = aNode.next;
            tmp.prev = aNode.prev;
        }
        
        aNode.obj = nil;
        SAFE_ARC_RELEASE(aNode.obj);
    }
    size--;
}

- (void)dumpList {
    TNode *n = nil;
    for (n = first; n; n=n.next) {
        NSLog(@"%p", n);
    }
}

- (int)count  { return size; }
- (int)size   { return size; }
- (int)length { return size; }


- (NSString *)description {
    return [NSString stringWithFormat:@"NSLinkedList with %d objects", size];
}

@end

TNode * TNodeMake(id obj, TNode *next, TNode *prev) {
    TNode *n = [TNode alloc];
    n.next = next;
    n.prev = prev;
    n.obj = obj;
    obj = nil;
    return n;
};




