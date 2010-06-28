#import "RootViewController.h"
#import "DetailViewController.h"
#import "WAYDetailContactViewController.h"
#import "WAYEditContactViewController.h"
#import "AddressBookAdditions.h"
#import "Contact.h"


@interface RootViewController () 
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end


@implementation RootViewController

@synthesize detailViewController;
@synthesize fetchedResultsController;
@synthesize managedObjectContext;
@synthesize peoplePicker;

- (void)dealloc {
    
    [detailViewController release];
    [fetchedResultsController release];
    [managedObjectContext release];
    [peoplePicker release];
    
    [super dealloc];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);

    NSError *error = nil;
    // TODO: deal with error
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}


- (void)viewDidUnload {
    self.peoplePicker = nil;
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
 */
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
 */
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
 */

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.    
    return YES;
}


#pragma mark -
#pragma mark Add a new object

- (void)insertNewObject:(id)sender {
    [self presentModalViewController:self.peoplePicker animated:YES];
}


#pragma mark -
#pragma mark Table view data source

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Contact *contact = [fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = contact.name;
    cell.detailTextLabel.text = [[contact.phones anyObject] valueForKey:@"phone"];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ContactCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        
//        // Delete the managed object.
//        NSManagedObject *objectToDelete = [fetchedResultsController objectAtIndexPath:indexPath];
//        if (detailViewController.detailItem == objectToDelete) {
//            detailViewController.detailItem = nil;
//        }
//        
//        NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
//        [context deleteObject:objectToDelete];
//        
//        NSError *error;
//        if (![context save:&error]) {
//            /*
//             Replace this implementation with code to handle the error appropriately.
//             
//             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
//             */
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
//    }   
//}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
       
}


#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                managedObjectContext:managedObjectContext 
                                                                                                  sectionNameKeyPath:nil 
                                                                                                           cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
    
    return fetchedResultsController;

}    


#pragma mark -
#pragma mark Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


#pragma mark -
#pragma mark ABPeoplePickerNavigationController

- (ABPeoplePickerNavigationController *)peoplePicker {
    
    if (peoplePicker == nil) {
        peoplePicker = [ABPeoplePickerNavigationController new];
        peoplePicker.peoplePickerDelegate = self;
        peoplePicker.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [peoplePicker popToRootViewControllerAnimated:NO];
    return peoplePicker;
}


- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)aPeoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    ABRecordID recordID = ABRecordGetRecordID(person);
    
    // Check that selected user doesn't exist in contacts list
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Contact" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"recordID == %d", recordID]];
    NSArray *contacts = [managedObjectContext executeFetchRequest:request error:nil];
    [request release];
    if (![contacts count]) {
        // Create new Contact
        NSString *name = (NSString *)ABRecordCopyCompositeName(person);
        NSArray *possibleTwitterAccounts = CollectUrlsThatContainString(person, (CFStringRef)@"twitter.com/");
        NSString *twitterAccount = nil;
        if ([possibleTwitterAccounts count]) {
            twitterAccount = [possibleTwitterAccounts lastObject];
        }
        NSArray *mobilePhones = CollectMobilePhones(person);
        NSMutableSet *phones = [[NSMutableSet alloc] init];
        for (NSString *phone in mobilePhones) {
            NSManagedObject *mobilePhone = [NSEntityDescription insertNewObjectForEntityForName:@"Phone" inManagedObjectContext:managedObjectContext];
            [mobilePhone setValue:phone forKey:@"phone"];
            [phones addObject:mobilePhone];
        }
        Contact *contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:managedObjectContext];
        contact.name = name;
        contact.recordID = [NSNumber numberWithInt:recordID];
        contact.twitter = twitterAccount;
        contact.phones = phones;
        [name release];
        [phones release];
        
        WAYAddNewContactViewController *controller = [[WAYAddNewContactViewController alloc] initWithStyle:UITableViewStyleGrouped];
        controller.contact = contact;
        controller.delegate = self;
        [aPeoplePicker pushViewController:controller animated:YES];
        [controller release];   
    }
    else {
        WAYEditContactViewController *controller = [[WAYEditContactViewController alloc] initWithStyle:UITableViewStyleGrouped];
        controller.contact = [contacts lastObject];
        [aPeoplePicker pushViewController:controller animated:YES];
        [controller release];
    }

    
    return NO;
}


- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person 
                                property:(ABPropertyID)property 
                              identifier:(ABMultiValueIdentifier)identifier 
{
    return NO;
}


- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark WAYAddNewContactViewControllerDelegate

- (void)addNewContactViewControllerDidDone:(WAYAddNewContactViewController *)controller {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

@end
