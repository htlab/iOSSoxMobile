//
//  AppDelegate.h
//  iOSSoxAppTemplate
//
//  Created by Takuro Yonezawa on 6/16/15.
//  Copyright (c) 2015 Takuro Yonezawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoxFramework.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    SoxConnection *soxConnection;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) SoxConnection *soxConnection;

@end

