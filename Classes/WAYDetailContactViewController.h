

@class WAYEditableTableViewCell;

@protocol WAYDetailContactViewControllerDelegate;

@interface WAYDetailContactViewController : UITableViewController <UITextFieldDelegate> {
    ABRecordID personID;
    id<WAYDetailContactViewControllerDelegate> delegate;
@private
    NSMutableArray *_data[2];
    NSMutableArray *_twitterUrls;
    NSMutableArray *_mobilePhones;
    NSIndexPath *_editingRowIndexPath;
    UITextField *_editingTextField;
}

@property (nonatomic) ABRecordID personID;
@property (nonatomic, assign) id<WAYDetailContactViewControllerDelegate> delegate;

@end

@protocol WAYDetailContactViewControllerDelegate

- (void)detailContactViewController:(WAYDetailContactViewController *)controller 
             didDoneWithTwitterURL:(NSString *)twitterURL
                       phoneNumbers:(NSArray *)phoneNumbers;
                                     
@end
