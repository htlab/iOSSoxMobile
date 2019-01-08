//
//  Data.m
//  iOSSoxLib
//
//  Created by Takuro Yonezawa on 6/9/15.
//  Copyright (c) 2015 Takuro Yonezawa. All rights reserved.
//

#import "Data.h"

@implementation Data

@synthesize transducerValueArray;
@synthesize transducerSetValueArray;

-(id)init{
    self = [super init];
    transducerValueArray = [[NSMutableArray alloc]init];
    transducerSetValueArray = [[NSMutableArray alloc]init];
    return self;
}

@end
