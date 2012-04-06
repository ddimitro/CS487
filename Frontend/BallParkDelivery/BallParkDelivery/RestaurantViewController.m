//
//  MasterViewController.m
//  BallParkDelivery
//
//  Created by Seth  Thompson on 4/2/12.
//  Copyright (c) 2012 Bradley University. All rights reserved.
//

#import "RestaurantViewController.h"

#import "MenuViewController.h"
#import "Model.h"
#import "CustomCell.h"
#import "CartViewController.h"

@implementation RestaurantViewController

@synthesize menuViewController = _menuViewController;
@synthesize restaurants,stadiumName,cart, currentURL;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Restaurants";
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] 
                                                initWithTitle:@"Cart" style:UIBarButtonItemStyleBordered target:self action:@selector(checkout)];

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
    [self.tableView reloadData];
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
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Fetched results controller

/*- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    // Set up the fetched results controller.
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Image" inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"url == %@",currentURL];
    
    [fetchRequest setPredicate:pred];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"url" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    
	     Replace this implementation with code to handle the error appropriately.
         
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	     
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    return __fetchedResultsController;
}    */



// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [restaurants count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    // Configure the cell.
    cell.textLabel.text = [[restaurants objectAtIndex:[indexPath row]] 
                           valueForKey:@"restaurant_name"];
    
    currentURL = [[restaurants objectAtIndex:[indexPath row]]valueForKey:@"logo_url"];
    NSFetchRequest *fetchrequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Image" inManagedObjectContext:self.managedObjectContext];
    [fetchrequest setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"url == %@",currentURL];
    [fetchrequest setPredicate:pred];
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchrequest error:nil];
    
    NSData *imageData;
    
    if (results == nil || ([results count]==0)) 
        imageData = [Model getImageFromURL:[[restaurants objectAtIndex:[indexPath row]]
                                                    valueForKey:@"logo_url"] inContext:self.managedObjectContext];
    else

        imageData = [[results objectAtIndex:0] data];
        
    cell.imageView.image = [UIImage imageWithData:imageData];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    return cell;
}

-(void) checkout
{
    CartViewController *cartVC = [[CartViewController alloc] init];
    cartVC.cart = self.cart;
    cartVC.delegate = self;
    [self presentViewController:cartVC animated:YES completion:nil];
}

-(void) orderPlaced:(id)sender
{
    [sender dismissViewControllerAnimated:YES completion:nil];
}

-(void) orderCancelled:(id)sender
{
    [sender dismissViewControllerAnimated:YES completion:nil];
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
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.menuViewController) {
        self.menuViewController = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
    }
    self.menuViewController.restaurantName = [[restaurants objectAtIndex:indexPath.row]objectForKey:@"restaurant_name"];
    self.menuViewController.menuList = [Model getMenuFromStadiumName:stadiumName andRestaurantName:
                                        [[restaurants objectAtIndex:indexPath.row]objectForKey:
                                         @"restaurant_name"]];
    self.menuViewController.stadiumName = self.stadiumName;
    self.menuViewController.cart = self.cart;
    self.menuViewController.navigationItem.rightBarButtonItem = self.navigationItem.rightBarButtonItem;
    self.menuViewController.managedObjectContext = self.managedObjectContext;
    [self.navigationController pushViewController:self.menuViewController animated:YES];
}

@end
