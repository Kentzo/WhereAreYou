
@class OASAPIOperation;

@protocol OASAPIOperationDelegate <NSObject>
@optional

- (void)apiOperation:(OASAPIOperation *)operation didEndWithResponse:(NSHTTPURLResponse *)response body:(NSData *)aBody error:(NSError *)anError;
- (void)apiOperationDidCancel:(OASAPIOperation *)operation;

@end
