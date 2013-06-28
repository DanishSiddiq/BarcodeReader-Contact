//
//  ViewController.h
//  ContactInfo
//
//  Created by goodcore1 on 5/21/13.
//  Copyright (c) 2013 goodcore1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BarcodeViewController.h"
#import "RNBlurModalView.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"

@interface ViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField* emailText;
@property (nonatomic, weak) IBOutlet UITextField* pwdText;
@property (nonatomic, weak) IBOutlet UIButton* loginButton;
@property (strong, nonatomic) NSMutableData *responseData;

@property (nonatomic, weak) IBOutlet UIImageView* splashImageUp;
@property (nonatomic, weak) IBOutlet UIImageView* splashImageMiddle;
@property (nonatomic, weak) IBOutlet UIImageView* splashImageBottom;

- (IBAction)login:(id)sender;

- (void)showModalPopup:(NSString*)title andUserMessage:(NSString*)message;
@end
