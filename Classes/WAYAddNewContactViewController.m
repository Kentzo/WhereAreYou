#import "WAYAddNewContactViewController.h"
#import "Contact.h"


@interface WAYDetailContactViewController ()

- (void)_done:(id)sender;

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
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (!_isDone) {
        // Delete just created contact when view disappears 
        [contact.managedObjectContext deleteObject:contact];
    }
}


- (void)insertPhones:(NSArray *)phones atIndexes:(NSIndexSet *)indexSet {
    [super insertPhones:phones atIndexes:indexSet];
    self.navigationItem.rightBarButtonItem.enabled = [contact validateForUpdate:nil];
}


- (void)removePhonesAtIndexes:(NSIndexSet *)indexSet {
    [super removePhonesAtIndexes:indexSet];
    self.navigationItem.rightBarButtonItem.enabled = [contact validateForUpdate:nil];
}


- (void)setText:(NSString *)text forRowAtIndexPath:(NSIndexPath *)indexPath {
    [super setText:text forRowAtIndexPath:indexPath];
    self.navigationItem.rightBarButtonItem.enabled = [contact validateForUpdate:nil];
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

@end
