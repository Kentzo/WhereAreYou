#import "OASAPIOperationDelegate.h"


@interface OASAPIOperation : NSOperation {
    NSURL *url;
    id<OASAPIOperationDelegate> delegate;
    NSTimeInterval timeoutInterval;
}

@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, assign) id<OASAPIOperationDelegate> delegate;
@property (nonatomic) NSTimeInterval timeoutInterval;

// Designated intializer
- (id)initWithURL:(NSURL *)anUrl;

- (BOOL)isEqualToTask:(OASAPIOperation *)task;

- (NSUInteger)hash;

@end
