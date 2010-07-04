#import "OASAPIOperation.h"

// Read about getLocation method in http://openapiservice.com/wiki/images/5/5a/LBS_API_Guide.pdf

extern NSString* const OASDelayToleranceNo;
extern NSString* const OASDelayToleranceLow;
extern NSString* const OASDelayToleranceTolerant;

@interface OASAPIGetLocationOperation : OASAPIOperation {
    NSNumber *applId;               // int          required
    NSString *applKey;              // string       required
    NSString *requestId;            // string       optional
    NSNumber *phoneNumber;          // long long    required
    NSNumber *requestedAccuracy;    // int          required
    NSNumber *acceptableAccuracy;   // int          required
    NSNumber *maximumAge;           // long long    required
    NSNumber *responseTime;         // long long    required
    NSString *tolerance;            // string       required
}

@property (nonatomic, readonly, copy) NSNumber *applId;
@property (nonatomic, readonly, copy) NSString *applKey;
@property (nonatomic, readonly, copy) NSString *requestId;
@property (nonatomic, readonly, copy) NSNumber *phoneNumber;
@property (nonatomic, readonly, copy) NSNumber *requestedAccuracy;
@property (nonatomic, readonly, copy) NSNumber *acceptableAccuracy;
@property (nonatomic, readonly, copy) NSNumber *maximumAge;
@property (nonatomic, readonly, copy) NSNumber *responseTime;
@property (nonatomic, readonly, copy) NSString *tolerance;

// Creates URL from received attributes
- (OASAPIGetLocationOperation *)initWithApplId:(NSNumber *)anApplId applKey:(NSString *)anApplKey requestId:(NSString *)aRequestId
                               phoneNumber:(NSNumber *)aPhoneNumber requestedAccuracy:(NSNumber *)aRequestedAccuracy
                        acceptableAccuracy:(NSNumber *)anAcceptableAccuracy maximumAge:(NSNumber *)aMaximumAge
                              responceTime:(NSNumber *)aResponseTime tolerance:(NSString *)aTolerance;

@end
