//
//  NodeSelectViewController.h
//  iOSSoxMobile
//
//  Created by Takuro Yonezawa on 6/17/15.
//  Copyright (c) 2015 Takuro Yonezawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoxFramework.h"

@interface NodeSelectViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *nodeSelectPicker;
@property (weak, nonatomic) IBOutlet UITableView *transducerTableView;
@property (strong,nonatomic) NSMutableArray *nodeArray;
@property (strong,nonatomic) NSMutableArray *transducerArray;
@property (weak, nonatomic) IBOutlet UIButton *autoBindingButton;
@property (weak, nonatomic) IBOutlet UIButton *publishSettingButton;
@property (strong, nonatomic) NSMutableDictionary *transducerBindingDictionary;


- (IBAction)didPushSelectButton:(id)sender;
- (IBAction)didPushPublishSettingButton:(id)sender;
- (IBAction)didPushAutoBindingButton:(id)sender;


@end
