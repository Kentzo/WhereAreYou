#import "OASAPIGetLocationOperation.h"


NSString* const OASDelayToleranceNo = @"NO_DELAY";
NSString* const OASDelayToleranceLow = @"LOW_DELAY";
NSString* const OASDelayToleranceTolerant = @"DELAY_TOLERANT";

@interface OASAPIGetLocationOperation (/* Private stuff here */)
@property (nonatomic, readwrite, copy) NSNumber *applId;
@property (nonatomic, readwrite, copy) NSString *applKey;
@property (nonatomic, readwrite, copy) NSString *requestId;
@property (nonatomic, readwrite, copy) NSNumber *phoneNumber;
@property (nonatomic, readwrite, copy) NSNumber *requestedAccuracy;
@property (nonatomic, readwrite, copy) NSNumber *acceptableAccuracy;
@property (nonatomic, readwrite, copy) NSNumber *maximumAge;
@property (nonatomic, readwrite, copy) NSNumber *responseTime;
@property (nonatomic, readwrite, copy) NSString *tolerance;

@end


@implementation OASAPIGetLocationOperation
@synthesize applId;
@synthesize applKey;
@synthesize requestId;
@synthesize phoneNumber;
@synthesize requestedAccuracy;
@synthesize acceptableAccuracy;
@synthesize maximumAge;
@synthesize responseTime;
@synthesize tolerance;

- (OASAPIGetLocationOperation *)initWithApplId:(NSNumber *)anApplId applKey:(NSString *)anApplKey requestId:(NSString *)aRequestId
                               phoneNumber:(NSNumber *)aPhoneNumber requestedAccuracy:(NSNumber *)aRequestedAccuracy
                        acceptableAccuracy:(NSNumber *)anAcceptableAccuracy maximumAge:(NSNumber *)aMaximumAge
                              responceTime:(NSNumber *)aResponseTime tolerance:(NSString *)aTolerance 
{   
    NSParameterAssert(anApplId != nil);
    NSParameterAssert(anApplKey != nil);
    NSParameterAssert(aPhoneNumber != nil);
    NSParameterAssert(aRequestedAccuracy != nil);
    NSParameterAssert(anAcceptableAccuracy != nil);
    NSParameterAssert([anAcceptableAccuracy intValue] >= [aRequestedAccuracy intValue]);
    NSParameterAssert(aMaximumAge != nil);
    NSParameterAssert(aResponseTime != nil);
    NSParameterAssert(aTolerance != nil);
    
    /* Sample Request
     https://api.openapiservice.com/rest/getLocation?applId=1&applKey=a44f2nz9ql30cpou7wev8te3&requestId=R82962&phoneNumber=19175550001&requestedAccuracy=100&acceptableAccuracy=1000&maximumAge=300000&responseTime=60000&tolerance=DELAY_TOLERANT
     */
    NSString *urlString = nil;
    if (requestId != nil) {
        urlString = [[NSString alloc] initWithFormat:@"https://api.openapiservice.com/rest/getLocation?applId=%@&applKey=%@&requestId=%@&phoneNumber=%@&requestedAccuracy=%@&acceptableAccuracy=%@&maximumAge=%@&responseTime=%@&tolerance=%@",
                     anApplId, anApplKey, aRequestId, aPhoneNumber, aRequestedAccuracy, anAcceptableAccuracy, aMaximumAge, aResponseTime, aTolerance];
    }
    else {
        urlString = [[NSString alloc] initWithFormat:@"https://api.openapiservice.com/rest/getLocation?applId=%@&applKey=%@&phoneNumber=%@&requestedAccuracy=%@&acceptableAccuracy=%@&maximumAge=%@&responseTime=%@&tolerance=%@",
                     anApplId, anApplKey, aPhoneNumber, aRequestedAccuracy, anAcceptableAccuracy, aMaximumAge, aResponseTime, aTolerance];
    }
    NSURL *newUrl = [[NSURL alloc] initWithString:urlString];
    [urlString release];    
    
    if (self = [super initWithURL:newUrl]) {
        self.applId = anApplId;
        self.applKey = anApplKey;
        self.requestId = aRequestId;
        self.phoneNumber = aPhoneNumber;
        self.requestedAccuracy = aRequestedAccuracy;
        self.acceptableAccuracy = anAcceptableAccuracy;
        self.maximumAge = aMaximumAge;
        self.responseTime = aResponseTime;
        self.tolerance = aTolerance;
        // Set timeout interval to ceil of responseTime / 1000 (divide on 1000 becaouse openapiservice gets milliseconds 
        // but timeoutInterval is in seconds
        self.timeoutInterval = ceil([responseTime doubleValue]/1000);
    }
    [newUrl release];
    return self;
}


- (void)dealloc {
    [applId release];
    [applKey release];
    [requestId release];
    [phoneNumber release];
    [requestedAccuracy release];
    [acceptableAccuracy release];
    [maximumAge release];
    [responseTime release];
    [tolerance release];
    [super dealloc];
}

- (NSString *)description {
    NSString *requestIdString = [requestId description];
    if (requestId == nil) {
        requestIdString = [[NSNull null] description];
    }
    NSString *description = [NSString stringWithFormat:@"%@\napplId: %@\napplKey: %@\nrequestId: %@\nphoneNumber: %@\nrequestedAccuracy: %@\nacceptableAccuracy: %@\n\
                             maximumAge: %@\nresponseTime: %@\ntolerance: %@", [super description], applId, applKey, requestIdString, phoneNumber, 
                             requestedAccuracy, acceptableAccuracy, maximumAge, responseTime, tolerance];
    return description;
}

@end
