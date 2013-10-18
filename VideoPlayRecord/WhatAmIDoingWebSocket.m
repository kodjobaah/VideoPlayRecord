//
//  WhatAmIDoingWebSocket.m
//  VideoPlayRecord
//
//  Created by Valtech UK on 17/10/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import "WhatAmIDoingWebSocket.h"

@implementation WhatAmIDoingWebSocket

@synthesize wsi=_wsi;
@synthesize context = _context;
@synthesize camera = _camera;
@synthesize recordingStatus = _recordingStatus;
@synthesize startVideoButton = _startVideoButton;
@synthesize stopVideoButton = _stopVideoButton;


static  LinkedList *theQueue;
int force_exit = 0;

static int pollingInterval = 20000;

static int status = 0;

-(WhatAmIDoingWebSocket *) initWithCamera:(CvVideoCamera *)theCamera {
    self = [super init];
    
    if(self) {
        _camera = theCamera;
    }
    return self;
}

-(int) connectionStatus {
    
    if (status == 1)
        return YES;
    
    return NO;
    
}
-(void) close {
    libwebsocket_context_destroy(self.context);
}
 static int callback_http(struct libwebsocket_context *context,
                         struct libwebsocket *wsi,
                         enum libwebsocket_callback_reasons reason, void *user,
                         void *in, size_t len)
{
    NSLog(@"---callback_http");
    char *dataToWrite;
    switch (reason) {
            
        case LWS_CALLBACK_CLOSED:
            NSLog(@"--- libwebsocket close");
            status =0;
            break;
            
        case LWS_CALLBACK_CLIENT_ESTABLISHED:
           
            status = 1;
            NSLog(@"--- libwebsocket client established");
            /*
             * start the ball rolling,
             * LWS_CALLBACK_CLIENT_WRITEABLE will come next service
             */
            
            libwebsocket_callback_on_writable(context, wsi);
            break;
            
        case LWS_CALLBACK_CLIENT_RECEIVE:
            NSLog(@"--libwebsocket client receive--");
            break;
            
        case LWS_CALLBACK_CLIENT_WRITEABLE:
           
            
            
            dataToWrite = (char *)[theQueue popBack];
            unsigned char *response_buf;
            
            if (strlen(dataToWrite) > 0) {
                response_buf = (unsigned char*) malloc(LWS_SEND_BUFFER_PRE_PADDING + strlen(dataToWrite) +LWS_SEND_BUFFER_POST_PADDING);
                
                bcopy(dataToWrite, &response_buf[LWS_SEND_BUFFER_PRE_PADDING], strlen(dataToWrite));
                libwebsocket_write(wsi, &response_buf[LWS_SEND_BUFFER_PRE_PADDING], strlen(dataToWrite), LWS_WRITE_TEXT);
                free(response_buf);
            }
            else {
                NSLog(@"Attempt to write empty data on the websocket");
            }
            
            /* get notified as soon as we can write again */
            libwebsocket_callback_on_writable(context, wsi);
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



-(void)open:(NSString *)theToken {
    
     NSLog(@"just inside ");
    signal(SIGINT, sighandler);
    int debug_level = 7;
    /* tell the library what debug level to emit and to send it to syslog */
	lws_set_log_level(debug_level, lwsl_emit_syslog);
    
    theQueue = [[LinkedList alloc] initWithCapacity:10000 incrementSize:10000];
    
    NSLog(@"Connection worked");
    const char *token = [theToken cStringUsingEncoding:NSASCIIStringEncoding];
    const char *initPath = "/publishVideo?token=";
    char * path ;
    if((path = malloc(strlen(initPath)+strlen(token)+1)) != NULL){
        path[0] = '\0';   // ensures the memory is an empty string
        strcat(path,initPath);
        strcat(path,token);
    }
    
    
    NSLog(@"path=%s",path);
    
    int ietf_version = -1;
    
   /*
     wsi = libwebsocket_client_connect(context, address, 9000, 0,
     "/", address, address, NULL, ietf_version);
     */
	if (self.wsi == NULL) {
		fprintf(stderr, "libwebsocket dumb connect failed\n");
        
	}
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(queue, ^{
        /* Context creation */
        struct libwebsocket_protocols protocols[] = {
            /* first protocol must always be HTTP handler */
            {
                "http-only",
                callback_http,
                0
            },
            {
                "what-am-doing",
                callback_what_am_i_doing,   // callback
                sizeof(int)            // the session is identified by an id
                
            },
            {
                NULL, NULL, 0   /* End of list */
            }
        };
        
        self.context = libwebsocket_create_context(9000, NULL, protocols,libwebsocket_internal_extensions, NULL, NULL, NULL, -1, -1, 0, NULL);
        NSError *error = nil;
        if (self.context == NULL) {
            //      error = [NSError errorWithDomain:errorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Couldn't create the libwebsockets context.", @"")}];
        }
        
        // create client websocket
        self.wsi = libwebsocket_client_connect(self.context,
                                               "5.79.24.141",
                                               9000, // port
                                               0, // "ws:" (no SSL)
                                               path, // path
                                               "5.79.24.141", // host name
                                               "controller", // Socket origin name
                                               NULL, // libwebsocket protocol name
                                               ietf_version
                                               );
   
        
        /*
         dispatch_async(dispatch_get_main_queue(), ^{
         completionBlock(error);
         });
         */
        
        if (!error) {
            //    self.isRunning = YES;
            
            /* For now infinite loop which proceses events and wait for n ms. */
            
            [self.camera start];
            self.stopVideoButton.enabled = YES;
            self.startVideoButton.enabled = NO;
            self.recordingStatus = 1;
            
            while (true) {
                @autoreleasepool {
                    libwebsocket_service(self.context, 0);
                    libwebsocket_callback_on_writable_all_protocol(&protocols[1]);
                    
                    usleep(pollingInterval);
                }
                
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.camera stop];
                     self.recordingStatus = 1;
                     self.stopVideoButton.enabled = NO;
                     self.startVideoButton.enabled = YES;
                 });
                
            }
        }
        
    });
    
}

-(void) send:(NSString *)data {
    
    const char *d = [data cStringUsingEncoding:NSASCIIStringEncoding];
   [theQueue pushFront:d];
    
}

 int
callback_what_am_i_doing(struct libwebsocket_context *context,
                         struct libwebsocket *wsi,
                         enum libwebsocket_callback_reasons reason,
                         void *user, void *in, size_t len)
{
    
    int l = 0;
    int n;
    char *dataToWrite;
    
    switch (reason) {
            
        case LWS_CALLBACK_CLOSED:
            NSLog(@"****************** libwebsocket close");
            break;
            
        case LWS_CALLBACK_CLIENT_ESTABLISHED:
            
            NSLog(@"******************* libwebsocket client established");
            /*
             * start the ball rolling,
             * LWS_CALLBACK_CLIENT_WRITEABLE will come next service
             */
            
            libwebsocket_callback_on_writable(context, wsi);
            break;
            
        case LWS_CALLBACK_CLIENT_RECEIVE:
            NSLog(@"******************* libwebsocket client receive--");
            break;
            
        case LWS_CALLBACK_CLIENT_WRITEABLE:
           
            dataToWrite = (char *)[theQueue popBack];
            unsigned char *response_buf;
         
            if (strlen(dataToWrite) > 0) {
                response_buf = (unsigned char*) malloc(LWS_SEND_BUFFER_PRE_PADDING + strlen(dataToWrite) +LWS_SEND_BUFFER_POST_PADDING);
                
                bcopy(dataToWrite, &response_buf[LWS_SEND_BUFFER_PRE_PADDING], strlen(dataToWrite));
                libwebsocket_write(wsi, &response_buf[LWS_SEND_BUFFER_PRE_PADDING], strlen(dataToWrite), LWS_WRITE_TEXT);
                free(response_buf);
            }
            else {
                NSLog(@"Attempt to write empty data on the websocket");
            }

            /* get notified as soon as we can write again */
            libwebsocket_callback_on_writable(context, wsi);
            break;
            
        default:
            break;
    }
    
    return 0;
}


@end
