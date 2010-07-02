

@class RootViewController, Phone, Contact;

@interface WAYMapViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate, MKMapViewDelegate> {
    
    UIPopoverController *popoverController;
    UIToolbar *toolbar;
    MKMapView *mapView;
    RootViewController *rootViewController;
    NSManagedObjectContext *managedObjectContext;
    Contact *contact;
    UIBarButtonItem *updateContactItem;
}

@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *updateContactItem;
@property (nonatomic, assign) IBOutlet RootViewController *rootViewController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Contact *contact;

- (IBAction)insertNewObject:(id)sender;
- (IBAction)changeMapViewType:(UISegmentedControl *)sender;
- (IBAction)updateContact:(id)sender;

@end
