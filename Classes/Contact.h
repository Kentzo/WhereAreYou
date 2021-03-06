

@class Phone;

@interface Contact :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * recordID;
@property (nonatomic, retain) NSString * twitter;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* phones;

@end


@interface Contact (CoreDataGeneratedAccessors)
- (void)addPhonesObject:(Phone *)value;
- (void)removePhonesObject:(Phone *)value;
- (void)addPhones:(NSSet *)value;
- (void)removePhones:(NSSet *)value;

- (BOOL)validatePhonesForUpdate:(NSError **)error;

@end

