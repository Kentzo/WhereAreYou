#import "OASAPIOperationDelegate.h"


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

- (void)syncAllLocations;
- (void)syncAllLocationsForContact:(NSManagedObjectID *)contactId;
- (void)syncLocationForPhone:(NSManagedObjectID *)phoneId;
- (void)cancellAllOperations:(BOOL)waitUntilDone;

@end

@interface WAYDataSyncer (Singleton)

+ (WAYDataSyncer *)sharedInstance;

@end

extern NSString* const WAYRetrivePhoneLocationErrorNotification;
extern NSString* const WAYErrorKey;
extern NSString* const WAYReasonKey;
extern NSString* const WAYPhoneKey;
