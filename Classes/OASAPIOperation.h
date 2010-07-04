#import "OASAPIOperationDelegate.h"


/*
 OASOperation is a base class for all openapiservice tasks.
 It subclusses from MSOperation and designed to be used in tandem with NSOperationQueue.
 It overrides isEqual and hash methods, so it is possible to compare OASAPIOperation objects.
 OASAPIOperation informs delegate about task status. It sends apiOperation:didEndWithResponse:body:error: selector when operation
    completed and apiOperationDidCancel: when operation is cancelled by sending cancel selector.
 */

@interface OASAPIOperation : NSOperation {
    NSURL *url;
    id<OASAPIOperationDelegate> delegate;
    NSTimeInterval timeoutInterval;
}

// URL to openapiserivce to retrieve some data
@property (nonatomic, readonly) NSURL *url;
// Delegate that will be informed about task status
@property (nonatomic, assign) id<OASAPIOperationDelegate> delegate;
// Maximum time that connection can wait for response
@property (nonatomic) NSTimeInterval timeoutInterval;

// Designated intializer
- (id)initWithURL:(NSURL *)anUrl;

- (BOOL)isEqualToTask:(OASAPIOperation *)task;

- (NSUInteger)hash;

@end
