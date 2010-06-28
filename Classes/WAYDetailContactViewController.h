

@class Contact;

@interface WAYDetailContactViewController : UITableViewController <UITextFieldDelegate> {
    Contact *contact;
	NSNumberFormatter *phoneFormatter;
@private
    NSIndexPath *_editingRowIndexPath;
    NSIndexPath *_currentIndexPath;
    UITextField *_editingTextField;
    NSMutableArray *_contactMobilePhones;
}

@property (nonatomic, retain) Contact *contact;
@property (nonatomic, retain) NSNumberFormatter *phoneFormatter;

- (void)setText:(NSString *)text forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)insertPhones:(NSArray *)phones atIndexes:(NSIndexSet *)indexSet;
- (void)removePhonesAtIndexes:(NSIndexSet *)indexSet;

@end
