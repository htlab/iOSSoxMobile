//
//  PublishViewController.h
//  iOSSoxMobile
//
//  Created by Takuro Yonezawa on 6/19/15.
//  Copyright (c) 2015 Takuro Yonezawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SoxFramework.h"
#import "AppDelegate.h"
#import "SensorInformation.h"
#import "SensorBinder.h"
#import <AVFoundation/AVFoundation.h>


@interface PublishViewController : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,AVCaptureVideoDataOutputSampleBufferDelegate            >{
    AudioQueueRef   _queue; //for audio
    NSTimer             *_timer; //for audio
    CLLocationManager *locationManager; //for GPS and heading
    CMMotionManager *motionManager; //for Gyro
    CMAltimeter *altimater; //for air pressure and altitude
}

@property (strong,nonatomic) SoxDevice *soxDevice;
@property (strong,nonatomic) NSMutableArray *sensorInfoArray;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UITextField *intervalTextField;
@property (weak, nonatomic) IBOutlet UITableView *transducerTableView;
@property (weak, nonatomic) IBOutlet UIButton *autoPublishButton;
@property (weak, nonatomic) IBOutlet UILabel *nodeToPublishLabel;
@property (strong, nonatomic) AVCaptureSession *session;

- (IBAction)didPushPublishButton:(id)sender;
- (IBAction)didPushAutoPublishButton:(id)sender;

@end
