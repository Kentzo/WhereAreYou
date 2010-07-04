

@class WAYRootViewController, Phone, Contact, WAYErrorMessageControl;

@interface WAYMapViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate, MKMapViewDelegate> {
    
    UIPopoverController *contactsPopoverController;
    UIPopoverController *errorsPopoverController;
    UIToolbar *toolbar;
    MKMapView *mapView;
    WAYErrorMessageControl *errorMessage;
    UIBarButtonItem *errorMessageBarButtonItem;
    UIBarButtonItem *updateContactItem;
    WAYRootViewController *rootViewController;
    
    NSManagedObjectContext *managedObjectContext;
    Contact *contact;
    NSMutableArray *errors;
}

@property (nonatomic, retain) UIPopoverController *contactsPopoverController;
@property (nonatomic, retain) UIPopoverController *errorsPopoverController;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet WAYErrorMessageControl *errorMessage;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *errorMessageBarButtonItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *updateContactItem;
@property (nonatomic, assign) IBOutlet WAYRootViewController *rootViewController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Contact *contact;
@property (nonatomic, readonly) NSArray *errors;

- (IBAction)insertNewObject:(id)sender;
- (IBAction)changeMapViewType:(UISegmentedControl *)sender;
- (IBAction)updateContact:(id)sender;
- (IBAction)showErrorList:(id)sender;

- (void)centerAnnotaions;

@end
