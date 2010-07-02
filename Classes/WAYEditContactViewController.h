#import "WAYDetailContactViewController.h"


@protocol WAYEditContactViewControllerDelegate;

@interface WAYEditContactViewController : WAYDetailContactViewController {
    id<WAYEditContactViewControllerDelegate> delegate;
}

@property (nonatomic, assign) id<WAYEditContactViewControllerDelegate> delegate;

@end

@protocol WAYEditContactViewControllerDelegate

- (void)editContactViewControllerDidDone:(WAYEditContactViewController *)controller;

@end
