//
//  MenuViewController.h
//  iOSSoxAppTemplate
//
//  Created by Takuro Yonezawa on 6/16/15.
//  Copyright (c) 2015 Takuro Yonezawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoxFramework.h"

@interface MenuViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *serverLabel;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
- (IBAction)didPushLogoutButton:(id)sender;
- (IBAction)didPushSelectNodeButton:(id)sender;

@end
