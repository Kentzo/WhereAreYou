

@interface OASConnectionDelegate : NSObject {
	NSMutableData *data;
	NSHTTPURLResponse *response;
	BOOL done;
	NSError *error;	
}

@property (nonatomic, readonly) NSMutableData *data;
@property (nonatomic, readonly, retain) NSHTTPURLResponse *response;
@property (nonatomic, readonly) BOOL done;
@property (nonatomic, readonly, retain) NSError *error;

+ (OASConnectionDelegate *)delegate;

@end
