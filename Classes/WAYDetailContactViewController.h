

@protocol WAYDetailContactViewControllerDelegate;

/*!
 * @class WAYDetailContactViewController
 * @abstract It allows user to select twitter account and phone numbers that are generated from user address book. 
 * It is also possible to modify list by adding new phones and accounts.
 * @discussion View is just UITableView with two sections: one for twitter account and one for phone numbers.
 * Controller adds Done button to the navigationItem. After this button is pressed controller sends message to its delegate that should adopt
 * WAYDetailContactViewControllerDelegate delegate to inform it about selected twitter account and phone numbers.
 * Only one twitter account can be set in the same time. However it is possible to select multiple phone numbers.
 */
@interface WAYDetailContactViewController : UITableViewController <UITextFieldDelegate> {
    ABRecordID personID;
    id<WAYDetailContactViewControllerDelegate> delegate;
@private
    NSMutableArray *_data[2];
    NSMutableArray *_twitterAccounts;
    NSMutableArray *_mobilePhones;
    NSIndexPath *_editingRowIndexPath;
    UITextField *_editingTextField;
    NSUInteger _selectedTwitterAccount;
}

/*!
 * @property personID
 * @abstract personID is used to collect twitter accounts and phone numbers from user's address book.
 * @discussion You must set this method before you add controller to the controllers stack.
 */
@property (nonatomic) ABRecordID personID;

/*!
 * @property delegate
 * @abstract delegate of the controller
 */
@property (nonatomic, assign) id<WAYDetailContactViewControllerDelegate> delegate;

@end

/*!
 * @protocol WAYDetailContactViewControllerDelegate
 * @abstract This protocol should be adopted by a delegate in order to receive messages from the controller.
 */
@protocol WAYDetailContactViewControllerDelegate

/*!
 * @method detailContactViewController:didDoneWithTwitterURL:phoneNumbers:
 * @abstract Tells the delegate about selected twitter account and phone numbers after user taps Done button.
 * @param controller Controller that sends the message.
 * @param twitterAccount Selected twitter account. May be nil.
 * @param phoneNumbers NSArray that contains selected phone numbers. May be empty.
 */
- (void)detailContactViewController:(WAYDetailContactViewController *)controller 
             didDoneWithTwitterAccount:(NSString *)twitterAccount
                       phoneNumbers:(NSArray *)phoneNumbers;
                                     
@end
