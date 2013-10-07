//
//  WhatAmIDoingViewController.m
//  VideoPlayRecord
//
//  Created by Valtech UK on 26/08/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import "WhatAmIDoingViewController.h"
#import "AuthenticationToken.h"
#import "PropertyAccessor.h"

@interface WhatAmIDoingViewController ()

@end

@implementation WhatAmIDoingViewController

@synthesize whatAmIdoingUrl = _whatAmIdoingUrl;
@synthesize propertyAccessor = _propertyAccessor;

@synthesize managedObjectContext = __managedObjectContext;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.propertyAccessor = [[PropertyAccessor alloc] init];
    
    self.whatAmIdoingUrl = [self.propertyAccessor getPropertyValue:@"WHAT_AM_I_DOING_URL"];

    
    if (self.whatAmIdoingUrl == nil) {
        self.whatAmIdoingUrl = @"http://5.79.24.141:9000/";
    }
    
    self.registerUrl = [self.propertyAccessor getPropertyValue:@"WHAT_AM_I_DOING_REGISTER_URL"];
    
    if (self.registerUrl == nil) {
        self.registerUrl = @"http://5.79.24.141:9000/registerLogin?";
    }
    

}
- (IBAction)registerOrLoginAction:(id)sender {
    
    NSString *params = [NSString stringWithFormat:@"email=%@&password=%@&firstName=%@&lastName=%@", self.email.text,self.password.text, self.firstName.text,self.lastName.text];
   
    NSString *hostMessage = [self.registerUrl stringByAppendingString:params];
    NSURL *url=[NSURL URLWithString:hostMessage];
    NSData *postData = [params dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    //Disabling the join  button
    self.registerOrJoin.enabled = NO;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.registerOrJoin.enabled = YES;
    // Dispose of any resources that can be recreated.
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    NSDictionary *fields = [HTTPResponse allHeaderFields];
    NSString *cookie = [fields objectForKey:@"Set-Cookie"];
    
    NSRange range = [cookie rangeOfString:@"PLAY_SESSION="];
    int location = range.location;
    int length = range.length;
    NSString *substring = [cookie substringFromIndex:location+1+length];
    
    NSRange rangeEndOfPlaySession = [substring rangeOfString:@"\""];
    int endOfPlaySessionLocation =  rangeEndOfPlaySession.location;
    
    NSString *newDes = [substring substringWithRange: NSMakeRange (0, endOfPlaySessionLocation)];
    
 
    _playSession = newDes;
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
    
    self.registerOrJoin.enabled = YES;
    
    // Grab the context
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // Deleting old authentication token
    
    [self deleteAllObjects:@"AuthenticationToken"];
    AuthenticationToken *authenticationToken = [NSEntityDescription insertNewObjectForEntityForName:@"AuthenticationToken" inManagedObjectContext:context];
    
    authenticationToken.playSession = _playSession;
    
    // Save everything
    NSError *error = nil;
    if ([context save:&error]) {
        NSLog(@"The save was successful!");
    } else {
        NSLog(@"The save wasn't successful: %@", [error userInfo]);
    }

    
    [self performSegueWithIdentifier:@"thisIsWhatIAmDoing" sender:self];
       
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    
    self.registerOrJoin.enabled = YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.email resignFirstResponder];
    [self.password resignFirstResponder];
    [self.firstName resignFirstResponder];
    [self.lastName resignFirstResponder];
}

- (void) deleteAllObjects: (NSString *) entityDescription  {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    
    for (NSManagedObject *managedObject in items) {
    	[self.managedObjectContext deleteObject:managedObject];
    	NSLog(@"%@ object deleted",entityDescription);
    }
    if (![self.managedObjectContext save:&error]) {
    	NSLog(@"Error deleting %@ - error:%@",entityDescription,error);
    }
    
}

@end
