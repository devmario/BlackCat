//
//  SavePointSelectTableViewController.m
//  TomasAdventure
//
//  Created by wonhee jang on 11. 11. 28..
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SavePointSelectTableViewController.h"
#import "OpenGLViewController.h"
#import "TomasWorld.h"

@implementation SavePointSelectTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil tomasData:(TomasData*)_tomasData {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    tomasData = _tomasData;
    levelData = [[LevelData alloc] initWithContentsOfFile:[tomasData getCurrentStageFile]];
    [self setTitle:@"Select Save Point"];
    return self;
}

- (void)dealloc {
    [levelData release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [levelData->saveBody count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        if(indexPath.row == 0)
            [cell.textLabel setText:@"시작지점"];
        else {
            GameObject* obj = [levelData->saveBody objectAtIndex:indexPath.row - 1];
            b2PolygonShape* ps = (b2PolygonShape*)obj->shape;
            [cell.textLabel setText:[NSString stringWithFormat:@"x = %i, y = %i 좌표의 세이브 포인트", (int)floorf(ps->GetVertex(0).x * 20.0), (int)floorf(ps->GetVertex(0).y * 20.0)]];
        }
    }
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OpenGLViewController* gameVC = [[OpenGLViewController alloc] initWithNibName:@"OpenGLViewController" bundle:[NSBundle mainBundle] tomasData:tomasData levelData:levelData];
    [self.navigationController pushViewController:gameVC animated:YES];
    [gameVC release];
    if(indexPath.row != 0) {
        TomasWorld* world = (TomasWorld*)gameVC->currentScene;
        GameObject* obj = [levelData->saveBody objectAtIndex:indexPath.row - 1];
        b2PolygonShape* ps = (b2PolygonShape*)obj->shape;
        world->tomas->body->SetTransform(b2Vec2(ps->GetVertex(0).x,ps->GetVertex(0).y), 0);
        [world->tomas save];
        [world->levelData save];
    }
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
