#import "WAYEditContactViewController.h"


@implementation WAYEditContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.rightBarButtonItem.enabled = [contact validateForUpdate:nil];
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

@end
