//
//  WhatAmIDoingViewController.m
//  VideoPlayRecord
//
//  Created by Valtech UK on 26/08/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import "WhatAmIDoingViewController.h"
#import "AuthenticationToken.h"
@interface WhatAmIDoingViewController ()

@end

@implementation WhatAmIDoingViewController

@synthesize managedObjectContext = __managedObjectContext;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)registerOrLoginAction:(id)sender {
    
    NSString *params = [NSString stringWithFormat:@"email=%@&password=%@&firstName=%@&lastName=%@", self.email.text,self.password.text, self.firstName.text,self.lastName.text];
   
    NSString *hostUrlString = @"http://5.79.24.141:9000/registerLogin?";
    NSString *hostMessage = [hostUrlString stringByAppendingString:params];
    NSLog(@":( URL %@", hostMessage);
    NSURL *url=[NSURL URLWithString:hostMessage];
    NSData *postData = [params dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    //[request setHTTPShouldHandleCookies:YES];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    //Disabling the join  button
    self.registerOrJoin.enabled = NO;
    
    NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"5.79.24.141"]];
    
    UIAlertView* mes=[[UIAlertView alloc]
                      initWithTitle: @"received a response"
                      message: [NSString stringWithFormat:@"my dictionary is %@", cookies]
                      delegate:self
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles: nil];
    [mes show];

    
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
    
    UIAlertView* mes=[[UIAlertView alloc]
                      initWithTitle: @"received a response"
                      message: [NSString stringWithFormat:@"i want to see %@", cookie]
                      delegate:self
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles: nil];
    [mes show];
    
    _playSession = cookie;
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
    
    UIAlertView* mes=[[UIAlertView alloc]
                      initWithTitle: [[NSString alloc] initWithData:_responseData encoding:NSASCIIStringEncoding]
                      message:[[NSString alloc] initWithData:_responseData encoding:NSASCIIStringEncoding]
                      delegate:self
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles: nil];
    [mes show];
    
    self.registerOrJoin.enabled = YES;
    
    // Grab the context
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // Grab the Label entity
    
    AuthenticationToken *athenticationToken = [NSEntityDescription insertNewObjectForEntityForName:@"AuthenticationToken" inManagedObjectContext:context];
    
    // Save everything
    NSError *error = nil;
    if ([context save:&error]) {
        NSLog(@"The save was successful!");
    } else {
        NSLog(@"The save wasn't successful: %@", [error userInfo]);
    }

    
    NSString *entityName = @"AuthenticationToken"; // Put your entity name here
    NSLog(@"Setting up a Fetched Results Controller for the Entity named %@", entityName);
    
    // 2 - Request that Entity
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AuthenticationToken"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [self.managedObjectContext
                               executeFetchRequest:fetchRequest error:&error];
    NSLog(@"fetech objects %@", fetchedObjects);
    
    
  // [self performSegueWithIdentifier:@"thisIsWhatIAmDoing" sender:self];
       
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    
    UIAlertView* mes=[[UIAlertView alloc]
                      initWithTitle: [error localizedDescription]
                      message: [error localizedDescription]
                      delegate:self
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles: nil];
    [mes show];
    self.registerOrJoin.enabled = YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.email resignFirstResponder];
    [self.password resignFirstResponder];
    [self.firstName resignFirstResponder];
    [self.lastName resignFirstResponder];
}

@end
