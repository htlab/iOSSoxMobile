//
//  SensorBinder.m
//  iOSSoxMobile
//
//  Created by Takuro Yonezawa on 6/17/15.
//  Copyright (c) 2015 Takuro Yonezawa. All rights reserved.
//

#import "SensorBinder.h"
#import "NSString+Score.h"
#import <sys/utsname.h>

@implementation SensorBinder

@synthesize sensorList;

-(id)init{
    self = [super init];
    
    sensorList = [[NSMutableArray alloc] init];
    
    //set sensor list
    NSString* deviceName = getDeviceName();
    
    NSLog(@"%@",deviceName);
    
    bool is_Simulator =  ([deviceName isEqualToString:@"i386"] || [deviceName isEqualToString:@"x86_64"]);
    bool is_iPhone5 = ([deviceName hasPrefix:@"iPhone5,"] || [deviceName hasPrefix:@"iPhone6,"]);
    bool is_iPhone6 =  ([deviceName isEqualToString:@"iPhone7,2"]);
    bool is_iPhone6Plus =  ([deviceName isEqualToString:@"iPhone7,1"]);
    bool is_iPhone6s =  ([deviceName isEqualToString:@"iPhone8,1"]);
    bool is_iPhone7 =([deviceName isEqualToString:@"iPhone9,1"]||[deviceName isEqualToString:@"iPhone9,3"]);
    bool is_iPhone7Plus =([deviceName isEqualToString:@"iPhone9,2"]||[deviceName isEqualToString:@"iPhone9,4"]);
    bool is_iPhone8 = ([deviceName isEqualToString:@"iPhone10,1"]||[deviceName isEqualToString:@"iPhone10,2"]||[deviceName isEqualToString:@"iPhone10,4"]||[deviceName isEqualToString:@"iPhone10,5"]);
    bool is_iPadMini3 = ([deviceName isEqualToString:@"iPad4,8"]);

    if(is_Simulator){
        
        [sensorList addObject:ACCEL_X];
        [sensorList addObject:ACCEL_Y];
        [sensorList addObject:ACCEL_Z];
        [sensorList addObject:YAW];
        [sensorList addObject:ROLL];
        [sensorList addObject:PITCH];
        [sensorList addObject:LONGITUDE];
        [sensorList addObject:LATITUDE];
        [sensorList addObject:ALTITUDE];
        [sensorList addObject:AIR_PRESSURE];
        [sensorList addObject:HEADING];
        [sensorList addObject:ORIENTATION]; //same as heading
        [sensorList addObject:SPEED];
        [sensorList addObject:BATTERY];
        [sensorList addObject:SOUNDLEVEL];
        [sensorList addObject:AUDIOLEVEL]; //same as sound level
        [sensorList addObject:FRONTCAMERA];
        [sensorList addObject:BACKCAMERA];
        //not yet implemented camera function
        
    }else if(is_iPhone5){
        //without air pressure
        [sensorList addObject:ACCEL_X];
        [sensorList addObject:ACCEL_Y];
        [sensorList addObject:ACCEL_Z];
        [sensorList addObject:YAW];
        [sensorList addObject:ROLL];
        [sensorList addObject:PITCH];
        [sensorList addObject:LONGITUDE];
        [sensorList addObject:LATITUDE];
        [sensorList addObject:ALTITUDE];
        [sensorList addObject:HEADING];
        [sensorList addObject:ORIENTATION]; //same as heading
        [sensorList addObject:SPEED];
        [sensorList addObject:BATTERY];
        [sensorList addObject:SOUNDLEVEL];
        [sensorList addObject:AUDIOLEVEL]; //same as sound level
        [sensorList addObject:FRONTCAMERA];
        [sensorList addObject:BACKCAMERA];
        
    }else if(is_iPhone6 || is_iPhone6Plus){
        [sensorList addObject:ACCEL_X];
        [sensorList addObject:ACCEL_Y];
        [sensorList addObject:ACCEL_Z];
        [sensorList addObject:YAW];
        [sensorList addObject:ROLL];
        [sensorList addObject:PITCH];
        [sensorList addObject:LONGITUDE];
        [sensorList addObject:LATITUDE];
        [sensorList addObject:ALTITUDE];
        [sensorList addObject:AIR_PRESSURE];
        [sensorList addObject:HEADING];
        [sensorList addObject:ORIENTATION]; //same as heading
        [sensorList addObject:SPEED];
        [sensorList addObject:BATTERY];
        [sensorList addObject:SOUNDLEVEL];
        [sensorList addObject:AUDIOLEVEL]; //same as sound level
        [sensorList addObject:FRONTCAMERA];
        [sensorList addObject:BACKCAMERA];

        //not yet implemented camera function

    }else if(is_iPhone6s){
        [sensorList addObject:ACCEL_X];
        [sensorList addObject:ACCEL_Y];
        [sensorList addObject:ACCEL_Z];
        [sensorList addObject:YAW];
        [sensorList addObject:ROLL];
        [sensorList addObject:PITCH];
        [sensorList addObject:LONGITUDE];
        [sensorList addObject:LATITUDE];
        [sensorList addObject:ALTITUDE];
        [sensorList addObject:AIR_PRESSURE];
        [sensorList addObject:HEADING];
        [sensorList addObject:ORIENTATION]; //same as heading
        [sensorList addObject:SPEED];
        [sensorList addObject:BATTERY];
        [sensorList addObject:SOUNDLEVEL];
        [sensorList addObject:AUDIOLEVEL]; //same as sound level
        [sensorList addObject:FRONTCAMERA];
        [sensorList addObject:BACKCAMERA];

        
    }else if(is_iPhone7Plus || is_iPhone7 || is_iPhone8){
        [sensorList addObject:ACCEL_X];
        [sensorList addObject:ACCEL_Y];
        [sensorList addObject:ACCEL_Z];
        [sensorList addObject:YAW];
        [sensorList addObject:ROLL];
        [sensorList addObject:PITCH];
        [sensorList addObject:LONGITUDE];
        [sensorList addObject:LATITUDE];
        [sensorList addObject:ALTITUDE];
        [sensorList addObject:AIR_PRESSURE];
        [sensorList addObject:HEADING];
        [sensorList addObject:ORIENTATION]; //same as heading
        [sensorList addObject:SPEED];
        [sensorList addObject:BATTERY];
        [sensorList addObject:SOUNDLEVEL];
        [sensorList addObject:AUDIOLEVEL]; //same as sound level
        [sensorList addObject:FRONTCAMERA];
        [sensorList addObject:BACKCAMERA];
        
        //not yet implemented camera function
        
    }
    else if(is_iPadMini3){
        [sensorList addObject:ACCEL_X];
        [sensorList addObject:ACCEL_Y];
        [sensorList addObject:ACCEL_Z];
        [sensorList addObject:YAW];
        [sensorList addObject:ROLL];
        [sensorList addObject:PITCH];
        [sensorList addObject:LONGITUDE];
        [sensorList addObject:LATITUDE];
        [sensorList addObject:ALTITUDE];
        [sensorList addObject:HEADING];
        [sensorList addObject:ORIENTATION]; //same as heading
        [sensorList addObject:SPEED];
        [sensorList addObject:BATTERY];
        [sensorList addObject:SOUNDLEVEL];
        [sensorList addObject:AUDIOLEVEL]; //same as sound level
        [sensorList addObject:FRONTCAMERA];
        [sensorList addObject:BACKCAMERA];
        //not yet implemented camera function
        
    }
    
    return self;
}

-(NSString*) getSimilarSensor:(NSString*)target :(float)minSimilarity{
    
    float similarity=0;
    NSString *candidateSensor=@"";

    for(NSString *sensor in sensorList){
        float s = [sensor scoreAgainst:target fuzziness:[NSNumber numberWithFloat:0.8]];
        //NSLog(@"%@ %f",sensor,s);
        if(s>similarity){
            similarity = s;
            candidateSensor = sensor;
        }
    }
    
    if(similarity>=minSimilarity){
        return candidateSensor;
    }
    
    return @"";
}


NSString* getDeviceName()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

@end
