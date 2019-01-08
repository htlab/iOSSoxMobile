//
//  SoxConnection.h
//  iOSSoxLib
//
//  Created by Takuro Yonezawa on 6/8/15.
//  Copyright (c) 2015 Takuro Yonezawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "XMPPLogging.h"
#import "Device.h"
#import "Transducer.h"

#define ACCESS_MODEL_OPEN @"open"
#define ACCESS_MODEL_AUTHORIZE @"authorize"
#define ACCESS_MODEL_WHITELIST @"whitelist"
#define ACCESS_MODEL_PRESENCE @"presence"
#define ACCESS_MODEL_ROSTER @"roster"
#define PUBLISH_MODEL_OPEN @"open"
#define PUBLISH_MODEL_PUBLISHERD @"publishers"
#define PUBLISH_MODEL_SUBSCRIBERS @"subscribers"

@interface SoxConnection : NSObject 

@property (strong,nonatomic)XMPPStream *xmppStream;
@property (strong,nonatomic)XMPPPubSub *xmppPubSub;
@property (strong,nonatomic)XMPPReconnect *xmppReconnect;
@property (strong,nonatomic)NSString *jid;
@property (strong,nonatomic)NSString *pass;
@property (strong,nonatomic)NSString *server;
@property (strong,nonatomic)NSMutableArray *nodeList;


-(id)init;
-(id)initWithAnonymousUser:(NSString*)_server;
-(id)initWithJIDandPassword:(NSString*)_server :(NSString*)_jid : (NSString*)_password;
-(void)setServerAndUserAndPassword:(NSString*) _server : (NSString *)_jid :(NSString *)_password;
-(BOOL)connect;
-(void)disconnect;
-(void)create:(NSString*)nodeName : (Device*)device : (NSString*)accessModel :(NSString*)publishModel;
-(void)delete:(NSString*)nodeName;
-(void)teardownStream;
-(NSMutableArray*)getAllNodeList;
-(NSMutableArray*)getSubscribingNodes;

@end
