#import "OASConnectionDelegate.h"


@interface OASConnectionDelegate (/* Private stuff here */)
@property (nonatomic, readwrite, retain) NSHTTPURLResponse *response;
@property (nonatomic, readwrite, retain) NSError *error;

@end

@implementation OASConnectionDelegate
@synthesize data;
@synthesize response;
@synthesize done;
@synthesize error;

- (id)init {
	if (self = [super init]) {
		data = [[NSMutableData alloc] init];
		done = NO;
	}
	return self;
}


- (void)dealloc {
	[data release];
	[response release];
	[error release];
	[super dealloc];
}


+ (OASConnectionDelegate *)delegate {
    return [[[OASConnectionDelegate alloc] init] autorelease];
}


- (NSString *)description {
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        return [NSString stringWithFormat:@"data: %@\nerror :%@\nresponse headers: %@\nstatus code: %d", 
                data, error, [(NSHTTPURLResponse *)response allHeaderFields], [(NSHTTPURLResponse *)response statusCode]];
    }
    else {
        return [NSString stringWithFormat:@"data: %@\nerror :%@\nresponse: %@", 
                data, error, response];
    }
}


#pragma mark -
#pragma mark NSURLConnectionDelegate methods

- (NSURLRequest *)connection:(NSURLConnection *)aConnection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
	return request;
}


- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	if ([challenge previousFailureCount] > 0) {
		[[challenge sender] cancelAuthenticationChallenge:challenge];
	}
	else {
		[[challenge sender] useCredential:[challenge proposedCredential] forAuthenticationChallenge:challenge];
	}
}


- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	done = YES;
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse {
    if ([aResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        self.response = (NSHTTPURLResponse *)aResponse;
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)someData {
	[data appendData:someData];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
	done = YES;
}


- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)aError {
	self.error = aError;
	done = YES;
}

@end
