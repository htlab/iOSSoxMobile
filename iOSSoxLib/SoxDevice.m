//
//  SoxDevice.m
//  iOSSoxLib
//
//  Created by Takuro Yonezawa on 6/8/15.
//  Copyright (c) 2015 Takuro Yonezawa. All rights reserved.
//

#import "SoxDevice.h"

@implementation SoxDevice{
    BOOL isUnsubscribeMode;
    NSMutableArray *transducerValueArrayForPublish;
}

@synthesize soxConnection;
@synthesize nodeName;
@synthesize device;
@synthesize lastData;


dispatch_semaphore_t semaphoreForDeviceCreation;
dispatch_semaphore_t semaphoreForUnsubscribing;

-(id)init{
    self = [super init];
    return self;
}

-(id)initWithSoxConnectionAndNodeName:(SoxConnection *)_soxConnection :(NSString *)_nodeName{
    self = [super init];
    soxConnection = _soxConnection;
    nodeName = _nodeName;
    
    [soxConnection.xmppPubSub addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    //retrieve last node
    [soxConnection.xmppPubSub retrieveItemsFromNode:[NSString stringWithFormat:@"%@_meta",nodeName]];
    
    //waiting until device create by getting meta data
    semaphoreForDeviceCreation=dispatch_semaphore_create(0);
    dispatch_semaphore_wait(semaphoreForDeviceCreation, DISPATCH_TIME_FOREVER);
    
    return self;
}

-(void)subscribe{
    
    //unsubscribing all subscription with myJID to prevent double-subscribing. First getting subscription list and unsubscribe with the subscription information. see in delegate method of - (void)xmppPubSub:(XMPPPubSub *)sender didRetrieveSubscriptions:(XMPPIQ *)iq forNode:(NSString *)node
    isUnsubscribeMode = YES;
    semaphoreForUnsubscribing=dispatch_semaphore_create(0);
    [soxConnection.xmppPubSub retrieveSubscriptionsForNode:[NSString stringWithFormat:@"%@_data",nodeName]];
    dispatch_semaphore_wait(semaphoreForUnsubscribing, DISPATCH_TIME_FOREVER);     //waiting until device unsubscribing
    
    //then, subscribe the node
    [soxConnection.xmppPubSub subscribeToNode:[NSString stringWithFormat:@"%@_data",nodeName]];
}

-(void)unsubscribe{
    isUnsubscribeMode = YES;
    semaphoreForUnsubscribing=dispatch_semaphore_create(0);
    [soxConnection.xmppPubSub retrieveSubscriptionsForNode:[NSString stringWithFormat:@"%@_data",nodeName]];
    dispatch_semaphore_wait(semaphoreForUnsubscribing, DISPATCH_TIME_FOREVER);     //waiting until device unsubscribing
}

-(void)publish:(Data*)data{
    
    //Make Publish Data as XML (now only for transducerValues in data objects. will implement transducerSetValues)
    
    NSString *xml =@"<data>";
    
    transducerValueArrayForPublish= data.transducerValueArray;
    
    for(TransducerValue *tValue in transducerValueArrayForPublish){
        
        xml = [NSString stringWithFormat:@"%@<transducerValue id='%@' rawValue='%@' typedValue='%@' timestamp='%@' />",xml,tValue.id,tValue.rawValue,tValue.typedValue,tValue.timestamp];
    }
    xml = [NSString stringWithFormat:@"%@</data>",xml];
    
    //Create XML element to be published
    DDXMLElement *element = [[DDXMLElement alloc] initWithXMLString:xml error:nil];
    
    //Do publish
    [soxConnection.xmppPubSub publishToNode:[NSString stringWithFormat:@"%@_data",nodeName] entry:element];
    
    
    
}


-(BOOL)isDataFromMyMetaNode:(NSString *)node{
    if([node isEqualToString:[NSString stringWithFormat:@"%@_meta",nodeName]]){
        return YES;
    }
    return NO;
}

-(BOOL)isDataFromMyDataNode:(NSString *)node{
    if([node isEqualToString:[NSString stringWithFormat:@"%@_data",nodeName]]){
        return YES;
    }
    return NO;
}

-(NSString*)getFormedXML:(NSString *)str{
    
    str = [str stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    str = [str stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    str = [str stringByReplacingOccurrencesOfString:@"&apos;" withString:@"\""];
    
    return str;
}

-(NSString*)getMetaNodeName{
    return [NSString stringWithFormat:@"%@_meta",nodeName];
}

-(NSString*)getDataNodeName{
    return [NSString stringWithFormat:@"%@_data",nodeName];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPPubSub Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)xmppPubSub:(XMPPPubSub *)sender didRetrieveItems:(XMPPIQ *)iq fromNode:(NSString *)node{
    //NSLog(@"Last Item %@",[iq XMLString]);
    
    NSString *xml = [self getFormedXML:[iq XMLString]];
    DDXMLDocument *doc = [[DDXMLDocument alloc] initWithXMLString:xml options:0 error:nil];
    NSArray *array  = [[doc rootElement] nodesForXPath:@"/*/*" error:nil];
    
    for(DDXMLElement *xmlnsNode in array){
        
        
        if([[xmlnsNode xmlns] isEqualToString:@"http://jabber.org/protocol/pubsub"]){
            
            NSError *error=nil;
            array  = [[doc rootElement] nodesForXPath:@"/*/*/*" error:&error];
            
            NSString *name;
            
            for(DDXMLElement* node in array){
                
                name=[[node attributeForName:@"node"] stringValue];
                
                //setting device information to device
                if(name!=nil  && [name hasSuffix:@"_meta"] && [nodeName isEqualToString:[name substringToIndex:name.length-5]]){
                    //registerDevice
                    array  = [[doc rootElement] nodesForXPath:@"/*/*/*/*/*" error:&error];
                    
                    for(DDXMLElement *node in array){
                        device = [[Device alloc]init];
                        device.name =[[node attributeForName:@"name"] stringValue];
                        device.type = [[node attributeForName:@"type"] stringValue];
                        
                        array = [[doc rootElement] nodesForXPath:@"/*/*/*/*/*/*" error:nil];
                        
                        for(DDXMLElement* node in array){
                            Transducer *transducer = [[Transducer alloc]init];
                            transducer.name = [[node attributeForName:@"name"] stringValue];
                            
                            transducer.id = [[node attributeForName:@"id"] stringValue];
                            transducer.units = [[node attributeForName:@"units"] stringValue];
                            transducer.unitScaler = [[node attributeForName:@"unitScaler"] stringValue];
                            transducer.canActuate = [[node attributeForName:@"canActuate"] stringValue];
                            transducer.hasOwnNode = [[node attributeForName:@"hasOwnNode"] stringValue];
                            transducer.transducerTypeName = [[node attributeForName:@"transducerTypeName"] stringValue];
                            transducer.manufacture = [[node attributeForName:@"manufacture"] stringValue];
                            transducer.partNumber = [[node attributeForName:@"partNumber"] stringValue];
                            transducer.serialNumber = [[node attributeForName:@"serialNumber"] stringValue];
                            transducer.minValue = [[node attributeForName:@"minValue"] stringValue];
                            transducer.maxValue = [[node attributeForName:@"maxValue"] stringValue];
                            transducer.resolution = [[node attributeForName:@"resolution"] stringValue];
                            transducer.precision = [[node attributeForName:@"precision"] stringValue];
                            transducer.accuracy = [[node attributeForName:@"accuracy"] stringValue];
                            [device.transducersArray addObject:transducer];
                        }
                    }
                    
                    
                    dispatch_semaphore_signal(semaphoreForDeviceCreation);
                }
                
            }
        }
    }
    
    
    
    
}

- (void)xmppPubSub:(XMPPPubSub *)sender didNotRetrieveItems:(XMPPIQ *)iq fromNode:(NSString *)node{
    NSLog(@"%@",[iq XMLString]);
    
    dispatch_semaphore_signal(semaphoreForDeviceCreation);
}

- (void)xmppPubSub:(XMPPPubSub *)sender didReceiveMessage:(XMPPMessage *)message{
    
    NSLog(@"PubSub Message:  %@",[self getFormedXML:[message XMLString]]);
    
    NSString *xml = [self getFormedXML:[message XMLString]];
    DDXMLElement *element = [[DDXMLElement alloc] initWithXMLString:xml error:nil];
    NSArray *array = [element nodesForXPath:@"/*/*/*" error:nil];
    for(DDXMLElement* node in array){
        
        if([self isDataFromMyDataNode:[[node attributeForName:@"node"] stringValue]]){
            
            NSArray *array = [node nodesForXPath:@"/*/*/*/*" error:nil];
            Data *data = [[Data alloc]init];
            TransducerValue *tValue;
            for(DDXMLElement* node in array){
                
                tValue = [[TransducerValue alloc] init];
                tValue.id = [[node attributeForName:@"id"] stringValue];
                tValue.rawValue = [[node attributeForName:@"rawValue"] stringValue];
                tValue.typedValue = [[node attributeForName:@"typedValue"] stringValue];
                tValue.timestamp = [[node attributeForName:@"timestamp"] stringValue];
                [[data transducerValueArray] addObject:tValue];
            }
            
            
            //Creating SoxData for delegating
            SoxData *soxData = [[SoxData alloc] init];
            soxData.device = device;
            soxData.data = data;
            
            
            //fire delegate
            if ([self.delegate respondsToSelector:@selector(didReceivePublishedData:)]){
                [self.delegate didReceivePublishedData:soxData];
            }
            
        }
        
        
    }
}

- (void)xmppPubSub:(XMPPPubSub *)sender didRetrieveSubscriptions:(XMPPIQ *)iq{
    
    NSLog(@"didRetrieveSubscruptions Message in SoxDevice %@",[iq XMLString]);
    
}

- (void)xmppPubSub:(XMPPPubSub *)sender didNotRetrieveSubscriptions:(XMPPIQ *)iq{
    NSLog(@"didNotRetrieveSubscruptions Message in SoxDevice %@",[iq XMLString]);
    
}


- (void)xmppPubSub:(XMPPPubSub *)sender didRetrieveSubscriptions:(XMPPIQ *)iq forNode:(NSString *)node{
    NSLog(@"didRetrieveSubscruptionsForNode Message in SoxDevice %@",[iq XMLString]);
    
    if(isUnsubscribeMode){
        DDXMLDocument *doc = [[DDXMLDocument alloc] initWithXMLString:[iq XMLString] options:0 error:nil];
        NSArray *array  = [[doc rootElement] nodesForXPath:@"/*/*/*/*" error:nil];
        
        for(DDXMLElement* node in array){
            NSString *jid = [[node attributeForName:@"jid"] stringValue];
            NSString *subid = [[node attributeForName:@"subid"] stringValue];
            NSLog(@"unsubscribing %@ : %@",jid,subid);
            
            [soxConnection.xmppPubSub unsubscribeFromNode:[self getDataNodeName] withJID:[XMPPJID jidWithString:jid] subid:subid];
        }
        
        dispatch_semaphore_signal(semaphoreForUnsubscribing);
        isUnsubscribeMode=NO;
    }
    
}

- (void)xmppPubSub:(XMPPPubSub *)sender didNotRetrieveSubscriptions:(XMPPIQ *)iq forNode:(NSString *)node{
    NSLog(@"didNotRetrieveSubscruptionsForNode Message in SoxDevice %@",[iq XMLString]);
    if(isUnsubscribeMode){
        dispatch_semaphore_signal(semaphoreForUnsubscribing);
        isUnsubscribeMode=NO;
    }
    
}



@end
