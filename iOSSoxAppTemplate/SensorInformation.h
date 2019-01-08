//
//  SensorInformation.h
//  iOSSoxMobile
//
//  Created by Takuro Yonezawa on 6/19/15.
//  Copyright (c) 2015 Takuro Yonezawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SoxFramework.h"

@interface SensorInformation : NSObject

@property (nonatomic,strong) Transducer *transducer;
@property (nonatomic,strong) NSString *iPhoneSensorName;
@property (nonatomic,strong) NSString *sensorValue;

@end
