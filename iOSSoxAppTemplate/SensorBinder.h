//
//  SensorBinder.h
//  iOSSoxMobile
//
//  Created by Takuro Yonezawa on 6/17/15.
//  Copyright (c) 2015 Takuro Yonezawa. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ACCEL_X @"accel_x"
#define ACCEL_Y @"accel_y"
#define ACCEL_Z @"accel_z"
#define YAW @"yaw"
#define ROLL @"roll"
#define PITCH @"pitch"
#define LONGITUDE @"longtitude"
#define LATITUDE @"latitude"
#define ALTITUDE @"altitude"
#define AIR_PRESSURE @"air_pressure"
#define HEADING @"heading"
#define SPEED @"speed"
#define ORIENTATION @"orientation"
#define FRONT_CAMERA @"front_camera"
#define BACK_CAMERA @"back_camera"
#define BATTERY @"battery"
#define SOUNDLEVEL @"sound_level"
#define AUDIOLEVEL @"audio_level"
#define FRONTCAMERA @"front_camera"
#define BACKCAMERA @"back_camera"

@interface SensorBinder : NSObject

@property (strong,nonatomic) NSMutableArray *sensorList;

-(NSString*) getSimilarSensor:(NSString*)target :(float)minSimilarity;

@end
