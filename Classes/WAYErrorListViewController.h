

@interface WAYErrorListViewController : UITableViewController {
    NSArray *errors;
}
// An erray of NSDictionaries with WAYReasonKey, WAYErrorKey and WAYPhoneKey
@property (nonatomic, retain) NSArray *errors;

@end
