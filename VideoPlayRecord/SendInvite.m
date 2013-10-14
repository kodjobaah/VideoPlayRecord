//
//  SendInvite.m
//  VideoPlayRecord
//
//  Created by Valtech UK on 14/10/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import "SendInvite.h"

@implementation SendInvite

-(SendInvite*) initWithEmail:(UITextField*) email {
    self = [super init];
    if(self) {
        _emal = email;
    }
    return self;
}

-(void) sendInvitation:(NSString *) token {
    NSString *hostMessage = [NSString stringWithFormat:@"http://5.79.24.141:9000/invite?email=%@&token=%@",self.emal.text,token];
    
    NSURL *url=[NSURL URLWithString:hostMessage];
    NSString *post =[[NSString alloc] initWithFormat:@"email=%@&token=%@",self.emal.text,token];
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
    
    NSString *sentEmailString = @"Email Sent to ";
    NSString *message = [sentEmailString stringByAppendingString:self.emal.text];
    
    UIAlertView* mes=[[UIAlertView alloc]
                      initWithTitle: message
                      message: @""
                      delegate:self
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles: nil];
    [mes show];
    self.emal.text = @"";
    
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}
@end
