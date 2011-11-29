//
//  SavePointSelectTableViewController.h
//  TomasAdventure
//
//  Created by wonhee jang on 11. 11. 28..
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TomasData.h"
#import "LevelData.h"

@interface SavePointSelectTableViewController : UITableViewController {
    TomasData* tomasData;
    LevelData* levelData;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil tomasData:(TomasData*)_tomasData;

@end
