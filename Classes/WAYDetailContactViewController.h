

@protocol WAYDetailContactViewControllerDelegate;

@interface WAYDetailContactViewController : UITableViewController <UITextFieldDelegate> {
    ABRecordID personID;
    id<WAYDetailContactViewControllerDelegate> delegate;
@private
    NSMutableArray *_data[2];
    NSMutableArray *_twitterUrls;
    NSMutableArray *_mobilePhones;
}

@property (nonatomic) ABRecordID personID;
@property (nonatomic, assign) id<WAYDetailContactViewControllerDelegate> delegate;

@end

@protocol WAYDetailContactViewControllerDelegate

- (void)detailContactViewController:(WAYDetailContactViewController *)controller 
             didDoneWithTwitterURLs:(NSArray *)twitterURLs
                       phoneNumbers:(NSArray *)phoneNumbers;
                                     
@end