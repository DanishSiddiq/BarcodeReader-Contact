//
//  BarcodeViewController.h
//  ContactInfo
//
//  Created by goodcore1 on 5/21/13.
//  Copyright (c) 2013 goodcore1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"
#import "RNBlurModalView.h"
#import <AddressBookUI/AddressBookUI.h>
#import "SVProgressHUD.h"
#import "ViewController.h"

@interface BarcodeViewController : UIViewController <ZBarReaderDelegate, ZBarReaderViewDelegate, ABUnknownPersonViewControllerDelegate>

@property (strong, nonatomic) NSMutableData *responseData;

- (IBAction)openBarcodeReader:(id)sender;

- (void) openContactViewController:(NSDictionary*)jsonResponse;

- (UIView*)CommomOverlay;
- (IBAction)logout:(id)sender;

@end
