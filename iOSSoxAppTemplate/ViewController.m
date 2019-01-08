//
//  ViewController.m
//  iOSSoxAppTemplate
//
//  Created by Takuro Yonezawa on 6/16/15.
//  Copyright (c) 2015 Takuro Yonezawa. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController{
    AppDelegate *appDelegate;
    BOOL isAnonymousLogin;
}

@synthesize serverTextField;
@synthesize jidTextField;
@synthesize passTextField;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //for text editing (especially for hiding keyboard when return key is pressed
    serverTextField.delegate = self;
    jidTextField.delegate =self;
    passTextField.delegate=self;


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)didPushAnonymousLoginButton:(id)sender {
    
    isAnonymousLogin = YES;
    [self login];
    
}

- (IBAction)didPushLoginWithJIDButton:(id)sender {
    
    isAnonymousLogin = NO;
    [self login];
    
}

-(void)login{
    if(isAnonymousLogin){
        //anonymous login
        if(appDelegate.soxConnection==nil){
            appDelegate.soxConnection = [[SoxConnection alloc] initWithAnonymousUser:[serverTextField text]];
        }else{
            [appDelegate.soxConnection setServerAndUserAndPassword:[serverTextField text] :@"" :@""];
        }
    }else{
        //login with JID and Password
        if(appDelegate.soxConnection==nil){
            appDelegate.soxConnection = [[SoxConnection alloc] initWithJIDandPassword:[serverTextField text] :[jidTextField text] :[passTextField text]];
        }else{
            [appDelegate.soxConnection setServerAndUserAndPassword:[serverTextField text] :[jidTextField text] :[passTextField text]];
        }
    }
    
    if([appDelegate.soxConnection connect]){
        //move to menu view
        [self performSegueWithIdentifier:@"loginSegue" sender:self];
    }else{
        UIAlertView *alert =
        [[UIAlertView alloc]
         initWithTitle:@"Cannot Login"
         message:@"Please Check User&Password"
         delegate:nil
         cancelButtonTitle:nil
         otherButtonTitles:@"OK", nil
         ];
        [alert show];
        [appDelegate.soxConnection disconnect];
        
    }
    
    
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Navigation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark TextField Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //hide keyboard
    [self.view endEditing:YES];
    
    return YES;
}


@end
