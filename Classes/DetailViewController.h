

@class RootViewController;

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate> {
    
    UIPopoverController *popoverController;
    UIToolbar *toolbar;
    MKMapView *mapView;

    RootViewController *rootViewController;
}

@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;

@property (nonatomic, assign) IBOutlet RootViewController *rootViewController;

- (IBAction)insertNewObject:(id)sender;
- (IBAction)changeMapViewType:(UISegmentedControl *)sender;

@end
