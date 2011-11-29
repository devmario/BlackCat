//
//  TomasAdventureAppDelegate.h
//  TomasAdventure
//
//  Created by wonhee jang on 11. 8. 17..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StageSelectTableViewController.h"

@interface TomasAdventureAppDelegate : NSObject <UIApplicationDelegate> {
    UINavigationController* naviVC;
    StageSelectTableViewController* stageSelectVC;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end
