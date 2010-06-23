

@protocol WAYDetailContactViewControllerDelegate;

@interface WAYDetailContactViewController : UITableViewController <UITextFieldDelegate> {
    ABRecordID personID;
    id<WAYDetailContactViewControllerDelegate> delegate;
    NSMutableArray *twitterUrls;
    NSMutableArray *mobilePhones;
@private
    NSMutableArray *_data[2];
}

@property (nonatomic) ABRecordID personID;
@property (nonatomic, assign) id<WAYDetailContactViewControllerDelegate> delegate;

@property (nonatomic, retain) NSMutableArray *twitterUrls;
@property (nonatomic, retain) NSMutableArray *mobilePhones;

// Make properties observable
- (NSUInteger)countOfTwitterUrls;
- (id)objectInTwitterUrlsAtIndex:(NSUInteger)index;
- (void)insertObject:(NSMutableDictionary *)object inTwitterUrlsAtIndex:(NSUInteger)index;
- (void)removeObjectFromTwitterUrlsAtIndex:(NSUInteger)index;
- (void)replaceObjectInTwitterUrlsAtIndex:(NSUInteger)index withObject:(NSMutableDictionary *)object;

- (NSUInteger)countOfMobilePhones;
- (id)objectInMobilePhonesAtIndex:(NSUInteger)index;
- (void)insertObject:(NSMutableDictionary *)object inMobilePhonesAtIndex:(NSUInteger)index;
- (void)removeObjectFromMobilePhonesAtIndex:(NSUInteger)index;
- (void)replaceObjectInMobilePhonesAtIndex:(NSUInteger)index withObject:(NSMutableDictionary *)object;

@end

@protocol WAYDetailContactViewControllerDelegate

- (void)detailContactViewController:(WAYDetailContactViewController *)controller 
             didDoneWithTwitterURLs:(NSArray *)twitterURLs
                       phoneNumbers:(NSArray *)phoneNumbers;
                                     
@end