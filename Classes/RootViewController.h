

@class DetailViewController;

@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate, ABPeoplePickerNavigationControllerDelegate> {
    
    DetailViewController *detailViewController;
    
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    
    ABPeoplePickerNavigationController *peoplePicker;
}

@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
@property (nonatomic, retain) ABPeoplePickerNavigationController *peoplePicker;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)insertNewObject:(id)sender;

@end
