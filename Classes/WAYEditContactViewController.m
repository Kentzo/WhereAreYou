#import "WAYEditContactViewController.h"
#import "Contact.h"


@interface WAYEditContactViewController (/* Private stuff here  */)
- (void)_managedObjectContextDidChanged:(NSNotification *)notification;
@end

@implementation WAYEditContactViewController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.rightBarButtonItem.enabled = [contact validateForUpdate:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(_managedObjectContextDidChanged:) 
                                                 name:NSManagedObjectContextObjectsDidChangeNotification 
                                               object:contact.managedObjectContext];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:NSManagedObjectContextObjectsDidChangeNotification 
                                                  object:contact.managedObjectContext];
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    if (editing) {
        [self.navigationItem setHidesBackButton:YES animated:YES];
        self.navigationItem.leftBarButtonItem.enabled = NO;
    }
    else {
        NSError *error = nil;
        if (![contact.managedObjectContext save:&error]) {
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
        [self.navigationItem setHidesBackButton:NO animated:YES];
        self.navigationItem.leftBarButtonItem.enabled = YES;
        [delegate editContactViewControllerDidDone:self];
    }
}


- (void)_managedObjectContextDidChanged:(NSNotification *)notification {
    self.navigationItem.rightBarButtonItem.enabled = [contact validateForUpdate:nil] && [contact validatePhonesForUpdate:nil];
}

@end
