#import "OASAPIOperationDelegate.h"

// Allows you sync locations in asycnhronous way

@interface WAYDataSyncer : NSObject <OASAPIOperationDelegate> {
    NSManagedObjectContext *context;
    NSNumber *applId;
    NSString *applKey;
@private
    NSOperationQueue *_queue;
}

@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic, copy) NSNumber *applId;
@property (nonatomic, copy) NSString *applKey;

// Syncs locations for all phones
- (void)syncAllLocations;
// Syncs locations for all phones of a contact with contactId
- (void)syncAllLocationsForContact:(NSManagedObjectID *)contactId;
// Syncs location of a phone with phoneId
- (void)syncLocationForPhone:(NSManagedObjectID *)phoneId;
// Cancels all operations
- (void)cancellAllOperations:(BOOL)waitUntilDone;

@end

@interface WAYDataSyncer (Singleton)
// Returns WAYDataSyncer singleton
+ (WAYDataSyncer *)sharedInstance;

@end

extern NSString* const WAYRetrivePhoneLocationErrorNotification;
extern NSString* const WAYErrorKey;
extern NSString* const WAYReasonKey;
extern NSString* const WAYPhoneKey;
