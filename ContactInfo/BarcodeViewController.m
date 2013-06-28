//
//  BarcodeViewController.m
//  ContactInfo
//
//  Created by goodcore1 on 5/21/13.
//  Copyright (c) 2013 goodcore1. All rights reserved.
//

#import "BarcodeViewController.h"

@interface BarcodeViewController ()

@end

@implementation BarcodeViewController

@synthesize responseData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //[[self navigationController] setNavigationBarHidden:NO];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openBarcodeReader:(id)sender {
    NSString *device = [[UIDevice currentDevice] model];
    
    if ([device rangeOfString:@"iPhone"].location != NSNotFound ) {
        [self showCameraControl];
    }
    else{
        [self showModalPopup:@"Device Not Supported!" andUserMessage:@"This device is not suported for the app."];
    }
}

-(void) showCameraControl{
    
        ZBarReaderViewController *reader = [ZBarReaderViewController new];
        reader.readerDelegate = self;
        // [reader.scanner setSymbology: ZBAR_QRCODE config: ZBAR_CFG_ENABLE to: 1];
        
        ZBarImageScanner *scanner = reader.scanner;
        [scanner setSymbology: ZBAR_I25
                       config: ZBAR_CFG_ENABLE
                           to: 0];
        
        reader.readerView.zoom = 1.0;
        reader.tracksSymbols = YES;
    
        [self presentViewController:reader animated:YES completion:nil];
    
        reader.cameraOverlayView = [self CommomOverlay];

}

-(UIView*)CommomOverlay{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,450)];
    UIImageView *frameImg = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,450)];
    [frameImg setImage:[UIImage imageNamed:@"QR-scanner-start-bg_2x.png"]];
    frameImg.alpha = 0.5;
    [view addSubview:frameImg];
    return view;
}

- (IBAction)logout:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}



-(void)imagePickerController: (UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"imagePickerController");
    
    [self dismissViewControllerAnimated:YES completion:nil];
        
    id <NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    NSString *hiddenData;
    for(symbol in results)
        hiddenData=[NSString stringWithString:symbol.data];
    NSLog(@"SYMBOL : %@", hiddenData);
    
    NSURL* userURL = [NSURL URLWithString:hiddenData];
    
    if(userURL && userURL.scheme && userURL.host){
        // loader
        [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
        NSMutableURLRequest *request = [NSMutableURLRequest
                                        requestWithURL:userURL];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [connection start];
    }else{
       [self showModalPopup:@"Invalid QRcode Scanned!" andUserMessage:@"The scanned QRcode is not recognized."]; 
    }
}


-(void)imagePickerControllerDidCancel: (UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
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

- (void)showModalPopup:(NSString *)title andUserMessage:(NSString *)message{
    RNBlurModalView *modal = [[RNBlurModalView alloc] initWithViewController:self title:title message:message];
    [modal show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [SVProgressHUD dismiss];
    //NSLog(@"response data - %@", [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding]);
    NSError* error;
    NSDictionary* response = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&error];
    if(error){
        [self showModalPopup:@"Invalid QRcode Scanned!" andUserMessage: @"The scanned QRcode contains invalid information."];
    }
    else if([response objectForKey:@"profile"]){
        [self openContactViewController:response];
    }
    else{
        [self showModalPopup:@"Invalid json data!" andUserMessage:@"The scanned QRcode contains invalid json data."];
    }
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)unknownPersonViewController:(ABUnknownPersonViewController *)unknownCardViewController didResolveToPerson:(ABRecordRef)person{
    if (person){
		[self.navigationController popViewControllerAnimated:NO];
    }
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    [self dismissViewControllerAnimated:YES completion:nil];
    return NO;
}



- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier{
    return NO;
}

- (void)openContactViewController:(NSDictionary *)jsonResponse{
    CFErrorRef error = NULL;
    
    NSDictionary* profile = [jsonResponse objectForKey:@"profile"];
    
    ABRecordRef person = ABPersonCreate();
    
    // adding firstname, lastname and company which are single sting values
    ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFTypeRef)([profile objectForKey:@"firstName"]), &error);
    ABRecordSetValue(person, kABPersonLastNameProperty, (__bridge CFTypeRef)([profile objectForKey:@"lastName"]), &error);
    ABRecordSetValue(person, kABPersonOrganizationProperty, (__bridge CFTypeRef)([profile objectForKey:@"company"]), &error);
    
    // adding email which is a multi string value
    ABMutableMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(email, (__bridge CFTypeRef)([profile objectForKey:@"email"]), kABWorkLabel, NULL);
    ABRecordSetValue(person, kABPersonEmailProperty, email , &error);
    CFRelease(email);
    
    // adding phone/mobile number
    ABMutableMultiValueRef phone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(phone, (__bridge CFTypeRef)([profile objectForKey:@"mobile"]), kABPersonPhoneMobileLabel, NULL);
    ABMultiValueAddValueAndLabel(phone, (__bridge CFTypeRef)([profile objectForKey:@"phone"]), kABHomeLabel, NULL);
    ABRecordSetValue(person, kABPersonPhoneProperty, phone , &error);
    CFRelease(phone);
    
    
    //add work adress
    ABMutableMultiValueRef multiAddress1 = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    NSMutableDictionary *addressDictionary1 = [[NSMutableDictionary alloc] init];
    if(![[profile objectForKey:@"addressLine1"] isEqualToString:@""])
        [addressDictionary1 setObject:[profile objectForKey:@"addressLine1"] forKey:(NSString *) kABPersonAddressStreetKey];
    if(![[profile objectForKey:@"city"] isEqualToString:@""])
        [addressDictionary1 setObject:[profile objectForKey:@"city"] forKey:(NSString *)kABPersonAddressCityKey];
    if(![[profile objectForKey:@"postalCode"] isEqualToString:@""])
        [addressDictionary1 setObject:[profile objectForKey:@"postalCode"] forKey:(NSString *)kABPersonAddressZIPKey];
    if(![[profile objectForKey:@"country"] isEqualToString:@""])
        [addressDictionary1 setObject:[profile objectForKey:@"country"] forKey:(NSString *)kABPersonAddressCountryKey];
    
    ABMultiValueAddValueAndLabel(multiAddress1, (__bridge CFTypeRef)(addressDictionary1), kABWorkLabel, NULL);
    
    
    //add home address
    if([profile objectForKey:@"addressLine2"] && ![[profile objectForKey:@"addressLine2"] isEqualToString:@""]){
        NSMutableDictionary *addressDictionary2 = [[NSMutableDictionary alloc] init];
        [addressDictionary1 setObject:[profile objectForKey:@"addressLine1"] forKey:(NSString *) kABPersonAddressStreetKey];
        if(![[profile objectForKey:@"city"] isEqualToString:@""])
            [addressDictionary2 setObject:[profile objectForKey:@"city"] forKey:(NSString *)kABPersonAddressCityKey];
        if(![[profile objectForKey:@"postalCode"] isEqualToString:@""])
            [addressDictionary2 setObject:[profile objectForKey:@"postalCode"] forKey:(NSString *)kABPersonAddressZIPKey];
        if(![[profile objectForKey:@"country"] isEqualToString:@""])
            [addressDictionary2 setObject:[profile objectForKey:@"country"] forKey:(NSString *)kABPersonAddressCountryKey];
        
        ABMultiValueAddValueAndLabel(multiAddress1, (__bridge CFTypeRef)(addressDictionary2), kABWorkLabel, NULL);
    }
    ABRecordSetValue(person, kABPersonAddressProperty, multiAddress1, &error);
    
    CFRelease(multiAddress1); 
    
    if(error){
        CFStringRef errorDesc = CFErrorCopyDescription(error);
        NSLog(@"Contact not saved: %@", errorDesc);
        CFRelease(errorDesc);
    }
        
    ABUnknownPersonViewController *view = [[ABUnknownPersonViewController alloc] init];
    view.unknownPersonViewDelegate = self;
    view.displayedPerson = person;
    view.allowsAddingToAddressBook = YES;
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:view animated:YES];
}


@end
