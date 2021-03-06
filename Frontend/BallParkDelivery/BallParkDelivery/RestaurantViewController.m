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
@synthesize restaurants,stadiumName,cart;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize tableViewCell;


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

    UIBarButtonItem *shoppingCart = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"shoppingcart.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(checkout)];
    self.navigationItem.rightBarButtonItem = shoppingCart;
    
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


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath 
{
    return 99;
}

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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"RestaurantCell" owner:self options:nil];
        cell = tableViewCell;
        self.tableViewCell = nil;
    }

    

    // Configure the cell.
    ((UILabel *)[cell viewWithTag:2]).text = [[restaurants objectAtIndex:[indexPath row]] 
                           valueForKey:@"restaurant_name"];
    
    NSString *currentURL = [[restaurants objectAtIndex:[indexPath row]]valueForKey:@"logo_url"];
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
    {
        NSManagedObject *object = [results objectAtIndex:0];
        imageData = [object valueForKey:@"image"];
    }
        
    ((UIImageView *)[cell viewWithTag:1]).image = [UIImage imageWithData:imageData];
    ((UIImageView *)[cell viewWithTag:1]).contentMode = UIViewContentModeScaleAspectFit;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    
    return cell;
}

-(void) checkout
{
    CartViewController *cartVC = [[CartViewController alloc] init];
    cartVC.cart = self.cart;
    cartVC.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cartVC];
    [self presentViewController:nav animated:YES completion:nil];
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
