//
//  LinkedList.m
//  NSDataLinkedList
//
//  Created by Sam Davies on 26/09/2012.
//  Copyright (c) 2012 VisualPutty. All rights reserved.
//

#import "LinkedList.h"

@implementation LinkedList

#pragma mark - Initialisation
- (id)init
{
    return [self initWithCapacity:1000];
}

- (id)initWithCapacity:(int)capacity
{
    return [self initWithCapacity:capacity incrementSize:1000];
}

- (id)initWithCapacity:(int)capacity incrementSize:(int)increment
{
    self = [super init];
    if(self) {
        _cacheSizeIncrements = increment;
        int bytesRequired = capacity * sizeof(Node);
        nodeCache = [[NSMutableData alloc] initWithLength:bytesRequired];
        [self initialiseNodesAtOffset:0 count:capacity];
        freeNodeOffset = 0;
        topNodeOffset = FINAL_NODE_OFFSET;
    }
    return self;
}

#pragma mark - Memory management
- (void)dealloc
{
}

#pragma mark - DynamicSizedArray Protocol methods
- (void)pushFront:(char *)p
{
    
    
   
        
    Node *node = [self getNextFreeNode];
        // and the length of the input string.
        size_t len = strlen(p);
        
        //allocate space for the result (including NUL terminator).
        node->value = malloc(len+1);
       memcpy(node->value,p,len);
    node->value[len] = '\0';
    
    //bcopy(p,&node->value,len);
    //node->value = p;
    node->nextNodeOffset = topNodeOffset;
    topNodeOffset = [self offsetOfNode:node];
}

- (void)pushBack:(char *)p
{
    // Prepare the new node
    Node *node = [self getNextFreeNode];
    node->value = p;
    node->nextNodeOffset = FINAL_NODE_OFFSET;
    
    // If the list is empty then just set topNodeOffset
    if(topNodeOffset == FINAL_NODE_OFFSET) {
        topNodeOffset = [self offsetOfNode:node];
    } else {
        // Otherwise, we need to find the current last node
        Node *searchNode = [self nodeAtOffset:topNodeOffset];
        while (searchNode->nextNodeOffset != FINAL_NODE_OFFSET) {
            searchNode = [self nodeAtOffset:searchNode->nextNodeOffset];
        }
        // searchNode is the current end node
        searchNode->nextNodeOffset = [self offsetOfNode:node];
    }
}

- (const char *)popFront
{
    if(topNodeOffset == FINAL_NODE_OFFSET) {
        return "-1";
    }
    
    Node *node = [self nodeAtOffset:topNodeOffset];
    int thisNodeOffset = topNodeOffset;
    
    // Remove this node from the queue
    topNodeOffset = node->nextNodeOffset;
    const char *value = node->value;
    
    // Reset it and add it to the free node cache
    node->value = 0;
    node->nextNodeOffset = freeNodeOffset;
    freeNodeOffset = thisNodeOffset;
    
    return value;
}

- (char *)popBack
{
    // Find the penultimate node
    if(topNodeOffset == FINAL_NODE_OFFSET) {
        // The queue is empty
        return "";
    }
    
    Node *searchNode = [self nodeAtOffset:topNodeOffset];
    if(searchNode->nextNodeOffset == FINAL_NODE_OFFSET) {
        // This is the case when there's one node
        topNodeOffset = FINAL_NODE_OFFSET;
    } else {
        // There's more than one node:
        Node *priorSearchNode = searchNode;
        searchNode = [self nodeAtOffset:searchNode->nextNodeOffset];
        while (searchNode->nextNodeOffset != FINAL_NODE_OFFSET) {
            priorSearchNode = searchNode;
            searchNode = [self nodeAtOffset:searchNode->nextNodeOffset];
        }
        // Change the last node
        priorSearchNode->nextNodeOffset = FINAL_NODE_OFFSET;
    }
    
    // Get the value we need to return
    const char *value = searchNode->value;

    // Make this node available again
    searchNode->nextNodeOffset = freeNodeOffset;
    searchNode->value = 0;
    freeNodeOffset = [self offsetOfNode:searchNode];
    
    return value;
}

#pragma mark - utility functions

- (int)offsetOfNode:(Node *)node
{
    return node - (Node *)nodeCache.mutableBytes;
}

- (Node *)nodeAtOffset:(int)offset
{
    return (Node *)nodeCache.mutableBytes + offset;
}

- (Node *)getNextFreeNode
{
    if(freeNodeOffset < 0) {
        // Need to extend the size of the nodeCache
        int currentSize = nodeCache.length / sizeof(Node);
        [nodeCache increaseLengthBy:_cacheSizeIncrements * sizeof(Node)];
        // Set these new nodes to be the free ones
        [self initialiseNodesAtOffset:currentSize count:_cacheSizeIncrements];
        freeNodeOffset = currentSize;
    }
    
    Node *node = (Node*)nodeCache.mutableBytes + freeNodeOffset;
    freeNodeOffset = node->nextNodeOffset;
    return node;
}


- (void)initialiseNodesAtOffset:(int)offset count:(int)count
{
    Node *node = (Node *)nodeCache.mutableBytes + offset;
    for (int i=0; i<count - 1; i++) {
        node->value = 0;
        node->nextNodeOffset = offset + i + 1;
        node++;
    }
    node->value = 0;
    // Set the next node offset to make sure we don't continue
    node->nextNodeOffset = FINAL_NODE_OFFSET;
}

@end
