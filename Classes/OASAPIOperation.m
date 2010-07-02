#import "OASAPIOperation.h"
#import "OASConnectionDelegate.h"


@implementation OASAPIOperation
@synthesize url;
@synthesize delegate;
@synthesize timeoutInterval;

- (id)initWithURL:(NSURL *)anUrl {
    NSParameterAssert(anUrl != nil);
    if (self = [super init]) {
        url = [anUrl copy];
    }
    return self;
}


- (void)dealloc {
    [url release];
    [super dealloc];
}


- (BOOL)isEqualToTask:(OASAPIOperation *)task {
    return [url isEqual:task.url];
}


- (BOOL)isEqual:(id)object {
    return [self isEqualToTask:object];
}


- (NSUInteger)hash {
    return [url hash];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"%@\nurl: %@\ntimeoutInterval: %.f", [super description], url, timeoutInterval];
}


- (void)main {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    // Ignore all caches
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url 
                                                  cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData 
                                              timeoutInterval:timeoutInterval];
    
	OASConnectionDelegate *connectionDelegate = [OASConnectionDelegate delegate];
    
    // Set up custom rul loop to provide asynchronous
    static NSString *runLoopMode = @"com.kulakov.openapiservice.operation";
    NSURLConnection *connection = [[[NSURLConnection alloc] initWithRequest:request delegate:connectionDelegate startImmediately:NO] autorelease];
    [request release];
	[connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:runLoopMode];
	[connection start];
    NSLog(@"=> %@", url);
	while (!connectionDelegate.done && ![self isCancelled]) {
		[[NSRunLoop currentRunLoop] runMode:runLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:.3f]];
	}
    if ([self isCancelled]) {
        if ([delegate respondsToSelector:@selector(apiOperationDidCancel:)]) {
            [delegate apiOperationDidCancel:self];
        }
    }
    else {
        if ([delegate respondsToSelector:@selector(apiOperation:didEndWithResponse:body:error:)]) {
            [delegate apiOperation:self didEndWithResponse:connectionDelegate.response body:connectionDelegate.data error:connectionDelegate.error];
        }
    }
    [pool release];
}

@end
