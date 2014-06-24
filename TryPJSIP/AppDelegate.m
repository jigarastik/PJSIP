//
//  AppDelegate.m
//  TryPJSIP
//
//  Created by Jigar on 6/19/14.
//  Copyright (c) 2014 Jigar. All rights reserved.
//

#import "AppDelegate.h"

#include <unistd.h>
#import <CFNetwork/CFNetwork.h>
#include <sys/stat.h>
#import <pjlib.h>
#import <pjsua.h>
#include "pjsua_app.h"
#include "pjsua_app_config.h"

#import <pj/log.h>
#import "TestVC.h"

#define THIS_FILE	"ipjsuaAppDelegate.m"

@implementation AppDelegate

NSString *kSIPCallState         = @"CallState";
NSString *kSIPRegState          = @"RegState";
NSString *kSIPMwiInfo           = @"MWIInfo";

static pjsua_app_cfg_t  app_cfg;
static bool				isShuttingDown;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
	
	TestVC *testVC = [[TestVC alloc] init];
	
	self.navigationController = [[UINavigationController alloc] initWithRootViewController:testVC];
	self.window.rootViewController = self.navigationController;
	
//	app = self;
	[self startSIP];
	
    [self.window makeKeyAndVisible];
	
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{

}

- (void)startSIP
{	
	[self pjsuaStart];
}

- (void)initUserDefaults
{
	// TODO Franchement pas beau ;-)
	NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSNumber numberWithInt: 1800], @"regTimeout",
						  [NSNumber numberWithBool:NO], @"enableNat",
						  [NSNumber numberWithBool:NO], @"enableMJ",
						  [NSNumber numberWithInt: 5060], @"localPort",
						  [NSNumber numberWithInt: 4000], @"rtpPort",
						  [NSNumber numberWithInt: 15], @"kaInterval",
						  [NSNumber numberWithBool:NO], @"enableEC",
						  [NSNumber numberWithBool:YES], @"disableVad",
						  [NSNumber numberWithInt: 0], @"codec",
						  [NSNumber numberWithBool:NO], @"dtmfWithInfo",
						  [NSNumber numberWithBool:NO], @"enableICE",
						  [NSNumber numberWithInt: 0], @"logLevel",
						  [NSNumber numberWithBool:YES],  @"enableG711u",
						  [NSNumber numberWithBool:YES],  @"enableG711a",
						  [NSNumber numberWithBool:NO],   @"enableG722",
						  [NSNumber numberWithBool:NO],   @"enableG7221",
						  [NSNumber numberWithBool:NO],   @"enableG729",
						  [NSNumber numberWithBool:YES],  @"enableGSM",
						  [NSNumber numberWithBool:NO], @"keepAwake",
						  [NSString stringWithFormat:@"1001"],@"username",
  						  [NSString stringWithFormat:@"1001"],@"authname",
  						  [NSString stringWithFormat:@"1234"],@"password",
   						  [NSString stringWithFormat:@"10.102.3.131"],@"server",
   						  [NSString stringWithFormat:@"10.102.3.131"],@"proxyServer",
						  
						  nil];
	
	[userDef registerDefaults:dict];
	[userDef synchronize];
}

//- (app_config_t *)pjsipConfig
//{
//	return &_app_config;
//}

- (void)processCallState:(NSNotification *)notification
{
}

- (void)processRegState:(NSNotification *)notification
{
	//  const pj_str_t *str;
	//NSNumber *value = [[ notification userInfo ] objectForKey: @"AccountID"];
	//pjsua_acc_id accId = [value intValue];
//	self.networkActivityIndicatorVisible = NO;
	int status = [[[ notification userInfo ] objectForKey: @"Status"] intValue];
	
	switch(status)
	{
		case 200: // OK
			isConnected = TRUE;
//			if (launchDefault == NO)
//			{
//				pjsua_call_id call_id;
//				NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"dateOfCall"];
//				NSString *url = [[NSUserDefaults standardUserDefaults] stringForKey:@"callURL"];
//				if (date && [date timeIntervalSinceNow] < kDelayToCall)
//				{
//					sip_dial_with_uri(_sip_acc_id, [url UTF8String], &call_id);
//				}
//				[self outOfTimeToCall];
//			}
			break;
		case 403: // registration failed
		case 404: // not found
			//sprintf(TheGlobalConfig.accountError, "SIP-AUTH-FAILED");
			//break;
		case 503:
		case PJSIP_ENOCREDENTIAL:
			// This error is caused by the realm specified in the credential doesn't match the realm challenged by the server
			//sprintf(TheGlobalConfig.accountError, "SIP-REGISTER-FAILED");
			//break;
		default:
			isConnected = FALSE;
			//      [self sipDisconnect];
	}
}

/***** SIP ********/
/* */


- (void)pjsuaStart
{
	
    // TODO: read from config?
    const char **argv = pjsua_app_def_argv;
    int argc = PJ_ARRAY_SIZE(pjsua_app_def_argv) -1;
    pj_status_t status;
    
    isShuttingDown = false;
    displayMsg("Starting..");
    
    pj_bzero(&app_cfg, sizeof(app_cfg));
	
	app_cfg.argc = argc;
	app_cfg.argv = (char**)argv;

    app_cfg.on_started = &pjsuaOnStartedCb;
    app_cfg.on_stopped = &pjsuaOnStoppedCb;
    app_cfg.on_config_init = &pjsuaOnAppConfigCb;
    
    while (!isShuttingDown) {
        status = pjsua_app_init(&app_cfg);
        if (status != PJ_SUCCESS) {
            char errmsg[PJ_ERR_MSG_SIZE];
            pj_strerror(status, errmsg, sizeof(errmsg));
            displayMsg(errmsg);
            pjsua_app_destroy();
            return;
        }
		
        status = pjsua_app_run(PJ_TRUE);
        if (status != PJ_SUCCESS) {
            char errmsg[PJ_ERR_MSG_SIZE];
            pj_strerror(status, errmsg, sizeof(errmsg));
            displayMsg(errmsg);
        }
		
        pjsua_app_destroy();
    }
}

static void pjsuaOnStartedCb(pj_status_t status, const char* msg)
{
    char errmsg[PJ_ERR_MSG_SIZE];
    
    if (status != PJ_SUCCESS && (!msg || !*msg)) {
		pj_strerror(status, errmsg, sizeof(errmsg));
		PJ_LOG(3,(THIS_FILE, "Error: %s", errmsg));
		msg = errmsg;
    } else {
		PJ_LOG(3,(THIS_FILE, "Started: %s", msg));
    }

	registerAccount("1001", "1001", "1234", "10.102.3.131");
    displayMsg(msg);
}

static void pjsuaOnStoppedCb(pj_bool_t restart,
                             int argc, char** argv)
{
    PJ_LOG(3,("ipjsua", "CLI %s request", (restart? "restart" : "shutdown")));
    if (restart) {
        displayMsg("Restarting..");
		pj_thread_sleep(100);
        app_cfg.argc = argc;
        app_cfg.argv = argv;
    } else {
        displayMsg("Shutting down..");
		pj_thread_sleep(100);
//        isShuttingDown = true;
    }
}

static void pjsuaOnAppConfigCb(pjsua_app_config *cfg)
{
    PJ_UNUSED_ARG(cfg);
}

static void displayMsg(const char *msg)
{
    NSString *str = [NSString stringWithFormat:@"%s", msg];
//    [app performSelectorOnMainThread:@selector(displayMsg:) withObject:str
//                       waitUntilDone:NO];
}

-(void)displayParameterError:(NSString *)msg
{
	NSString *message = NSLocalizedString(msg, msg);
	NSString *error = [message stringByAppendingString:NSLocalizedString(
																		 @"\nTo correct this parameter, select \"Settings\" from your Home screen, "
																		 "and then tap the \"Siphon\" entry.", @"SiphonApp")];
	
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
													 message:error
#if defined(CYDIA) && (CYDIA == 1)
													delegate:self
#else
													delegate:nil
#endif
										   cancelButtonTitle:NSLocalizedString(@"Cancel", @"SiphonApp")
										   otherButtonTitles:NSLocalizedString(@"Settings", @"SiphonApp"), nil ];
	[alert show];
	//[alert release];
}

@end
