//
//  MenuViewController.m
//  iOSSoxAppTemplate
//
//  Created by Takuro Yonezawa on 6/16/15.
//  Copyright (c) 2015 Takuro Yonezawa. All rights reserved.
//

#import "MenuViewController.h"
#import "AppDelegate.h"
#import "ViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController{
    AppDelegate *appDelegate;
    SoxConnection *soxConnection;
    
}
@synthesize serverLabel;
@synthesize userLabel;



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    soxConnection = appDelegate.soxConnection;
    [serverLabel setText:[soxConnection server]];
    if(![soxConnection.jid isEqualToString:@""]){
        [userLabel setText:[soxConnection jid]];
    }else{
        [userLabel setText:@"anonymous"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)didPushLogoutButton:(id)sender {
    
    [self performSegueWithIdentifier:@"logoutSegue" sender:self];
    
}

- (IBAction)didPushSelectNodeButton:(id)sender {
    [self performSegueWithIdentifier:@"selectSegue" sender:self];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ( [[segue identifier] isEqualToString:@"logoutSegue"] ) {
        
        [soxConnection disconnect];
   
         [self.navigationController setNavigationBarHidden:YES animated:YES];
        
    }
    

}


@end
