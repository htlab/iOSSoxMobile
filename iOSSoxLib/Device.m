//
//  Device.m
//  iOSSoxLib
//
//  Created by Takuro Yonezawa on 6/9/15.
//  Copyright (c) 2015 Takuro Yonezawa. All rights reserved.
//

#import "Device.h"

@implementation Device
@synthesize nodeName;
@synthesize name;
@synthesize type;
@synthesize id;
@synthesize serialNumber;
@synthesize description;
@synthesize timestamp;
@synthesize transducersArray;

-(id)init{
    self = [super init];
    transducersArray = [[NSMutableArray alloc] init];
    return self;
}

@end
