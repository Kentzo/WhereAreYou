#import "WAYAddNewContactViewController.h"
#import "Contact.h"


@interface WAYDetailContactViewController (/* Private stuff here */)

- (void)_done:(id)sender;
- (void)_managedObjectContextDidChanged:(NSNotification *)notification;

@end

@implementation WAYAddNewContactViewController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                              target:self 
                                                                              action:@selector(_done:)];
    self.navigationItem.rightBarButtonItem = doneItem;
    [doneItem release];
    self.editing = YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.rightBarButtonItem.enabled = [contact validateForUpdate:nil];
    _isDone = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(_managedObjectContextDidChanged:) 
                                                 name:NSManagedObjectContextObjectsDidChangeNotification 
                                               object:contact.managedObjectContext];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (!_isDone) {
        // Delete just created contact when view disappears 
        [contact.managedObjectContext deleteObject:contact];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:NSManagedObjectContextObjectsDidChangeNotification 
                                                  object:contact.managedObjectContext];
}


- (void)_done:(id)sender {
    NSError *error = nil;
    if (![contact.managedObjectContext save:&error]) {
        NSLog(@"%@", error);
    }
    else {
        _isDone = YES;
    }    
    [delegate addNewContactViewControllerDidDone:self];
}


- (void)_managedObjectContextDidChanged:(NSNotification *)notification {
    self.navigationItem.rightBarButtonItem.enabled = [contact validateForUpdate:nil];
}

@end
