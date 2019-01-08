//
//  Device.h
//  iOSSoxLib
//
//  Created by Takuro Yonezawa on 6/9/15.
//  Copyright (c) 2015 Takuro Yonezawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Device : NSObject

@property (strong, nonatomic) NSString* nodeName;
@property (strong,nonatomic) NSString* name;
@property (strong,nonatomic) NSString* type;
@property (strong,nonatomic) NSString* id;
@property (strong,nonatomic) NSString* serialNumber;
@property (strong,nonatomic) NSString* description;
@property (strong,nonatomic) NSString* timestamp;
@property (strong,nonatomic) NSMutableArray* transducersArray;


@end
