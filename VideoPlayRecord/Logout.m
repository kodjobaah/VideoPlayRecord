//
//  Logout.m
//  VideoPlayRecord
//
//  Created by Valtech UK on 14/10/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import "Logout.h"
#import "WhatAmIDoingViewController.h"

@implementation Logout
@synthesize propertyAccessor = _propertyAccessor;

-(Logout*) initWithController:(UIViewController*) rvvc {
    self = [super init];
    
    if(self) {
        _recordVideoViewController = rvvc;
        _constants = [[WhatAmIDoingConstants alloc] init];
        _propertyAccessor = [[PropertyAccessor alloc] init];
    }
    return self;
}

-(void) logout:(NSString *) token {
    NSLog(@"Logging out");
    NSString *port = [self.propertyAccessor getPropertyValue:@"WHAT_AM_I_DOING_PORT"];
    NSString *host = [self.propertyAccessor getPropertyValue:@"WHAT_AM_I_DOING_URL"];
    NSString *logout = [self.propertyAccessor getPropertyValue:@"WHAT_AM_I_DOING_LOGOUT"];
    
    NSString *hostMessage = [NSString stringWithFormat:@"http://%@:%@/%@%@",host,port,logout,token];
    
    NSURL *url=[NSURL URLWithString:hostMessage];
    NSString *post =[[NSString alloc] initWithFormat:@"%@%@",logout,token];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}
#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    
    
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [self.responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
    NSLog(@"Having problems here :%@:",[self.constants registerOrLoginId]);
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    WhatAmIDoingViewController *viewController = (WhatAmIDoingViewController *)[storyboard instantiateViewControllerWithIdentifier:[self.constants registerOrLoginId]];

    NSLog(@"Having problems here 2");
    
    [self.recordVideoViewController presentViewController:viewController animated:YES completion:nil];

    NSLog(@"Having problems here 3");
    
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

@end
