#import "WAYMapViewController.h"
#import "WAYRootViewController.h"
#import "WAYErrorListViewController.h"
#import "WAYErrorMessageControl.h"
#import "WAYDataSyncer.h"
#import "Phone.h"
#import "Contact.h"

// This constant is used when centerAnnotations method is called. You can increase this value to decrease zoom level
static const float kSpanDelta = 1.15f;

@interface WAYMapViewController (/* Private stuff here */)

- (void)_updateAnnotationsFromNotification:(NSNotification *)notification;
- (void)_managedObjectDidSave:(NSNotification *)notification;
- (void)_placeAnnotations;
- (void)_handleOASError:(NSNotification *)notification;
- (void)_updateErrorView;

@end

@implementation WAYMapViewController
@synthesize contactsPopoverController;
@synthesize errorsPopoverController;
@synthesize toolbar;
@synthesize mapView;
@synthesize errorMessage;
@synthesize errorMessageBarButtonItem;
@synthesize updateContactItem;
@synthesize rootViewController;
@synthesize managedObjectContext;
@synthesize contact;
@synthesize errors;

- (NSUInteger)countOfErrors {
    return [errors count];
}


- (NSDictionary *)objectInErrorsAtIndex:(NSUInteger)index {
    return [errors objectAtIndex:index];
}


- (void)insertObject:(NSDictionary *)object inErrorsAtIndex:(NSUInteger)index {
    [errors insertObject:object atIndex:index];
}


- (void)removeObjectFromErrorsAtIndex:(NSUInteger)index {
    [errors removeObjectAtIndex:index];
}


- (void)dealloc {
	
    [contactsPopoverController release];
    [errorsPopoverController release];
    [toolbar release];
    [mapView release];
    [errorMessage release];
    [errorMessageBarButtonItem release];
    [updateContactItem release];
    [managedObjectContext release];
    [contact release];
    [errors release];
	[super dealloc];
}	


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"keyPath");
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(_managedObjectDidSave:) 
                                                 name:NSManagedObjectContextDidSaveNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_handleOASError:)
                                                 name:WAYRetrivePhoneLocationErrorNotification
                                               object:[WAYDataSyncer sharedInstance]];
    [self addObserver:self forKeyPath:@"errors" options:NSKeyValueObservingOptionNew context:NULL];
    mapView.delegate = self;
    errors = [NSMutableArray new];
}


- (void)viewDidUnload {
    [super viewDidUnload];
	self.contactsPopoverController = nil;
    self.errorsPopoverController = nil;
    self.mapView = nil;
    self.errorMessage = nil;
    self.errorMessageBarButtonItem = nil;
    self.updateContactItem = nil;
    [errors release];
    errors = nil;
    mapView.delegate = nil;
    [self removeObserver:self forKeyPath:@"errors"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark -
#pragma mark UISplitViewControllerDelegate

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    
    barButtonItem.title = rootViewController.title;
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.contactsPopoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.contactsPopoverController = nil;
}


- (void)splitViewController:(UISplitViewController*)svc popoverController:(UIPopoverController*)pc willPresentViewController:(UIViewController *)aViewController {
    // Dismiss errors popover if is is presented
    [errorsPopoverController dismissPopoverAnimated:YES];
}


#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark IBAction

- (IBAction)insertNewObject:(id)sender {	
	[rootViewController insertNewObject:sender];	
}


- (IBAction)changeMapViewType:(UISegmentedControl *)sender {
    mapView.mapType = sender.selectedSegmentIndex;
}


- (IBAction)updateContact:(id)sender {
    if (contact != nil) {
        [[WAYDataSyncer sharedInstance] syncAllLocationsForContact:[contact objectID]];
    }
}


- (IBAction)showErrorList:(id)sender {
    
    if (self.errorsPopoverController == nil) {
        WAYErrorListViewController *controller = [[WAYErrorListViewController alloc] initWithStyle:UITableViewStylePlain];
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:controller];
        [controller release];
        self.errorsPopoverController = popover;
        [popover release];
    }
    WAYErrorListViewController *controller = (WAYErrorListViewController *)errorsPopoverController.contentViewController;
    controller.errors = errors;
    // Calc popover height to display all errors
    // If height is more than 600 points, reset it to 600 points
    CGFloat height = controller.tableView.rowHeight * [errors count];
    if (height > 600.0f) {
        height = 600.0f;
    }
    errorsPopoverController.popoverContentSize = CGSizeMake(320.0, height);
    // Dismiss contacts popover if it is presented
    [contactsPopoverController dismissPopoverAnimated:YES];
    [errorsPopoverController presentPopoverFromBarButtonItem:errorMessageBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}


#pragma mark -
#pragma mark MKMapViewDelegate

//- (void)mapView:(MKMapView *)aMapView didAddAnnotationViews:(NSArray *)views {
//    
//    CGRect visibleRect = [aMapView annotationVisibleRect];
//    
//    for (MKAnnotationView *view in views) {
//        CGRect endFrame = view.frame;
//        CGRect startFrame = endFrame;
//        startFrame.origin.y = visibleRect.origin.y - startFrame.size.height;
//        view.frame = startFrame;
//        
//        [UIView beginAnimations:@"drop" context:NULL];
//        [UIView setAnimationDelay:0.0f];
//        [UIView setAnimationDuration:0.3f];
//        view.frame = endFrame;
//        [UIView commitAnimations];
//    }
//}


- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    static NSString *annotationViewIdentifier = @"annotationViewIdentifier";
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[aMapView dequeueReusableAnnotationViewWithIdentifier:annotationViewIdentifier];
    if (annotationView == nil) {
        annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationViewIdentifier] autorelease];
        annotationView.animatesDrop = YES;
        annotationView.canShowCallout = YES;
    }
    
//    if ([((Phone*)annotation).contact.twitter length]) {
//        UIImage *twitterImage = [UIImage imageNamed:@"twitter.png"];
//        UIButton *twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [twitterButton setImage:twitterImage forState:UIControlStateNormal];
//        CGRect frame = twitterButton.frame;
//        frame.size = CGSizeMake(18, 18);
//        twitterButton.frame = frame;
//        annotationView.rightCalloutAccessoryView = twitterButton;
//    }
    
    return annotationView;
}


#pragma mark -
#pragma mark Work with map

- (void)setContact:(Contact *)newContact {
    
    // Remove all errors and update errorMessage view
    [errors removeAllObjects];
    [self _updateErrorView];
    [[WAYDataSyncer sharedInstance] cancellAllOperations:NO];
    
    if (contact != newContact) {
        [newContact retain];
        [contact release];
        contact = newContact;
        // If newContact differs from contact, remove all annotations
        [mapView removeAnnotations:mapView.annotations];
        if (newContact != nil) {
            [self _placeAnnotations];
        }
    }
    
    if (contact != nil) {
        self.updateContactItem.enabled = YES;
        [[WAYDataSyncer sharedInstance] syncAllLocationsForContact:[contact objectID]];
    }
    else {
        self.updateContactItem.enabled = NO;
    }
}


- (void)centerAnnotaions {
    
    NSArray *annotations = mapView.annotations;
    if ([annotations count] == 1) {
        // Center on annotation and zoom to street level
        Phone *phone = [annotations lastObject];
        MKCoordinateRegion region;
        region.center.latitude = [phone.latitude floatValue];
        region.center.longitude = [phone.longitude floatValue];
        region.span.latitudeDelta = 0.0039;
        region.span.longitudeDelta = 0.0034;
        [mapView setRegion:region animated:YES];
    }
    else if ([mapView.annotations count] > 1) {
        // Calc region to display all pins
        Phone *anyPhone = [annotations lastObject];
        float topLatitude = [anyPhone.latitude floatValue], leftLongitude = [anyPhone.longitude floatValue],
        bottomLatitude = topLatitude, rightLongitude = leftLongitude;
        for (Phone *phone in annotations) {
            float phoneLatitude = [phone.latitude floatValue];
            float phoneLongitude = [phone.longitude floatValue];
            NSLog(@"latitude: %f\nlongitude: %f\n\n", phoneLatitude, phoneLongitude);
            if (phoneLatitude < topLatitude) {
                topLatitude = phoneLatitude;
            }
            else if (phoneLatitude > bottomLatitude) {
                bottomLatitude = phoneLatitude;
            }
            
            if (phoneLongitude < leftLongitude) {
                leftLongitude = phoneLongitude;
            }
            else if (phoneLongitude > rightLongitude) {
                rightLongitude = phoneLongitude;
            }
        }
        MKCoordinateRegion region;
        region.center.latitude = topLatitude + (bottomLatitude - topLatitude) / 2;
        region.center.longitude = leftLongitude + (rightLongitude - leftLongitude) / 2;
        region.span.latitudeDelta = (bottomLatitude - topLatitude) * kSpanDelta; // *kSpanDelta to make all pins visible
        region.span.longitudeDelta = (rightLongitude - leftLongitude) * kSpanDelta;
        [mapView setRegion:region animated:YES];
    }
}


- (void)_updateAnnotationsFromNotification:(NSNotification *)notification {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class = %@", [Phone class]];
    
    NSArray *deletedObjects = [[[[[notification userInfo] objectForKey:NSDeletedObjectsKey] allObjects] filteredArrayUsingPredicate:predicate] valueForKey:@"objectID"];
    NSMutableArray *annotationsToDelete = [NSMutableArray arrayWithCapacity:[deletedObjects count]];
    for (NSManagedObjectID *objectID in deletedObjects) {
        for (Phone *phone in mapView.annotations) {
            if ([objectID isEqual:[phone objectID]]) {
                [annotationsToDelete addObject:phone];
            }
        }
    }
    [mapView removeAnnotations:annotationsToDelete];
    [self _placeAnnotations];
}


- (void)_managedObjectDidSave:(NSNotification *)notification {
    [self performSelectorOnMainThread:@selector(_updateAnnotationsFromNotification:) withObject:notification waitUntilDone:NO];
}


- (void)_placeAnnotations {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Phone" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"(timestamp > 0) && (contact = %@)", contact]];
    NSArray *phonesToInsert = [managedObjectContext executeFetchRequest:request error:nil];
    [request release];
    [mapView addAnnotations:phonesToInsert];
}


- (void)_handleOASError:(NSNotification *)notification {
    if ([NSThread currentThread] != [NSThread mainThread]) {
        [self performSelectorOnMainThread:@selector(_handleOASError:) withObject:notification waitUntilDone:NO];
    }
    else {
        NSDictionary *userInfo = [notification userInfo];
        // Check that error was occured with phone that contact has.
        if ([[contact valueForKeyPath:@"phones.phone"] containsObject:[userInfo objectForKey:WAYPhoneKey]]) {
            NSAssert(errors != nil, @"You forget to initialize _errors array");
            [errors addObject:userInfo];
            [self _updateErrorView];
        }
    }
}


- (void)_updateErrorView {
    if ([errors count]) {
        NSDictionary *error = [errors objectAtIndex:0];
        errorMessage.textLabel.text = [error objectForKey:WAYReasonKey];
        errorMessage.hidden = NO;
    }
    else {
        errorMessage.hidden = YES;
    }

}

@end
