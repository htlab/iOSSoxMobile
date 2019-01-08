//
//  SoxConnection.m
//  iOSSoxLib
//
//  Created by Takuro Yonezawa on 6/8/15.
//  Copyright (c) 2015 Takuro Yonezawa. All rights reserved.
//

#import "SoxConnection.h"
#import "DDLog.h"
#import "DDTTYLogger.h"


@implementation SoxConnection{
    NSMutableArray *subscribingNodeList;
    BOOL isGetSubscriptionMode;
    BOOL isConnected;
}

@synthesize jid;
@synthesize pass;
@synthesize server;
@synthesize xmppPubSub;
@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize nodeList;

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#endif

dispatch_semaphore_t semaphoreForConnection;
dispatch_semaphore_t semaphoreForAllNodeList;

dispatch_semaphore_t semaphoreForGetSubscription;


-(id)init{
    self = [super init];
    
    nodeList = [[NSMutableArray alloc]init];
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLogLevel:XMPP_LOG_FLAG_SEND_RECV]; //all log show
    
    isConnected=NO;
    
    return self;
}

-(id)initWithAnonymousUser:(NSString*)_server{
    self = [self init];

    [self setServerAndUserAndPassword:_server :@"" : @""];
    
    return self;
}

-(id)initWithJIDandPassword:(NSString *)_server :(NSString *)_jid :(NSString *)_password{
    self = [self init];
    
    [self setServerAndUserAndPassword:_server :_jid :_password];
    
    return self;
}

-(void)setServerAndUserAndPassword:(NSString*) _server : (NSString *)_jid :(NSString *)_password{
    jid = _jid;
    server = _server;
    pass = _password;    
}

-(BOOL)connect{
    xmppStream = [[XMPPStream alloc] init];
    xmppStream.hostName = server;
    xmppStream.hostPort = 5222;
    
    if([jid isEqualToString:@""]){
        //anonymous login but myJID should be set (I don't know why..)
        xmppStream.myJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@%@",@"anonymous@",server]];
    }else{
        xmppStream.myJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",jid,server]];
    }
    
    
    xmppReconnect = [[XMPPReconnect alloc] init];
    [xmppReconnect activate:xmppStream];
    
    
    [xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    [xmppPubSub addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    NSError *error = nil;
    if (![xmppStream connectWithTimeout:10 error:&error])
    {
        DDLogError(@"Error connecting: %@", error);
    }
    
    semaphoreForConnection =dispatch_semaphore_create(0);
    dispatch_semaphore_wait(semaphoreForConnection, DISPATCH_TIME_FOREVER);

    return isConnected;
}

-(void)disconnect{

    [self goOffline];
    [self teardownStream];
}


- (void)teardownStream
{
    [xmppStream removeDelegate:self];
    [xmppPubSub removeDelegate:self];
    [xmppReconnect deactivate];
    
    [xmppStream disconnect];
    
    xmppStream = nil;
    xmppPubSub = nil;
    xmppReconnect = nil;
}

- (void)goOnline
{
    XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
    
    NSString *domain = [xmppStream.myJID domain];
    
    //Google set their presence priority to 24, so we do the same to be compatible.
    
    if([domain isEqualToString:@"gmail.com"]
       || [domain isEqualToString:@"gtalk.com"]
       || [domain isEqualToString:@"talk.google.com"])
    {
        NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
        [presence addChild:priority];
    }
    
    [[self xmppStream] sendElement:presence];
}



- (void)goOffline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    
    [[self xmppStream] sendElement:presence];
}


-(NSString*)getFormedXML:(NSString *)str{
    
    str = [str stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    str = [str stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    str = [str stringByReplacingOccurrencesOfString:@"&apos;" withString:@"\""];
    
    return str;
}

-(NSMutableArray*)getAllNodeList{
    semaphoreForAllNodeList = dispatch_semaphore_create(0);
    
    [xmppPubSub discoverItemsForNode:nil];
    
    dispatch_semaphore_wait(semaphoreForAllNodeList, DISPATCH_TIME_FOREVER);
    
    return nodeList;
    
}

-(NSMutableArray *)getSubscribingNodes{
    isGetSubscriptionMode = YES;
    subscribingNodeList = [[NSMutableArray alloc]init];
    
    semaphoreForGetSubscription = dispatch_semaphore_create(0);
    [xmppPubSub retrieveSubscriptions];
    dispatch_semaphore_wait(semaphoreForGetSubscription, DISPATCH_TIME_FOREVER);
    
    
    return subscribingNodeList;
}


-(void)publishMetaData:(NSString *)nodeName : (Device*)device{
    
    NSString *xml = @"<device";
    if(device.name!=nil) xml=[NSString stringWithFormat:@"%@ name='%@'",xml,device.name];
    if(device.id!=nil) xml=[NSString stringWithFormat:@"%@ id='%@'",xml,device.id];
    if(device.type!=nil) xml=[NSString stringWithFormat:@"%@ type='%@'",xml,device.type];
    if(device.timestamp!=nil) xml=[NSString stringWithFormat:@"%@ timestamp='%@'",xml,device.timestamp];
    if(device.description!=nil) xml=[NSString stringWithFormat:@"%@ description='%@'",xml,device.description];
    if(device.serialNumber!=nil) xml=[NSString stringWithFormat:@"%@ serialNumber='%@'",xml,device.serialNumber];
    xml=[NSString stringWithFormat:@"%@>",xml];
    
    NSMutableArray *transducerArray = device.transducersArray;
    for(Transducer *transducer in transducerArray){
        xml = [NSString stringWithFormat:@"%@ <transducer",xml];
        if(transducer.name!=nil) xml = [NSString stringWithFormat:@"%@ name='%@'",xml,transducer.name];
        if(transducer.id!=nil) xml = [NSString stringWithFormat:@"%@ id='%@'",xml,transducer.id];
        if(transducer.units!=nil) xml = [NSString stringWithFormat:@"%@ units='%@'",xml,transducer.units];
        if(transducer.unitScaler!=nil) xml = [NSString stringWithFormat:@"%@ unitScaler='%@'",xml,transducer.unitScaler];
        if(transducer.canActuate!=nil) xml = [NSString stringWithFormat:@"%@ canActuate='%@'",xml,transducer.canActuate];
        if(transducer.hasOwnNode!=nil) xml = [NSString stringWithFormat:@"%@ hasOwnNode='%@'",xml,transducer.hasOwnNode];
        if(transducer.transducerTypeName!=nil) xml = [NSString stringWithFormat:@"%@ transducerTypeName='%@'",xml,transducer.transducerTypeName];
        if(transducer.manufacture!=nil) xml = [NSString stringWithFormat:@"%@ manufacture='%@'",xml,transducer.manufacture];
        if(transducer.partNumber!=nil) xml = [NSString stringWithFormat:@"%@ partNumber='%@'",xml,transducer.partNumber];
        if(transducer.serialNumber!=nil) xml = [NSString stringWithFormat:@"%@ serialNumber='%@'",xml,transducer.serialNumber];
        if(transducer.minValue!=nil) xml = [NSString stringWithFormat:@"%@ minValue='%@'",xml,transducer.minValue];
        if(transducer.maxValue!=nil) xml = [NSString stringWithFormat:@"%@ maxValue='%@'",xml,transducer.maxValue];
        if(transducer.resolution!=nil) xml = [NSString stringWithFormat:@"%@ resolution='%@'",xml,transducer.resolution];
        if(transducer.precision!=nil) xml = [NSString stringWithFormat:@"%@ precision='%@'",xml,transducer.precision];
        if(transducer.accuracy!=nil) xml = [NSString stringWithFormat:@"%@ accuracy='%@'",xml,transducer.accuracy];
        xml=[NSString stringWithFormat:@"%@/>",xml];
    }
    xml = [NSString stringWithFormat:@"%@</device>",xml];
    
    //Create XML element to be published
    DDXMLElement *element = [[DDXMLElement alloc] initWithXMLString:xml error:nil];
    
    //Do publish
    [xmppPubSub publishToNode:[NSString stringWithFormat:@"%@_meta",nodeName] entry:element];
    
    
}

-(void)create:(NSString*)nodeName : (Device*)device : (NSString*)accessModel :(NSString*)publishModel{
    
    if(![jid isEqualToString:@""]){
        //meta node creation
        NSMutableDictionary *optionsForMetaNode = [[NSMutableDictionary alloc]init];
        [optionsForMetaNode setValue:@"1" forKey:@"persist_items"];
        [optionsForMetaNode setValue:@"1" forKey:@"max_items"];
        [optionsForMetaNode setValue:accessModel forKey:@"access_model"];
        [optionsForMetaNode setValue:publishModel forKey:@"publish_model"];
        
        [xmppPubSub createNode:[NSString stringWithFormat:@"%@_meta",nodeName] withOptions:optionsForMetaNode];
        
        
        //data node creation
        NSMutableDictionary *optionsForDataNode = [[NSMutableDictionary alloc]init];
        [optionsForDataNode setValue:@"0" forKey:@"persist_items"];
        [optionsForDataNode setValue:@"0" forKey:@"max_items"];
        [optionsForDataNode setValue:accessModel forKey:@"access_model"];
        [optionsForDataNode setValue:publishModel forKey:@"publish_model"];
        
        [xmppPubSub createNode:[NSString stringWithFormat:@"%@_data",nodeName] withOptions:optionsForDataNode];
        
        
        //Then publish meta information
        [self publishMetaData:nodeName:device];
    }
}

-(void)delete:(NSString*)nodeName{
    [xmppPubSub deleteNode:[NSString stringWithFormat:@"%@_meta",nodeName]];
    [xmppPubSub deleteNode:[NSString stringWithFormat:@"%@_data",nodeName]];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error{
    DDLogVerbose(@"%@: %@", [self class], THIS_METHOD);
    NSLog(@"did not authenticated");

    isConnected=NO;
    [xmppStream removeDelegate:self];
    [xmppPubSub removeDelegate:self];
    
    dispatch_semaphore_signal(semaphoreForConnection);

    
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    NSLog(@"authenticated");
    xmppPubSub = [[XMPPPubSub alloc] initWithServiceJID:[XMPPJID jidWithString:[NSString stringWithFormat:@"pubsub.%@",server]]];
    [xmppPubSub activate:xmppStream];
    
    [self goOnline];
    
    isConnected=YES;
    
    //semaphor
    dispatch_semaphore_signal(semaphoreForConnection);
    
}


- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    NSError *error = nil;
    
    if([jid isEqualToString:@""]){
        //anonymous authenticate
        if(![xmppStream authenticateAnonymously:&error]){
            DDLogError(@"%@: Error authenticating: %@", [self class], error);
        }else{
            NSLog(@"anonymous authenticated");
        }
        
    }else{
        
        //authenticate with JID and Password
        if (![xmppStream authenticateWithPassword:pass error:&error])
        {
            DDLogError(@"%@: Error authenticating: %@", [self class], error);
        }else{
            NSLog(@"password authenticated");
        }
    }
    
}

- (void)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
    
    
    NSString *xml = [self getFormedXML:[iq XMLString]];
    //NSLog(@"Received in SoxConnection: %@",xml);
    
    DDXMLDocument *doc = [[DDXMLDocument alloc] initWithXMLString:xml options:0 error:nil];
    
    //for node discovery
    NSArray *array  = [[doc rootElement] nodesForXPath:@"/*/*" error:nil];
    for(DDXMLElement *xmlnsNode in array){
        
        //node discovery mode
        if([[xmlnsNode xmlns] isEqualToString:@"http://jabber.org/protocol/disco#items"]){
            //Update All Node List
            [nodeList removeAllObjects];
            array  = [[doc rootElement] nodesForXPath:@"/*/*/*" error:nil];
            for(DDXMLElement *node in array){
                NSString *nodeName = [[node attributeForName:@"node"] stringValue];
                if([nodeName hasSuffix:@"_meta"]){
                    [nodeList addObject:[nodeName substringToIndex:nodeName.length-5]];
                }
            }
            
            dispatch_semaphore_signal(semaphoreForAllNodeList);
        }
        
        
    }
    
    //for subscription discovery
    if(isGetSubscriptionMode){
        array  = [[doc rootElement] nodesForXPath:@"/*/*/*/*" error:nil];
        for(DDXMLElement *node in array){
            NSString *nodeName = [[node attributeForName:@"node"] stringValue];
            [subscribingNodeList addObject:[nodeName substringToIndex:nodeName.length-5]];
        }
        isGetSubscriptionMode=NO;
        dispatch_semaphore_signal(semaphoreForGetSubscription);
    }
    
}





@end
