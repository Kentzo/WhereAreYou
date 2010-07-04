

// OASConnectionDelegate is designed to be URLConnection delegate for OASAPI operations

@interface OASConnectionDelegate : NSObject {
	NSMutableData *data;
	NSHTTPURLResponse *response;
	BOOL done;
	NSError *error;	
}
// Returns collected data from a connection
@property (nonatomic, readonly) NSMutableData *data;
// Returns NSHTTPURLResponse for a connection
@property (nonatomic, readonly, retain) NSHTTPURLResponse *response;
// Indicate that connection is done or not
@property (nonatomic, readonly) BOOL done;
// Returns error for a connection
@property (nonatomic, readonly, retain) NSError *error;

// Returns initialized autoreleased OASConnectionDelegate object
+ (OASConnectionDelegate *)delegate;

@end
