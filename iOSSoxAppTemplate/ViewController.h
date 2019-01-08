//
//  ViewController.h
//  iOSSoxAppTemplate
//
//  Created by Takuro Yonezawa on 6/16/15.
//  Copyright (c) 2015 Takuro Yonezawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoxFramework.h"

@interface ViewController : UIViewController<UITextFieldDelegate,SoxDeviceDelegate>
@property (weak, nonatomic) IBOutlet UITextField *serverTextField;
@property (weak, nonatomic) IBOutlet UITextField *jidTextField;
@property (weak, nonatomic) IBOutlet UITextField *passTextField;
@property (weak, nonatomic) IBOutlet UIButton *anonymousLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *loginWithJIDButton;
- (IBAction)didPushAnonymousLoginButton:(id)sender;
- (IBAction)didPushLoginWithJIDButton:(id)sender;


@end

