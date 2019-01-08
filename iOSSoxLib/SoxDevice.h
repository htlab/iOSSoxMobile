//
//  SoxDevice.h
//  iOSSoxLib
//
//  Created by Takuro Yonezawa on 6/8/15.
//  Copyright (c) 2015 Takuro Yonezawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SoxConnection.h"
#import "Device.h"
#import "Transducer.h"
#import "TransducerValue.h"
#import "Data.h"
#import "SoxData.h"


@protocol SoxDeviceDelegate <NSObject>
@optional
-(void)didReceivePublishedData:(SoxData *)soxdata;
@end

@interface SoxDevice : NSObject


@property (strong,nonatomic)SoxConnection *soxConnection;
@property (strong,nonatomic)NSString *nodeName;
@property (strong,nonatomic)Device *device;
@property (strong,nonatomic)Data *lastData;
@property (nonatomic,assign)id<SoxDeviceDelegate> delegate;


-(id)init;
-(id)initWithSoxConnectionAndNodeName:(SoxConnection*)_soxConnection :(NSString*)_nodeName;
-(void)subscribe;
-(void)unsubscribe;
-(void)publish:(Data*)data;
@end
