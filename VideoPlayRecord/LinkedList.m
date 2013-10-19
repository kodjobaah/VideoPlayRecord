//
//  LinkedList.m
//  NSDataLinkedList
//
//  Created by Sam Davies on 26/09/2012.
//  Copyright (c) 2012 VisualPutty. All rights reserved.
//

#import "LinkedList.h"



@implementation LinkedList

struct Node
{
    struct Node *previous;
    char data[MAXBUFFERSIZE];
    struct Node *next;
}*head, *last;



- (void)pushFront:(char *)p
{

    NSLog(@"about to push");
    size_t len = strlen(p);
    struct Node *temp;
    
    struct Node var= {NULL,*p,NULL};
    
    //ar->data = malloc(sizeof(len));
    //var->data[0] = '\0';
    NSLog(@"about to push 1");

    //sprintf(var->data, "%s", p);
    NSLog(@"about to push 2");

    //var->data[len]='\0';
    NSLog(@"about to push 3");

    NSLog(@"added:%s",var.data);
    if(head==NULL)
    {
        head=&var;
        head->previous=NULL;
        head->next=NULL;
        last=head;
    }
    else
    {
        temp=&var;
        temp->previous=NULL;
        temp->next=head;
        head->previous=temp;
        head=temp;
    }
}

- (char *)popBack
{
    struct Node *temp;
    temp=last;
    if(temp->previous==NULL)
    {
        free(temp);
        head=NULL;
        last=NULL;
        return "";
    }
    
    if (last != NULL) {
        printf("removing data");
        // printf("\nData deleted from list is %s \n",last->data);
        last=temp->previous;
        last->next=NULL;
        size_t len = strlen(temp->data);
        
        char out[len];
        out[0] = '\0';
        
        sprintf(out, "%s", temp->data);
        free(temp);
        return out;
    }
    return "";
}

@end
