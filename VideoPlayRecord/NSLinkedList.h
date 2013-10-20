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

}

- (id)init;                                 // init an empty list
- (void)pushFront:(id)anObject;             // add an object to front of list
- (id)popBack;                              // remove object at end of list (returns it)
- (int)count;                               // how many objects are stored
- (int)size;                                // how many objects are stored
- (int)length;                              // how many objects are stored
- (void)removeNode:(TNode *)aNode;          // remove a given node


@property (atomic,retain) TNode *first;
@property (atomic,retain) TNode *last;

@end



TNode * TNodeMake(id obj, TNode *next, TNode *prev);    // convenience method for creating a TNode
