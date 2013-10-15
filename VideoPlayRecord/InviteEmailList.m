//
//  InviteEmailList.m
//  VideoPlayRecord
//
//  Created by Valtech UK on 14/10/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import "InviteEmailList.h"
#import "ActionSheetPicker.h"

@implementation InviteEmailList

@synthesize email = _email;
@synthesize responseData = _responseData;
@synthesize sender = _sender;

-(InviteEmailList *) initWithData:(UITextField *)theEmail {
    self = [super init];
    if(self) {
        _email = theEmail;
    }
    return self;
}

-(void) displayInvites:(id)theSender theToken:(NSString *) token{
    NSLog(@"making calling:%@",token);
    self.sender = theSender;
    NSString *hostMessage = [NSString stringWithFormat:@"http://5.79.24.141:9000/findAllInvites?token=%@",token];
    
    NSURL *url=[NSURL URLWithString:hostMessage];
    NSString *post =[[NSString alloc] initWithFormat:@"token=%@",token];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
NSLog(@"finnish making calling");
    
}
#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    NSLog(@"recoeved data");
    
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [self.responseData appendData:data];
    NSLog(@"storing");
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
    NSLog(@"---findishi");
    NSString *data = [[NSString alloc] initWithData:self.responseData encoding:NSASCIIStringEncoding];
    NSArray *myArray = [data componentsSeparatedByString:@","];
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        self.email.text = selectedValue;
        
    };
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
        NSLog(@"Block Picker Canceled");
    };
    [ActionSheetStringPicker showPickerWithTitle:@"Select a Block" rows:myArray initialSelection:0 doneBlock:done cancelBlock:cancel origin:self.sender];
    
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

@end
