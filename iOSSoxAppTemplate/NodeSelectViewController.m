//
//  NodeSelectViewController.m
//  iOSSoxMobile
//
//  Created by Takuro Yonezawa on 6/17/15.
//  Copyright (c) 2015 Takuro Yonezawa. All rights reserved.
//

#import "NodeSelectViewController.h"
#import "AppDelegate.h"
#import "SensorBinder.h"
#import "SensorManualBindViewController.h"
#import "SensorInformation.h"
#import "PublishViewController.h"

@interface NodeSelectViewController ()

@end

@implementation NodeSelectViewController{
    AppDelegate *appDelegate;
    SoxConnection *soxConnection;
    NSMutableArray *allNodeList;
    NSString *nodeToPublish;
    SoxDevice *soxDevice;
    SensorBinder *sensorBinder;
    NSIndexPath *selectedIndexPath;
}

@synthesize nodeArray;
@synthesize nodeSelectPicker;
@synthesize transducerTableView;
@synthesize transducerArray;
@synthesize autoBindingButton;
@synthesize publishSettingButton;
@synthesize transducerBindingDictionary;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    soxConnection = appDelegate.soxConnection;
    
    //delegate setting
    nodeSelectPicker.delegate = self;
    [transducerTableView setDataSource:self];
    [transducerTableView setDelegate:self];
    
    //initialize
    transducerArray = [[NSMutableArray alloc]init];
    transducerBindingDictionary = [[NSMutableDictionary alloc] init];
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    soxConnection = appDelegate.soxConnection;
    
    allNodeList = [soxConnection getAllNodeList];
    [allNodeList sortUsingSelector:@selector(caseInsensitiveCompare:)];
    
    self.transducerTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    [autoBindingButton setHidden:YES];
    [publishSettingButton setHidden:YES];
    
    
    //For sensor binding mechanism
    sensorBinder = [[SensorBinder alloc]init];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    return [allNodeList count];
    
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [allNodeList objectAtIndex:row];
}


-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    NSInteger selectedRow = [pickerView selectedRowInComponent:0];
    
    nodeToPublish = [allNodeList objectAtIndex:selectedRow];
    
    
}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UILabel *pickerLabel = (UILabel *)view;
    if (pickerLabel == nil) {
        CGRect frame = CGRectMake(0.0, 0.0, 180 , 20);
        pickerLabel = [[UILabel alloc] initWithFrame:frame];
        [pickerLabel setTextAlignment:UITextAlignmentLeft];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:12]];
    }
    
    //set label size
    [pickerLabel setText:[allNodeList objectAtIndex:row]];
    
    return pickerLabel;
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table view data source
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if([transducerArray count]==0){
        return 0;
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if([transducerArray count]==0){
        return 0;
    }else{
        return [transducerArray count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    
    //publish button
    
    
    cell =  [transducerTableView dequeueReusableCellWithIdentifier:@"transducerCell"];
    Transducer *transducer = [transducerArray objectAtIndex:indexPath.row];
    UILabel *transducerLabel = (UILabel*)[cell viewWithTag:1];
    transducerLabel.text = transducer.name;
    
    UILabel *unitLabel = (UILabel*)[cell viewWithTag:2];
    unitLabel.text = transducer.units;
    
    UILabel *bindLabel = (UILabel*)[cell viewWithTag:3];
    bindLabel.text = [transducerBindingDictionary objectForKey:transducer.name];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"settingSegue" sender:self];
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier  isEqualToString:@"settingSegue"]) {
        
        SensorManualBindViewController *sensorManualBindViewController = segue.destinationViewController;
        Transducer *transducer = [transducerArray objectAtIndex:selectedIndexPath.row];
        sensorManualBindViewController.selectedSensor = [transducerBindingDictionary objectForKey:[transducer name]];
        sensorManualBindViewController.transducer = transducer;
        sensorManualBindViewController.sensorList = sensorBinder.sensorList;
        
    }else if([segue.identifier isEqualToString:@"publishSegue"]){
        
        if(soxDevice!=nil){
            PublishViewController *publishViewController = segue.destinationViewController;
            publishViewController.soxDevice = soxDevice;
            publishViewController.sensorInfoArray = [[NSMutableArray alloc]init];
            for(Transducer *transducer in transducerArray){
                
                NSString *iPhoneSensor = [transducerBindingDictionary objectForKey:[transducer name]];
                //set binding information to array in publish view controller.
                if(![iPhoneSensor isEqualToString:@"no binding"]){
                    SensorInformation *sensorInfo = [[SensorInformation alloc] init];
                    sensorInfo.transducer = transducer;
                    sensorInfo.iPhoneSensorName = iPhoneSensor;
                    [publishViewController.sensorInfoArray addObject:sensorInfo];
                }
                
            }
            
        }
    }
    
}


- (IBAction)didPushSelectButton:(id)sender {
    soxDevice = [[SoxDevice alloc] initWithSoxConnectionAndNodeName:soxConnection :nodeToPublish ];
    
    transducerArray = [soxDevice.device.transducersArray mutableCopy];
    
    //set dictionary
    [transducerBindingDictionary removeAllObjects];
    for(Transducer *transducer in transducerArray){
        [transducerBindingDictionary setObject:@"no binding" forKey:transducer.name];
    }
    
    [transducerTableView reloadData];
    
    //show buttons
    [autoBindingButton setHidden:NO];
    [publishSettingButton setHidden:NO];
}

- (IBAction)didPushAutoBindingButton:(id)sender {
    int bindCount=0;
    
    if([transducerArray count]>0){
        for(Transducer *transducer in transducerArray){
            
            NSString *candidate = [sensorBinder getSimilarSensor:transducer.name :0.4];
            if([candidate isEqualToString:@""]){
                [transducerBindingDictionary setObject:@"no binding" forKey:transducer.name];
            }else{
                [transducerBindingDictionary setObject:candidate forKey:transducer.name];
                bindCount++;
            }
            
        }
        
        [transducerTableView reloadData];
        
        UIAlertView *alert =
        [[UIAlertView alloc]
         initWithTitle:@"Auto Bind Complete"
         message:[NSString stringWithFormat:@"%d/%ld sensors are binded.",bindCount,[transducerArray count]]
         delegate:nil
         cancelButtonTitle:nil
         otherButtonTitles:@"OK", nil
         ];
        [alert show];
        
    }
}


- (IBAction)didPushPublishSettingButton:(id)sender {
    [self performSegueWithIdentifier:@"publishSegue" sender:self];
}







@end
