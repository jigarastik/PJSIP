//
//  AppDelegate.h
//  TryPJSIP
//
//  Created by Jigar on 6/19/14.
//  Copyright (c) 2014 Jigar. All rights reserved.
//

#import <UIKit/UIKit.h>
//#include <pjsua-lib/pjsua.h>


//#include "call.h"

//NSString *kSIPCallState         = @"CallState";
//NSString *kSIPRegState          = @"RegState";
//NSString *kSIPMwiInfo           = @"MWIInfo";

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
//	AppDelegate *app;
//	app_config_t _app_config;
	BOOL isConnected;
	BOOL isIpod;
	
//	pjsua_acc_id  _sip_acc_id;
	
//	io_connect_t  root_port; // a reference to the Root Power Domain IOService
//	io_object_t   notifierObject; // notifier object, used to deregister later
//	IONotificationPortRef  notifyPortRef; // notification port allocated by IORegisterForSystemPower
}

@property (strong, nonatomic) UIWindow *window;
@property (retain) UINavigationController *navigationController;

//- (app_config_t *)pjsipConfig;
- (void)displayParameterError:(NSString *)msg;

@end
