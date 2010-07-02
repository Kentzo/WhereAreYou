#import "WAYMapViewController.h"
#import "RootViewController.h"
#import "WAYDataSyncer.h"
#import "Phone.h"
#import "Contact.h"


static const float updateInterval = 60.0f;

@interface WAYMapViewController (/* Private stuff here */)

- (void)_updateAnnotationsFromNotification:(NSNotification *)notification;
- (void)_managedObjectDidSave:(NSNotification *)notification;
- (void)_placeAnnotations;
- (void)_centerAnnotations;

@end

@implementation WAYMapViewController
@synthesize popoverController;
@synthesize toolbar;
@synthesize mapView;
@synthesize updateContactItem;
@synthesize managedObjectContext;
@synthesize rootViewController;
@synthesize contact;


- (void)dealloc {
	
    [popoverController release];
    [toolbar release];
    [mapView release];
    [updateContactItem release];
    [managedObjectContext release];
    [contact release];
	[super dealloc];
}	


#pragma mark -
#pragma mark View lifecycle


 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(_managedObjectDidSave:) 
                                                 name:NSManagedObjectContextDidSaveNotification 
                                               object:nil];
    mapView.delegate = self;
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	self.popoverController = nil;
    self.mapView = nil;
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
    self.popoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = nil;
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
    
    if ([((Phone*)annotation).contact.twitter length]) {
        UIImage *twitterImage = [UIImage imageNamed:@"twitter.png"];
        UIButton *twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [twitterButton setImage:twitterImage forState:UIControlStateNormal];
        CGRect frame = twitterButton.frame;
        frame.size = CGSizeMake(18, 18);
        twitterButton.frame = frame;
        annotationView.rightCalloutAccessoryView = twitterButton;
    }
    
    return annotationView;
}


#pragma mark -
#pragma mark Work with map

- (void)setContact:(Contact *)newContact {
    
    [newContact retain];
    [contact release];
    contact = newContact;
    [mapView removeAnnotations:mapView.annotations];
    
    [[WAYDataSyncer sharedInstance] cancellAllOperations:NO];
    
    if (contact != nil) {
        [self _placeAnnotations];
        [self _centerAnnotations];
        [[WAYDataSyncer sharedInstance] syncAllLocationsForContact:[contact objectID]];
        self.updateContactItem.enabled = YES;
        
    }
    else {
        self.updateContactItem.enabled = NO;
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

- (void)_centerAnnotations {
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
        region.center.latitude = topLatitude + (bottomLatitude - topLatitude)/2;
        region.center.longitude = leftLongitude + (rightLongitude - leftLongitude)/2;
        region.span.latitudeDelta = bottomLatitude - topLatitude;
        region.span.longitudeDelta = rightLongitude - leftLongitude;
        [mapView setRegion:region animated:YES];
    }    
}

@end
