#import "WAYAddNewContactViewController.h"
#import "WAYEditContactViewController.h"


@class WAYMapViewController;

@interface WAYRootViewController : UITableViewController <NSFetchedResultsControllerDelegate, ABPeoplePickerNavigationControllerDelegate, WAYAddNewContactViewControllerDelegate> {
    
    WAYMapViewController *mapViewController;
    
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    
    ABPeoplePickerNavigationController *peoplePicker;
}

@property (nonatomic, retain) IBOutlet WAYMapViewController *mapViewController;
@property (nonatomic, retain) ABPeoplePickerNavigationController *peoplePicker;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)insertNewObject:(id)sender;

@end
