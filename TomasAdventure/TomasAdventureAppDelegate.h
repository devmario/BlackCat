//
//  TomasAdventureAppDelegate.h
//  TomasAdventure
//
//  Created by wonhee jang on 11. 8. 17..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenGLViewController;

@interface TomasAdventureAppDelegate : NSObject <UIApplicationDelegate> {
    OpenGLViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end
