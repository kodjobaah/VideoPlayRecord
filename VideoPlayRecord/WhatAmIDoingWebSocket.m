//
//  WhatAmIDoingWebSocket.m
//  VideoPlayRecord
//
//  Created by Valtech UK on 17/10/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import "WhatAmIDoingWebSocket.h"


// Used to create private methods
@interface WhatAmIDoingWebSocket()

- (void) dequeueAndTransmit;

@end

@implementation WhatAmIDoingWebSocket

@synthesize propertyAccessor = _propertyAccessor;

static struct libwebsocket* wsi;
static struct libwebsocket_context *context;
static  NSLinkedList *theQueue;
int force_exit = 0;
int count = 0;

static int pollingInterval = 0;

static int status = 0;

-(WhatAmIDoingWebSocket *) init {
    self = [super init];
    status = 0;
    
    if(self) {
        self.propertyAccessor = [[PropertyAccessor alloc] init];
    }
    
    return self;
}

-(int) connectionStatus {
    
    if (status == 1)
        return YES;
    
    return NO;
    
}
-(void) close {
     NSLog(@"CLOSING WEBSOCKETS:%d",status);
    status = 0;
}


static int http_only(struct libwebsocket_context *context,
                         struct libwebsocket *wsi,
                         enum libwebsocket_callback_reasons reason, void *user,
                         void *in, size_t len)
{
    switch (reason) {
            
        case LWS_CALLBACK_CLOSED:
            NSLog(@"--- libwebsocket close");
            libwebsocket_context_destroy(context);
            status =0;
            break;
            
        case LWS_CALLBACK_CLIENT_ESTABLISHED: {
            
            status = 1;
            NSLog(@"pop");
             libwebsocket_callback_on_writable(context, wsi);
           
        }
        case LWS_CALLBACK_CLIENT_RECEIVE:
            status = 1;
            NSLog(@"--libwebsocket client receive--");
            break;
            
        case LWS_CALLBACK_CLIENT_WRITEABLE:
        {
        
            NSData *dataToWrite = [theQueue popBack];
            // NSLog(@"0 reference count = %ld", CFGetRetainCount((__bridge CFTypeRef)dataToWrite));
            unsigned char *response_buf;
            if (dataToWrite.length > 1) {
                
                //Base64 encoding
                BIO *context = BIO_new(BIO_s_mem());
                
                // Tell the context to encode base64
                BIO *command = BIO_new(BIO_f_base64());
                context = BIO_push(command, context);
                
                // Encode all the data
                BIO_write(context, [dataToWrite bytes], [dataToWrite length]);
                BIO_flush(context);
                
                // Get the data out of the context
                char *outputBuffer;
                long res = BIO_get_mem_data(context, &outputBuffer);
                int len = strlen(outputBuffer);
                response_buf = (unsigned char*) malloc(LWS_SEND_BUFFER_PRE_PADDING + len +LWS_SEND_BUFFER_POST_PADDING);
                bcopy(outputBuffer, &response_buf[LWS_SEND_BUFFER_PRE_PADDING], len);
                libwebsocket_write(wsi, &response_buf[LWS_SEND_BUFFER_PRE_PADDING], len, LWS_WRITE_TEXT);
                BIO_free_all(context);
                free(response_buf);
                response_buf = NULL;
                outputBuffer = NULL;
                dataToWrite = nil;
            }
            else {
                NSLog(@"Attempt to write empty data on the websocket");
            }
            //NSLog(@"--- libwebsocket client established");
            /*
             * start the ball rolling,
             * LWS_CALLBACK_CLIENT_WRITEABLE will come next service
             */
            
            libwebsocket_callback_on_writable(context, wsi);
            break;
        }
        default:
            break;
    }
    
    return 0;
}

/* dumb_increment protocol */

static int
callback_dumb_increment(struct libwebsocket_context * this,
                        struct libwebsocket *wsi,
                        enum libwebsocket_callback_reasons reason,
                        void *user, void *in, size_t len)
{
    switch (reason) {
            
        case LWS_CALLBACK_CLOSED:
            fprintf(stderr, "LWS_CALLBACK_CLOSED\n");
            break;
            
            /* because we are protocols[0] ... */
            
        case LWS_CALLBACK_CLIENT_CONFIRM_EXTENSION_SUPPORTED:
            break;
            
        default:
            break;
    }
    
    return 0;
}

void sighandler(int sig)
{
	force_exit = 1;
}


static void lwsl_emit_stderr(int level, const char *line)
{
	char buf[300];
	struct timeval tv;
	gettimeofday(&tv, NULL);
    
	buf[0] = '\0';
    sprintf(buf, "log - [%ld:%04d] ", tv.tv_sec,
            (int)(tv.tv_usec / 100));
	
}


-(void)open:(NSString *)theToken {
    
    signal(SIGINT, sighandler);
    int debug_level = 7;
    /* tell the library what debug level to emit and to send it to syslog */
	lws_set_log_level(debug_level, lwsl_emit_syslog);
    
    theQueue = [[NSLinkedList alloc] init];
    
    NSLog(@"Connection worked");
    const char *token = [theToken cStringUsingEncoding:NSASCIIStringEncoding];
    
    NSString *publishVideoUrl = [self.propertyAccessor getPropertyValue:@"WHAT_AM_I_DOING_PUBLISH_VIDEO"];
    const char *initPath =[publishVideoUrl cStringUsingEncoding:NSUTF8StringEncoding];
    int port = [[self.propertyAccessor getPropertyValue:@"WHAT_AM_I_DOING_PORT"] intValue];
    char * path ;
    if((path = malloc(strlen(initPath)+strlen(token)+1)) != NULL){
        path[0] = '\0';   // ensures the memory is an empty string
        strcat(path,initPath);
        strcat(path,token);
    }
    
    
    NSLog(@"path=%s",path);
    int ietf_version = -1;
    
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(queue, ^{
        /* Context creation */
        struct libwebsocket_protocols protocols[] = {
            /* first protocol must always be HTTP handler */
            {
                "http-only",
                 http_only,
            },
            {
                "dumb",
                callback_dumb_increment,
            },
            {
                NULL, NULL, 0   /* End of list */
            }
        };
        
        context = libwebsocket_create_context(port, NULL, protocols,libwebsocket_internal_extensions, NULL, NULL, NULL, -1, -1, 0, NULL);
        if (context == NULL) {
            NSLog(@"Unable to create context");
        } else {
           
            NSString *domainString = [self.propertyAccessor getPropertyValue:@"WHAT_AM_I_DOING_DOMAIN"];
            const char *domain =[domainString cStringUsingEncoding:NSUTF8StringEncoding];
            
            NSString *hostString = [self.propertyAccessor getPropertyValue:@"WHAT_AM_I_DOING_URL"];
            const char *host =[hostString cStringUsingEncoding:NSUTF8StringEncoding];

            
            NSLog(@"Able to create context");
            // create client websocket
            wsi = libwebsocket_client_connect(context,
                                              domain,
                                              port, // port
                                              0, // "ws:" (no SSL)
                                              path, // path
                                              host, // host name
                                              "controller", // Socket origin name
                                              NULL, // libwebsocket protocol name
                                              ietf_version
                                              );
            
            
            /*
             dispatch_async(dispatch_get_main_queue(), ^{
             completionBlock(error);
             });
             */
            
            
            if (wsi != NULL) {
                
                /* For now infinite loop which proceses events and wait for n ms. */
                //NSLog(@"--startging video");
                status = 1;
                while (status == 1) {
                    //  NSLog(@"polling");
                        libwebsocket_service(context, 0);
                        libwebsocket_callback_on_writable_all_protocol(&protocols[1]);
                        usleep(pollingInterval);
                    
                }
                
                NSLog(@"Websockets destroying contest");
                libwebsocket_close_and_free_session(context, wsi, LWS_CLOSE_STATUS_GOINGAWAY);
                libwebsocket_context_destroy(context);
                dispatch_async(dispatch_get_main_queue(), ^{
                    //[self.camera stop];
                    //self.recordingStatus = 0;
                    //self.stopVideoButton.enabled = NO;
                    //self.startVideoButton.enabled = YES;
                });
                
                
            }
        }
        
    });
    
}

-(void) send:(NSData *)data {
    
    @autoreleasepool {
        
        if (status == 1) {
            
            @synchronized(theQueue) {
                [theQueue pushFront:data] ;
            }
           // data = nil;
        }
    }
    
}


@end
