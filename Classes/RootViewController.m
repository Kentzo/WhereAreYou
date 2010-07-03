#import "RootViewController.h"
#import "WAYMapViewController.h"
#import "WAYDetailContactViewController.h"
#import "WAYEditContactViewController.h"
#import "AddressBookAdditions.h"
#import "Contact.h"
#import "Phone.h"


@interface RootViewController () 
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)_stopEditingContact;
@end


@implementation RootViewController

@synthesize mapViewController;
@synthesize fetchedResultsController;
@synthesize managedObjectContext;
@synthesize peoplePicker;

- (void)dealloc {
    
    [mapViewController release];
    [fetchedResultsController release];
    [managedObjectContext release];
    [peoplePicker release];
    
    [super dealloc];
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    if (editing) {
        mapViewController.contact = nil;
    }
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.    
    return YES;
}

#pragma mark -
#pragma mark Add a new object

- (void)insertNewObject:(id)sender {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    mapViewController.contact = nil;
    [self presentModalViewController:self.peoplePicker animated:YES];
}


#pragma mark -
#pragma mark Table view data source

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    static ABAddressBookRef addressBook = NULL;
    if (addressBook == NULL) {
        addressBook = ABAddressBookCreate();
    }
    Contact *contact = [fetchedResultsController objectAtIndexPath:indexPath];
    ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, [contact.recordID intValue]);
    if (person != NULL && ABPersonHasImageData(person)) {
        NSData *data = (NSData *)ABPersonCopyImageData(person);
        UIImage *image = [[UIImage alloc] initWithData:data];
        cell.imageView.image = image;
        [image release];
        [data release];
    }
    cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    cell.textLabel.text = contact.name;
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


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the managed object.
        NSManagedObject *objectToDelete = [fetchedResultsController objectAtIndexPath:indexPath];
        
        NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
        [context deleteObject:objectToDelete];
        
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
            NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
            if(detailedErrors != nil && [detailedErrors count] > 0) {
                for(NSError* detailedError in detailedErrors) {
                    NSLog(@"  DetailedError: %@", [detailedError userInfo]);
                }
            }
            else {
                NSLog(@"  %@", [error userInfo]);
            }
        }
    }   
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Contact *contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
    mapViewController.contact = contact;
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (self.editing) {
        WAYEditContactViewController *controller = [[WAYEditContactViewController alloc] initWithStyle:UITableViewStyleGrouped];
        controller.contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered 
                                                                        target:self action:@selector(_stopEditingContact)];
        controller.navigationItem.leftBarButtonItem = cancelButton;
        [cancelButton release];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentModalViewController:navController animated:YES];
        [controller release];
        [navController release];
    }
    else {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        Contact *contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
        mapViewController.contact = contact;
        [mapViewController centerAnnotaions];
    }
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
        for (NSNumber *phone in mobilePhones) {
            Phone *mobilePhone = [NSEntityDescription insertNewObjectForEntityForName:@"Phone" inManagedObjectContext:managedObjectContext];
            mobilePhone.phone = phone;
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
        // Use existing
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


- (void)_stopEditingContact {
    [self dismissModalViewControllerAnimated:YES];
}

@end
