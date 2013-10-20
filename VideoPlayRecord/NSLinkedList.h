//
//  NSLinkedList.h
//
//  Created by Matt Schettler on 5/30/10.
//  Copyright 2010-2013 mschettler@gmail.com. All rights reserved.
//
//  V1.4.2
//

#import <Foundation/Foundation.h>


@interface TNode: NSObject {
    TNode *next;
    TNode *prev;
    id obj;
  
}
@property (atomic,retain) TNode *next;
@property (atomic,retain) TNode *prev;
@property (atomic,retain) id obj;

@end;

@interface NSLinkedList : NSObject {

    TNode *first;
    TNode *last;

    unsigned int size;
    NSMutableArray *needToBeRelease;

}

- (id)init;                                 // init an empty list
+ (id)listWithObject:(id)anObject;          // init the linked list with a single object
- (id)initWithObject:(id)anObject;          // init the linked list with a single object
- (void)pushBack:(id)anObject;              // add an object to back of list
- (void)pushFront:(id)anObject;             // add an object to front of list
- (void)addObject:(id)anObject;             // same as pushBack
- (id)popBack;                              // remove object at end of list (returns it)
- (id)popFront;                             // remove object at front of list (returns it)
- (BOOL)removeObjectEqualTo:(id)anObject;   // removes object equal to anObject, returns (YES) on success
- (void)removeAllObjects;                   // clear out the list
- (void)dumpList;                           // dumps all the pointers in the list to NSLog
- (BOOL)containsObject:(id)anObject;        // (YES) if passed object is in the list, (NO) otherwise
- (int)count;                               // how many objects are stored
- (int)size;                                // how many objects are stored
- (int)length;                              // how many objects are stored
- (void)pushNodeBack:(TNode *)n;            // adds a node object to the end of the list
- (void)pushNodeFront:(TNode *)n;           // adds a node object to the beginning of the list
- (void)removeNode:(TNode *)aNode;          // remove a given node


- (id)objectAtIndex:(const int)idx;
- (id)lastObject;
- (id)firstObject;
- (id)secondLastObject;
- (id)top;

- (TNode *)firstNode;
- (TNode *)lastNode;

- (NSArray *)allObjects;
- (NSArray *)allObjectsReverse;


// Insert objects
- (void)insertObject:(id)anObject beforeNode:(TNode *)node;
- (void)insertObject:(id)anObject afterNode:(TNode *)node;
- (void)insertObject:(id)anObject betweenNode:(TNode *)previousNode andNode:(TNode *)nextNode;

- (void)insertObject:(id)anObject orderedPositionByKey:(NSString *)key ascending:(BOOL)ascending;

// Prepend/append - simple references to keep my sanity
- (void)prependObject:(id)anObject;
- (void)appendObject:(id)anObject;

//- (void)replaceObjectAtIndex:(int) withObject:(id)obj;    // replaces object at a given index with the passed object

@property (atomic,retain) TNode *first;
@property (atomic,retain) TNode *last;
@property (atomic, retain) NSMutableArray *needToBeRelease;

@end

TNode * TNodeMake(id obj, TNode *next, TNode *prev);    // convenience method for creating a LNode
