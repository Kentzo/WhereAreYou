

@class Contact;

@interface WAYDetailContactViewController : UITableViewController <UITextFieldDelegate> {
    Contact *contact;
	PhoneNumberFormatter *phoneFormatter;
@private
    NSIndexPath *_editingRowIndexPath;
    NSIndexPath *_currentIndexPath;
    UITextField *_editingTextField;
    NSMutableArray *_contactMobilePhones;
    NSCharacterSet *_nonDecimalDigits;
}

// Must be set before view appears and must be not changed before view disappears
@property (nonatomic, retain) Contact *contact;
@property (nonatomic, retain) PhoneNumberFormatter *phoneFormatter;

- (void)insertPhones:(NSArray *)phones atIndexes:(NSIndexSet *)indexSet;
- (void)removePhonesAtIndexes:(NSIndexSet *)indexSet;

@end
