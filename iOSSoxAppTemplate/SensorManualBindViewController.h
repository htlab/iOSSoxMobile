//
//  SensorManualBindViewController.h
//  iOSSoxMobile
//
//  Created by Takuro Yonezawa on 6/18/15.
//  Copyright (c) 2015 Takuro Yonezawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoxFramework.h"

@interface SensorManualBindViewController : UIViewController<UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *transducerLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel;

@property (weak, nonatomic) IBOutlet UIPickerView *sensorPicker;
@property (strong,nonatomic) NSMutableArray *sensorList;
@property (strong,nonatomic) NSString *selectedSensor;
@property (strong,nonatomic) Transducer *transducer;


@end
