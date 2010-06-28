#import "WAYDetailContactViewController.h"


@protocol WAYAddNewContactViewControllerDelegate;

@interface WAYAddNewContactViewController : WAYDetailContactViewController {
    id<WAYAddNewContactViewControllerDelegate> delegate;
@private
    BOOL _isDone;
}

@property (nonatomic, assign) id<WAYAddNewContactViewControllerDelegate> delegate;

@end

@protocol WAYAddNewContactViewControllerDelegate

- (void)addNewContactViewControllerDidDone:(WAYAddNewContactViewController *)controller;

@end
