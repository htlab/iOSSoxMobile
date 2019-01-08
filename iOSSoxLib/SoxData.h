//
//  SoxData.h
//  iOSSoxLib
//
//  Created by Takuro Yonezawa on 6/11/15.
//  Copyright (c) 2015 Takuro Yonezawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Device.h"
#import "Data.h"

@interface SoxData : NSObject

@property (nonatomic,strong) Device *device;
@property (nonatomic,strong) Data *data;

@end
