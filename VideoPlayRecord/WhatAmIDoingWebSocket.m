//
//  WhatAmIDoingWebSocket.m
//  VideoPlayRecord
//
//  Created by Valtech UK on 17/10/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import "WhatAmIDoingWebSocket.h"

@implementation WhatAmIDoingWebSocket

@synthesize camera = _camera;
@synthesize recordingStatus = _recordingStatus;
@synthesize startVideoButton = _startVideoButton;
@synthesize stopVideoButton = _stopVideoButton;


static struct libwebsocket* wsi;
static struct libwebsocket_context *context;
static  NSLinkedList *theQueue;
int force_exit = 0;
int count = 0;

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
    
    status = 0;
    
    
}
static int callback_http(struct libwebsocket_context *context,
                         struct libwebsocket *wsi,
                         enum libwebsocket_callback_reasons reason, void *user,
                         void *in, size_t len)
{
    //NSLog(@"---callback_http");
    
    switch (reason) {
            
        case LWS_CALLBACK_CLOSED:
            //NSLog(@"--- libwebsocket close");
            //libwebsocket_context_destroy(context);
            status =0;
            break;
            
        case LWS_CALLBACK_CLIENT_ESTABLISHED:
            
            status = 1;
            count = 0;
            //NSLog(@"--- libwebsocket client established");
            /*
             * start the ball rolling,
             * LWS_CALLBACK_CLIENT_WRITEABLE will come next service
             */
            
            libwebsocket_callback_on_writable(context, wsi);
            break;
            
        case LWS_CALLBACK_CLIENT_RECEIVE:
            //NSLog(@"--libwebsocket client receive--");
            break;
            
        case LWS_CALLBACK_CLIENT_WRITEABLE:
            
            
            
            if (status == 1) {
                @autoreleasepool {
                    NSString *dataToWrite = [theQueue popBack];
                    NSLog(@"data pullued:%lu",(unsigned long)dataToWrite.length);
                    unsigned char *response_buf;
                    count = count + 10;
                    if ((count > 10) && (dataToWrite.length > 1)) {
                        //   NSLog(@"wrting to buffer");
                        
                        int len = [dataToWrite lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
                        response_buf = (unsigned char*) malloc(LWS_SEND_BUFFER_PRE_PADDING + len +LWS_SEND_BUFFER_POST_PADDING);
                        bcopy([dataToWrite cStringUsingEncoding:NSUTF8StringEncoding], &response_buf[LWS_SEND_BUFFER_PRE_PADDING], len);
                        libwebsocket_write(wsi, &response_buf[LWS_SEND_BUFFER_PRE_PADDING], len, LWS_WRITE_TEXT);
                        free(response_buf);
                        response_buf = NULL;
                        CFStringRef del = (__bridge_retained CFStringRef) dataToWrite;
                        CFRelease(del);
                        dataToWrite = nil;
                        //free(dataToWrite);
                    }
                    else {
                        NSLog(@"Attempt to write empty data on the websocket");
                    }
                
                }
                /* get notified as soon as we can write again */
                libwebsocket_callback_on_writable(context, wsi);
            }
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
    const char *initPath = "/publishVideo?token=";
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
        
        context = libwebsocket_create_context(9000, NULL, protocols,libwebsocket_internal_extensions, NULL, NULL, NULL, -1, -1, 0, NULL);
        if (context == NULL) {
            NSLog(@"Unable to create context");
        } else {
            
            NSLog(@"Able to create context");
            // create client websocket
            wsi = libwebsocket_client_connect(context,
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
            
            if (wsi != NULL) {
                
                /* For now infinite loop which proceses events and wait for n ms. */
                //NSLog(@"--startging video");
                self.stopVideoButton.enabled = YES;
                self.startVideoButton.enabled = NO;
                self.recordingStatus = 1;
                status = 1;
                while (status == 1) {
                    @autoreleasepool {
                        libwebsocket_service(context, 0);
                        libwebsocket_callback_on_writable_all_protocol(&protocols[1]);
                        
                        usleep(pollingInterval);
                    }
                    
                }
                
                //libwebsocket_close_and_free_session(context, wsi, LWS_CLOSE_STATUS_GOINGAWAY);
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

-(void) send:(NSString *)data {
    
    
    //char *characters = (char *)malloc(data.length);
    
    // [data getCString:characters maxLength:data.length encoding:NSUTF8StringEncoding];
    
    // NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    //unsigned char* d = (unsigned char*) [NSData data];
    //char *d = (char *)[data cStringUsingEncoding:NSASCIIStringEncoding];
    //NSLog(@"data being pushed on queued:%lu",(unsigned long)data.length);
    @autoreleasepool {
        
    if (status == 1) {
        
        //  size_t len = strlen(data);
        //NSLog(@"1:%zu",(unsigned long)data.length);
         NSLog(@"Retain count is -send- 2:%ld", CFGetRetainCount((__bridge CFTypeRef)data));
        [theQueue pushFront:data] ;
         NSLog(@"Retain count is -send- 6:%ld", CFGetRetainCount((__bridge CFTypeRef)data));
        data = nil;
    }
    }
    
}

int
callback_what_am_i_doing(struct libwebsocket_context *context,
                         struct libwebsocket *wsi,
                         enum libwebsocket_callback_reasons reason,
                         void *user, void *in, size_t len)
{
    
    
    switch (reason) {
            
        case LWS_CALLBACK_CLOSED:
            //NSLog(@"****************** libwebsocket close");
            break;
            
        case LWS_CALLBACK_CLIENT_ESTABLISHED:
            
            //NSLog(@"******************* libwebsocket client established");
            /*
             * start the ball rolling,
             * LWS_CALLBACK_CLIENT_WRITEABLE will come next service
             */
            
            libwebsocket_callback_on_writable(context, wsi);
            break;
            
        case LWS_CALLBACK_CLIENT_RECEIVE:
            //NSLog(@"******************* libwebsocket client receive--");
            break;
            
        case LWS_CALLBACK_CLIENT_WRITEABLE:
            
            if (status == 1) {
                
                NSString *dataToWrite = [theQueue popBack];
                NSLog(@"data pullued:%lu",(unsigned long)dataToWrite.length);
                unsigned char *response_buf;
                count = count + 10;
                if ((count > 10) && (dataToWrite.length > 1)) {
                    //   NSLog(@"wrting to buffer");
                    
                    response_buf = (unsigned char*) malloc(LWS_SEND_BUFFER_PRE_PADDING + dataToWrite.length +LWS_SEND_BUFFER_POST_PADDING);
                    
                    bcopy(CFBridgingRetain(dataToWrite), &response_buf[LWS_SEND_BUFFER_PRE_PADDING], dataToWrite.length);
                    libwebsocket_write(wsi, &response_buf[LWS_SEND_BUFFER_PRE_PADDING], dataToWrite.length, LWS_WRITE_TEXT);
                    free(response_buf);
                    //free(dataToWrite);
                }
                else {
                    NSLog(@"Attempt to write empty data on the websocket");
                }
                }
                /* get notified as soon as we can write again */
                libwebsocket_callback_on_writable(context, wsi);
            break;
        default:
            break;
    }
    
    return 0;
}

- (CFStringRef *)base64EncodedString: data
{
    // Construct an OpenSSL context
    BIO *context = BIO_new(BIO_s_mem());
    
    // Tell the context to encode base64
    BIO *command = BIO_new(BIO_f_base64());
    context = BIO_push(command, context);
    
    // Encode all the data
    BIO_write(context, [data bytes], [data length]);
    BIO_flush(context);
    
    // Get the data out of the context
    char *outputBuffer;
    long outputLength = BIO_get_mem_data(context, &outputBuffer);
    
     char *bytes = malloc(strlen(outputBuffer)+1);
    strcpy(bytes, outputBuffer);
    CFStringRef str = CFStringCreateWithCStringNoCopy(NULL, bytes, kCFStringEncodingUTF8, kCFAllocatorMalloc);
    /*
     NSString *encodedString = [NSString
     stringWithCString:outputBuffer
     length:outputLength];
     
     */
    //free(outputBuffer);
    BIO_free_all(context);
   // NSString *val = CFBridgingRelease(str);
   // str = nil;
    NSLog(@"Retain count is -encodebase5-:%ld", CFGetRetainCount(str));

    return str;
}

@end
