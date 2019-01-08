//
//  Transducer.h
//  iOSSoxLib
//
//  Created by Takuro Yonezawa on 6/9/15.
//  Copyright (c) 2015 Takuro Yonezawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Transducer : NSObject

@property (strong,nonatomic) NSString* name;
@property (strong,nonatomic) NSString* id;
@property (strong,nonatomic) NSString* units;
@property (strong,nonatomic) NSString* unitScaler;
@property (strong,nonatomic) NSString* canActuate;
@property (strong,nonatomic) NSString* hasOwnNode;
@property (strong,nonatomic) NSString* transducerTypeName;
@property (strong,nonatomic) NSString* manufacture;
@property (strong,nonatomic) NSString* partNumber;
@property (strong,nonatomic) NSString* serialNumber;
@property (strong,nonatomic) NSString* minValue;
@property (strong,nonatomic) NSString* maxValue;
@property (strong,nonatomic) NSString* resolution;
@property (strong,nonatomic) NSString* precision;
@property (strong,nonatomic) NSString* accuracy;



@end
