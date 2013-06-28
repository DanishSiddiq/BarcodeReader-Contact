//
//  ViewController.m
//  ContactInfo
//
//  Created by goodcore1 on 5/21/13.
//  Copyright (c) 2013 goodcore1. All rights reserved.
//

#import "ViewController.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1
#define kUserAuthenticationURL [NSURL URLWithString:@"http://businesscard-manager.herokuapp.com/authenticate"]


@interface ViewController ()

@end

@implementation ViewController

@synthesize emailText;
@synthesize pwdText;
@synthesize loginButton;
@synthesize responseData;

@synthesize splashImageUp;
@synthesize splashImageMiddle;
@synthesize splashImageBottom;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    pwdText.delegate = emailText.delegate = self;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
    if([(AppDelegate *)[[UIApplication sharedApplication] delegate] isLoadedFirstTime]){
        
        [[self navigationController] setNavigationBarHidden:YES];
        
        CGRect splashTop = self.splashImageUp.frame;
        splashTop.origin.y = -splashTop.size.height - 40;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.8];
        [UIView setAnimationDelay:1.2];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        self.splashImageUp.frame = splashTop;
        
        [UIView commitAnimations];
        
        CGRect splashMiddle = self.splashImageMiddle.frame;
        splashMiddle.origin.y = -splashMiddle.size.height - 40;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.8];
        [UIView setAnimationDelay:2.2];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        self.splashImageMiddle.frame = splashMiddle;
        
        [UIView commitAnimations];
        
        CGRect splashBottom = self.splashImageBottom.frame;
        splashBottom.origin.y = splashBottom.size.height + 110;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.8];
        [UIView setAnimationDelay:3.2];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        self.splashImageBottom.frame = splashBottom;
        
        [UIView commitAnimations];
        
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] setIsLoadedFirstTime:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)login:(id)sender {
    
    // login validation
    if(![emailText.text isEqualToString: @""] && ![pwdText.text isEqualToString: @""]){
        
        // loader
        [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
        
        NSMutableURLRequest *request = [NSMutableURLRequest
                                        requestWithURL:kUserAuthenticationURL];
        
        NSDictionary *requestData = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     emailText.text, @"username",
                                     pwdText.text, @"password",
                                     nil];
        NSError *error;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:requestData options:0 error:&error];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:postData];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [connection start];
        
    }else{
        [self showModalPopup:@"Login Failed!" andUserMessage:@"Please give a valid id and password."];
    }
}

- (void)showModalPopup:(NSString *)title andUserMessage:(NSString *)message{
    RNBlurModalView *modal = [[RNBlurModalView alloc] initWithViewController:self title:title message:message];
    [modal show];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.responseData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (!self.responseData)
    {
        responseData = [NSMutableData data];
    }
    
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [SVProgressHUD dismiss];
    NSLog(@"response data - %@", [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding]);
    NSError* error;
    NSDictionary* respose = [NSJSONSerialization JSONObjectWithData:self.responseData options:0 error:&error];
    if(error){
        [self showModalPopup:@"Login Failed!" andUserMessage: [error localizedDescription]];
    }
    else if([respose objectForKey:@"login"]){
        if([[respose objectForKey:@"login"] isEqual:[NSNumber numberWithBool:YES]]){
            BarcodeViewController* barcodeController = [[BarcodeViewController alloc] init];
            [self.navigationController pushViewController:barcodeController animated:YES];
        }else{
            [self showModalPopup:@"Login Failed!" andUserMessage:@"Your id or password is incorrect."];
        }
    }
    else{
        [self showModalPopup:@"Login Failed!" andUserMessage:@"Server not responding."];
    }
}

@end
