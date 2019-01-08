//
//  SensorManualBindViewController.m
//  iOSSoxMobile
//
//  Created by Takuro Yonezawa on 6/18/15.
//  Copyright (c) 2015 Takuro Yonezawa. All rights reserved.
//

#import "SensorManualBindViewController.h"
#import "NodeSelectViewController.h"

@interface SensorManualBindViewController ()

@end

@implementation SensorManualBindViewController

@synthesize transducerLabel;
@synthesize unitLabel;
@synthesize sensorPicker;
@synthesize sensorList;
@synthesize selectedSensor;
@synthesize transducer;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    transducerLabel.text = transducer.name;
    unitLabel.text = transducer.units;
    if([transducer.units isEqualToString:@""]){
        unitLabel.text = @"not defined";
    }
    
    [sensorList addObject:@"no binding"];
    [sensorList sortUsingSelector:@selector(caseInsensitiveCompare:)];
    int index = [sensorList indexOfObject:selectedSensor];
    
    sensorPicker.delegate = self;
    [sensorPicker reloadAllComponents];
    [sensorPicker selectRow:index inComponent:0 animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    //reflect selected sensor to table in previous view
    NSArray *array = self.navigationController.viewControllers;
    int arrayCount = [array count];
    NodeSelectViewController *parent = [array objectAtIndex:arrayCount - 1];
    
    [parent.transducerBindingDictionary setObject:selectedSensor forKey:[transducer name]];
    
    [sensorList removeObject:@"no binding"];
    [parent.transducerTableView reloadData];
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Data Picker
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    
    return [sensorList count];
    
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [sensorList objectAtIndex:row];
}


-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    NSInteger selectedRow = [pickerView selectedRowInComponent:0];
    
    selectedSensor = [sensorList objectAtIndex:selectedRow];
    
    
}







/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end
