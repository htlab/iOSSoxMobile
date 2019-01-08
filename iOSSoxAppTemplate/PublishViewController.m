//
//  PublishViewController.m
//  iOSSoxMobile
//
//  Created by Takuro Yonezawa on 6/19/15.
//  Copyright (c) 2015 Takuro Yonezawa. All rights reserved.
//

#import "PublishViewController.h"
#import <unistd.h>


@interface PublishViewController ()

@end

@implementation PublishViewController{
    BOOL isUseLocation;
    BOOL isUseAltitude;
    BOOL isUseAccelerometer;
    BOOL isUseHeading;
    BOOL isUseSpeed;
    BOOL isUseGyro;
    BOOL isUseAirPressure;
    BOOL isUseFrontCamera;
    BOOL isUseBackCamera;
    BOOL isUseAudioLevel;
    BOOL isUseBatteryLevel;
    
    NSDateFormatter *formatter;
    NSMutableArray *transducerValuesForPublish;
    Data *dataToPublish;
    
    BOOL isAutoPublishMode;
    
    AudioQueueLevelMeterState levelMeter;
    UInt32 levelMeterSize;
    CLLocation* location;
    float batteryLevel;
    
    
    //for camera
    UIImage *backCameraImage;
    AVCaptureConnection *videoConnection;

}
@synthesize intervalTextField;
@synthesize transducerTableView;
@synthesize sensorInfoArray;
@synthesize soxDevice;
@synthesize timestampLabel;
@synthesize autoPublishButton;
@synthesize nodeToPublishLabel;
@synthesize session;

static void AudioInputCallback(
                               void* inUserData,
                               AudioQueueRef inAQ,
                               AudioQueueBufferRef inBuffer,
                               const AudioTimeStamp *inStartTime,
                               UInt32 inNumberPacketDescriptions,
                               const AudioStreamPacketDescription *inPacketDescs)
{
    //no implementation because no audio recording
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    nodeToPublishLabel.text = [soxDevice nodeName];
    
    [transducerTableView setDataSource:self];
    [transducerTableView setDelegate:self];
    [transducerTableView reloadData];
    intervalTextField.delegate = self;
    
    isUseLocation=NO;
    isUseAltitude=NO;
    isUseAccelerometer=NO;
    isUseHeading=NO;
    isUseSpeed=NO;
    isUseGyro=NO;
    isUseAirPressure=NO;
    isUseFrontCamera=NO;
    isUseBackCamera=NO;
    isUseAudioLevel=NO;
    isUseBatteryLevel=NO;
    
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    
    //setting sensors
    [self checkSensorUse];
    [self prepareSensor];
    
    //for publish
    transducerValuesForPublish = [[NSMutableArray alloc]init];
    dataToPublish = [[Data alloc]init];
    
    //for auto publishing
    isAutoPublishMode=NO;
    

    //for rotating device
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];

}

-(void)deviceOrientationDidChange:(NSNotification*)notification {
    UIDeviceOrientation orientation;
    orientation = [UIDevice currentDevice].orientation;
    if(orientation == UIDeviceOrientationUnknown) {
        NSLog(@"不明");
    }
    if(orientation == UIDeviceOrientationPortrait) {
        NSLog(@"縦(ホームボタン下)");
        [videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    }
    if(orientation == UIDeviceOrientationPortraitUpsideDown) {
        NSLog(@"縦(ホームボタン上)");
    }
    if(orientation == UIDeviceOrientationLandscapeLeft) {
        NSLog(@"横(ホームボタン右)");
    }
    if(orientation == UIDeviceOrientationLandscapeRight) {
        NSLog(@"横(ホームボタン左)");
        [videoConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
    }

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // stop audio level
    [_timer invalidate];
    [self stopUpdatingVolume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) checkSensorUse{
    for(SensorInformation *sensorInformation in sensorInfoArray){
        if(!isUseLocation){
            if([sensorInformation.iPhoneSensorName isEqualToString:LATITUDE] || [sensorInformation.iPhoneSensorName isEqualToString:LONGITUDE]){
                isUseLocation=YES;
            }
        }
        
        if(!isUseSpeed){
            if([sensorInformation.iPhoneSensorName isEqualToString:SPEED]){
                isUseSpeed=YES;
            }
        }
        
        if(!isUseAccelerometer){
            if([sensorInformation.iPhoneSensorName isEqualToString:ACCEL_X]||[sensorInformation.iPhoneSensorName isEqualToString:ACCEL_Y] || [sensorInformation.iPhoneSensorName isEqualToString:ACCEL_Z]){
                isUseAccelerometer=YES;
            }
        }
        
        if(!isUseAltitude){
            if([sensorInformation.iPhoneSensorName isEqualToString:ALTITUDE]){
                isUseAltitude=YES;
            }
        }
        
        if(!isUseGyro){
            if([sensorInformation.iPhoneSensorName isEqualToString:YAW] || [sensorInformation.iPhoneSensorName isEqualToString:ROLL] || [sensorInformation.iPhoneSensorName isEqualToString:PITCH]){
                isUseGyro=YES;
            }
        }
        if(!isUseHeading){
            if([sensorInformation.iPhoneSensorName isEqualToString:ORIENTATION] || [sensorInformation.iPhoneSensorName isEqualToString:HEADING]){
                isUseHeading=YES;
            }
        }
        
        if(!isUseAirPressure){
            if([sensorInformation.iPhoneSensorName isEqualToString:AIR_PRESSURE]){
                isUseAirPressure=YES;
            }
        }
        
        if(!isUseFrontCamera){
            if([sensorInformation.iPhoneSensorName isEqualToString:FRONT_CAMERA]){
                isUseFrontCamera=YES;
            }
        }
        
        if(!isUseBackCamera){
            if([sensorInformation.iPhoneSensorName isEqualToString:BACK_CAMERA]){
                isUseBackCamera=YES;
            }
        }
        
        if(!isUseBatteryLevel){
            if([sensorInformation.iPhoneSensorName isEqualToString:BATTERY]){
                isUseBatteryLevel=YES;
            }
        }
        
        if(!isUseAudioLevel){
            if([sensorInformation.iPhoneSensorName isEqualToString:AUDIOLEVEL]||[sensorInformation.iPhoneSensorName isEqualToString:SOUNDLEVEL]){
                isUseAudioLevel=YES;
            }
        }
        
    }
}


-(void)prepareSensor{
    
    //LATITUDE, LONGITUDE, and (HEADING or ORIENTATION)
    if(isUseLocation || isUseHeading){
        if(locationManager==nil){
            locationManager = [[CLLocationManager alloc] init];
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            //[locationManager requestWhenInUseAuthorization];
            [locationManager requestAlwaysAuthorization];
        }
        locationManager.delegate = self;
        
        if(isUseLocation){
            [locationManager startUpdatingLocation];
        }
        if(isUseHeading){
            [locationManager startUpdatingHeading];
        }
    }
    
    //ACCEL_X, ACCEL_Y and ACCEL_Z
    if(isUseAccelerometer){
        if(motionManager==nil){
            motionManager = [[CMMotionManager alloc] init];
        }
        if(motionManager.accelerometerAvailable){
            
            CMAccelerometerHandler handler = ^(CMAccelerometerData *data, NSError *error)
            {
                
                
                for(SensorInformation *sensorInfo in sensorInfoArray){
                    if([sensorInfo.iPhoneSensorName isEqualToString:ACCEL_X]){
                        sensorInfo.sensorValue = [NSString stringWithFormat:@"%f", data.acceleration.x];
                    }else if([sensorInfo.iPhoneSensorName isEqualToString:ACCEL_Y]){
                        sensorInfo.sensorValue = [NSString stringWithFormat:@"%f", data.acceleration.y];
                    }else if([sensorInfo.iPhoneSensorName isEqualToString:ACCEL_Z]){
                        sensorInfo.sensorValue = [NSString stringWithFormat:@"%f", data.acceleration.z];
                    }
                }
                
                [self updateVisibleCells];
                
            };
            
            
            [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:handler];
            
        }
    }
    
    //YAW, ROLL and PITCH
    if(isUseGyro){
        if(motionManager==nil){
            motionManager = [[CMMotionManager alloc] init];
        }
        
        if(motionManager.deviceMotionAvailable){
            
            
            CMDeviceMotionHandler handler = ^(CMDeviceMotion *data, NSError *error){
                
                for(SensorInformation *sensorInfo in sensorInfoArray){
                    if([sensorInfo.iPhoneSensorName isEqualToString:YAW]){
                        sensorInfo.sensorValue = [NSString stringWithFormat:@"%f",data.attitude.yaw];
                    }else if([sensorInfo.iPhoneSensorName isEqualToString:ROLL]){
                        sensorInfo.sensorValue = [NSString stringWithFormat:@"%f",data.attitude.roll];
                    }else if([sensorInfo.iPhoneSensorName isEqualToString:PITCH]){
                        sensorInfo.sensorValue = [NSString stringWithFormat:@"%f",data.attitude.pitch];
                    }
                    
                }
                
                [self updateVisibleCells];
            };
            
            [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:handler];
        }
        
    }
    
    //ALTITUDE and AIR_PRESSURE
    if(isUseAirPressure || isUseAltitude){
        
        if([CMAltimeter isRelativeAltitudeAvailable]){
            if(altimater==nil){
                altimater = [[CMAltimeter alloc] init];
            }
            
            CMAltitudeHandler handler =^(CMAltitudeData *data, NSError *error){
                for(SensorInformation *sensorInfo in sensorInfoArray){
                    if([sensorInfo.iPhoneSensorName isEqualToString:ALTITUDE]){
                        sensorInfo.sensorValue = [NSString stringWithFormat:@"%f",[[data relativeAltitude] doubleValue]];
                    }else if([sensorInfo.iPhoneSensorName isEqualToString:AIR_PRESSURE]){
                        sensorInfo.sensorValue = [NSString stringWithFormat:@"%f",[[data pressure] doubleValue]*10];
                    }
                }
                
                [self updateVisibleCells];
            };
            
            [altimater startRelativeAltitudeUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:handler];
        }
    }
    
    
    if(isUseBackCamera){
        

        //デバイス取得
        AVCaptureDevice* device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        //入力作成
        AVCaptureDeviceInput* deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:NULL];
        
        
        //ビデオデータ出力作成
        NSDictionary* settings = @{(id)kCVPixelBufferPixelFormatTypeKey:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]};
        AVCaptureVideoDataOutput* dataOutput = [[AVCaptureVideoDataOutput alloc] init];
        dataOutput.videoSettings = settings;
       // [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        
         dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
        
        [dataOutput setSampleBufferDelegate:self queue:queue];
        
        //セッション作成
        self.session = [[AVCaptureSession alloc] init];
        [self.session addInput:deviceInput];
        [self.session addOutput:dataOutput];
        self.session.sessionPreset = AVCaptureSessionPreset640x480;
        
        videoConnection = NULL;
        
        // カメラの向きなどを設定する
        [self.session beginConfiguration];
        
        for ( AVCaptureConnection *connection in [dataOutput connections] )
        {
            for ( AVCaptureInputPort *port in [connection inputPorts] )
            {
                if ( [[port mediaType] isEqual:AVMediaTypeVideo] )
                {
                    videoConnection = connection;
                    
                }
            }
        }
        if([videoConnection isVideoOrientationSupported]) // **Here it is, its always false**
        {
            [videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        }
        
        
        [self.session commitConfiguration];
        // セッションをスタートする
        [self.session startRunning];

        

   
    }
    
    if(isUseFrontCamera){
        //not yet implemented
    }
    
    
    
    //Battery level
    if(isUseBatteryLevel){
        [UIDevice currentDevice].batteryMonitoringEnabled = YES;
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(batteryLevelDidChange:)
                                                     name:UIDeviceBatteryLevelDidChangeNotification
                                                   object:nil];
        [self updateBatteryLevelLabel];
        
    }
    
    //audio level
    if(isUseAudioLevel){
        [self startUpdatingVolume];
    }
    
}


-(void) publish{
    
    [transducerValuesForPublish removeAllObjects];
    
    for(SensorInformation *sensorInfo in sensorInfoArray){
        if(![sensorInfo.sensorValue isEqualToString:@""]){
            
            TransducerValue *tValue = [[TransducerValue alloc]init];
            tValue.id = [[sensorInfo transducer] id];
            tValue.rawValue = [sensorInfo sensorValue];
            tValue.typedValue = [sensorInfo sensorValue];
            tValue.timestamp = [[NSDate date] xmppDateTimeString];
            [transducerValuesForPublish addObject:tValue];
            
        }
    }
    
    if([transducerValuesForPublish count]>0){
        
        dataToPublish.transducerValueArray = transducerValuesForPublish;
        
        [soxDevice publish:dataToPublish];
    }
    
}


//for cell updating
- (void)updateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Update Cells
    if([[[sensorInfoArray objectAtIndex:indexPath.row] iPhoneSensorName] isEqualToString:@"back_camera"]==NO){
        if([[sensorInfoArray objectAtIndex:indexPath.row] sensorValue]!=NULL){
        ((UILabel*)[cell viewWithTag:4]).text =[[sensorInfoArray objectAtIndex:indexPath.row] sensorValue];
        }
    }else{
        //back camera
        if(backCameraImage!=NULL){
            ((UIImageView*)[cell viewWithTag:4]).image = backCameraImage;
        }
    }
}

- (void)updateVisibleCells {
    @synchronized (self){

    for (UITableViewCell *cell in [transducerTableView visibleCells]){
        [self updateCell:cell atIndexPath:[transducerTableView indexPathForCell:cell]];
    }
    }
}


///////////////////
#pragma mark for audio sensing
///////////////////


- (void)startUpdatingVolume
{
    // record format
    AudioStreamBasicDescription dataFormat;
    dataFormat.mSampleRate = 44100.0f;
    dataFormat.mFormatID = kAudioFormatLinearPCM;
    dataFormat.mFormatFlags = kLinearPCMFormatFlagIsBigEndian | kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    dataFormat.mBytesPerPacket = 2;
    dataFormat.mFramesPerPacket = 1;
    dataFormat.mBytesPerFrame = 2;
    dataFormat.mChannelsPerFrame = 1;
    dataFormat.mBitsPerChannel = 16;
    dataFormat.mReserved = 0;
    
    // start level monitoring
    AudioQueueNewInput(&dataFormat, AudioInputCallback, (__bridge void *)(self), CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &_queue);
    AudioQueueStart(_queue, NULL);
    
    // level meter
    UInt32 enabledLevelMeter = true;
    AudioQueueSetProperty(_queue, kAudioQueueProperty_EnableLevelMetering, &enabledLevelMeter, sizeof(UInt32));
    
    // monitor level meter periodically
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                              target:self
                                            selector:@selector(detectVolume:)
                                            userInfo:nil
                                             repeats:YES];
}


- (void)stopUpdatingVolume
{
    AudioQueueFlush(_queue);
    AudioQueueStop(_queue, NO);
    AudioQueueDispose(_queue, YES);
}

- (void)detectVolume:(NSTimer *)timer
{
    // getting level
    levelMeterSize = sizeof(AudioQueueLevelMeterState);
    AudioQueueGetProperty(_queue, kAudioQueueProperty_CurrentLevelMeterDB, &levelMeter, &levelMeterSize);
    
    //NSString *audioLevel = [NSString stringWithFormat:@"%.2f", levelMeter.mPeakPower];//max level
    //NSString *audioLevel = [NSString stringWithFormat:@"%.2f", levelMeter.mAveragePower];//average level
    
    //set sensor data
    for(SensorInformation *sensorInfo in sensorInfoArray){
        if([sensorInfo.iPhoneSensorName isEqualToString:AUDIOLEVEL]){
            sensorInfo.sensorValue = [NSString stringWithFormat:@"%.2f", levelMeter.mAveragePower];
        }else if([sensorInfo.iPhoneSensorName isEqualToString:SOUNDLEVEL]){
            sensorInfo.sensorValue = [NSString stringWithFormat:@"%.2f", levelMeter.mAveragePower];
        }
    }
}


///////////////////
#pragma mark for Battery sensing
///////////////////
- (void)updateBatteryLevelLabel
{
    batteryLevel = [UIDevice currentDevice].batteryLevel;
    
    for(SensorInformation *sensorInfo in sensorInfoArray){
        if([sensorInfo.iPhoneSensorName isEqualToString:BATTERY]){
            sensorInfo.sensorValue = [NSString stringWithFormat:@"%f", batteryLevel*100];
        }
    }
    
}
- (void)batteryLevelDidChange:(NSNotification *)notification
{
    [self updateBatteryLevelLabel];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table view data source
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if([sensorInfoArray count]==0){
        return 0;
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if([sensorInfoArray count]==0){
        return 0;
    }else{
        return [sensorInfoArray count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    
    if([[[sensorInfoArray objectAtIndex:indexPath.row] iPhoneSensorName] isEqualToString:@"back_camera"]){
        cell =  [transducerTableView dequeueReusableCellWithIdentifier:@"cameraCell"];
        ((UILabel*)[cell viewWithTag:1]).text = [[[sensorInfoArray objectAtIndex:indexPath.row] transducer] name];
        ((UILabel*)[cell viewWithTag:2]).text = [[[sensorInfoArray objectAtIndex:indexPath.row] transducer] units];
        ((UILabel*)[cell viewWithTag:3]).text =[[sensorInfoArray objectAtIndex:indexPath.row] iPhoneSensorName];
        if(backCameraImage!=NULL){
            ((UIImageView*)[cell viewWithTag:4]).image = backCameraImage;
        }


    }else{
    
        cell =  [transducerTableView dequeueReusableCellWithIdentifier:@"transducerCell"];
        
        ((UILabel*)[cell viewWithTag:1]).text = [[[sensorInfoArray objectAtIndex:indexPath.row] transducer] name];
        ((UILabel*)[cell viewWithTag:2]).text = [[[sensorInfoArray objectAtIndex:indexPath.row] transducer] units];
        ((UILabel*)[cell viewWithTag:3]).text =[[sensorInfoArray objectAtIndex:indexPath.row] iPhoneSensorName];
        ((UILabel*)[cell viewWithTag:4]).text =[[sensorInfoArray objectAtIndex:indexPath.row] sensorValue];
    }
    /**
     UILabel *transducerLabel = (UILabel*)[cell viewWithTag:1];
     transducerLabel.text = [[[sensorInfoArray objectAtIndex:indexPath.row] transducer] name];
     
     UILabel *unitLabel = (UILabel*)[cell viewWithTag:2];
     unitLabel.text = [[[sensorInfoArray objectAtIndex:indexPath.row] transducer] units];
     
     UILabel *bindLabel = (UILabel*)[cell viewWithTag:3];
     bindLabel.text = [[sensorInfoArray objectAtIndex:indexPath.row] iPhoneSensorName];
     
     UILabel *valueLabel = (UILabel*)[cell viewWithTag:4];
     valueLabel.text = [[sensorInfoArray objectAtIndex:indexPath.row] sensorValue];
     **/
    
   
    
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if([[[sensorInfoArray objectAtIndex:indexPath.row] iPhoneSensorName] isEqualToString:@"back_camera"]){
        return 100;
    }
    else {
        return 44;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Location
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    location = [locations lastObject];
    //NSDate* timestamp = location.timestamp;
    //NSTimeInterval howRecent = [timestamp timeIntervalSinceNow];
    
    if(isUseLocation || isUseSpeed){
        for(SensorInformation *sensorInfo in sensorInfoArray){
            if([sensorInfo.iPhoneSensorName isEqualToString:LATITUDE]){
                sensorInfo.sensorValue = [NSString stringWithFormat:@"%.7f",location.coordinate.latitude];
            }else if([sensorInfo.iPhoneSensorName isEqualToString:LONGITUDE]){
                sensorInfo.sensorValue = [NSString stringWithFormat:@"%.7f",location.coordinate.longitude];
            }else if([sensorInfo.iPhoneSensorName isEqualToString:SPEED]){
                sensorInfo.sensorValue = [NSString stringWithFormat:@"%f",location.speed];
            }
        }
    }
    
    [self updateVisibleCells];
}

- (void)locationManager:(CLLocationManager*)manager didUpdateHeading:(CLHeading*)newHeading
{
    if(isUseHeading){
        for(SensorInformation *sensorInfo in sensorInfoArray){
            if([sensorInfo.iPhoneSensorName isEqualToString:HEADING]){
                sensorInfo.sensorValue = [NSString stringWithFormat:@"%f",newHeading.magneticHeading];
            }else if([sensorInfo.iPhoneSensorName isEqualToString:ORIENTATION]){
                sensorInfo.sensorValue = [NSString stringWithFormat:@"%f",newHeading.magneticHeading];
            }
        }
    }
    
    [self updateVisibleCells];}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)didPushPublishButton:(id)sender {
    
    [self publish];
    timestampLabel.text =  [formatter stringFromDate:[[NSDate alloc] init]];
    
}

- (IBAction)didPushAutoPublishButton:(id)sender {
    if([autoPublishButton.titleLabel.text isEqualToString:@"Auto Publish"]){
        //start auto publishing
        NSInteger s = [[intervalTextField text]integerValue];
        isAutoPublishMode=YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            
            while(isAutoPublishMode){
                @autoreleasepool{
                    [self publish];
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        timestampLabel.text =  [formatter stringFromDate:[NSDate date]];
                    });
                    
                    usleep((int)(s*1000));
                }
                
            }
        });
        
        
        [autoPublishButton setTitle:@"STOP" forState:UIControlStateNormal];
        
    }else{
        //stop publishing
        isAutoPublishMode=NO;
        
        [autoPublishButton setTitle:@"Auto Publish" forState:UIControlStateNormal];
        UIAlertView *alert =
        [[UIAlertView alloc]
         initWithTitle:@"Publish Stopped"
         message:@""
         delegate:nil
         cancelButtonTitle:nil
         otherButtonTitles:@"OK", nil
         ];
        [alert show];
    }
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



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Camera AVCapture Delegate
/////////////////////////////////

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    

    UIImage *img_mae = [self imageFromSampleBufferRef:sampleBuffer];
    //NSLog(@"width:%f height:%f",img_mae.size.width,img_mae.size.height);

    
    float widthPer = 0.5;  // リサイズ後幅の倍率
    float heightPer = 0.5;  // リサイズ後高さの倍率
    
    CGSize sz = CGSizeMake(img_mae.size.width*widthPer,
                           img_mae.size.height*heightPer);
    UIGraphicsBeginImageContext(sz);
    [img_mae drawInRect:CGRectMake(0, 0, sz.width, sz.height)];
    backCameraImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    NSData* jpgData = UIImageJPEGRepresentation(backCameraImage, 0.6f);
    NSString* jpg64Str = [NSString stringWithFormat:@"data:image/jpeg;base64,%@",[jpgData base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength]];
    
    //NSLog(@"%@",jpg64Str);

    
    
    if(isUseBackCamera){
        for(SensorInformation *sensorInfo in sensorInfoArray){
            if([sensorInfo.iPhoneSensorName isEqualToString:BACKCAMERA]){
                sensorInfo.sensorValue = jpg64Str;
                [self updateVisibleCells];
            }
        }
    }
    
    
}




// CMSampleBufferRefをUIImageへ
- (UIImage *)imageFromSampleBufferRef:(CMSampleBufferRef)sampleBuffer
{
    // イメージバッファの取得
    CVImageBufferRef    buffer;
    buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    // イメージバッファのロック
    CVPixelBufferLockBaseAddress(buffer, 0);
    // イメージバッファ情報の取得
    uint8_t*    base;
    size_t      width, height, bytesPerRow;
    base = CVPixelBufferGetBaseAddress(buffer);
    width = CVPixelBufferGetWidth(buffer);
    height = CVPixelBufferGetHeight(buffer);
    bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);
    
    // ビットマップコンテキストの作成
    CGColorSpaceRef colorSpace;
    CGContextRef    cgContext;
    colorSpace = CGColorSpaceCreateDeviceRGB();
    cgContext = CGBitmapContextCreate(
                                      base, width, height, 8, bytesPerRow, colorSpace,
                                      kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    
    // 画像の作成
    CGImageRef  cgImage;
    UIImage*    image;
    cgImage = CGBitmapContextCreateImage(cgContext);
    image = [UIImage imageWithCGImage:cgImage scale:1.0f
                          orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    CGContextRelease(cgContext);
    
    // イメージバッファのアンロック
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    return image;
}






@end
