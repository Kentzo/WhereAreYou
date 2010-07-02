#import "WAYDataSyncer.h"
#import "OASGetLocationOperation.h"
#import "Contact.h"
#import "Phone.h"


static const int defaultRequestedAccuracy = 10;     // 10 m
static const int defaultAcceptableAccuract = 1000000;  // 1000 km
static const long long defaultMaximumAge = 3600000L;// 1 hour
static const long long defaultResponseTime = 30000L;// 30 seconds

@interface WAYDataSyncer (/* Private suff here */)

- (void)_updateContext:(NSNotification *)notification;
- (void)_addOperation:(OASAPIOperation *)operation;

@end

static WAYDataSyncer *sharedInstance = nil;

@implementation WAYDataSyncer (Singleton)

+ (WAYDataSyncer *)sharedInstance {
    
    @synchronized(self)
    {
        if (sharedInstance == nil) {
            sharedInstance = [[WAYDataSyncer alloc] init];
        }
    }
    return sharedInstance;
}


+ (id)allocWithZone:(NSZone *)zone {
    
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}


- (id)copyWithZone:(NSZone *)zone {
    return self;
}


- (id)retain {
    return self;
}


- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}


- (void)release {
    return;
}


- (id)autorelease {
    return self;
}

@end

@implementation WAYDataSyncer
@synthesize context;
@synthesize applId;
@synthesize applKey;

static NSDictionary* CXMLNodeToNSDictionary(CXMLNode *rootElement) {
    NSMutableDictionary *bodyDictionary = [NSMutableDictionary dictionary];
    NSUInteger i, count;
    for (i=0, count=[rootElement childCount]; i<count; ++i) {
        CXMLNode *node = [rootElement childAtIndex:i];
        NSUInteger childCount = [node childCount];
        if (childCount == 1) {
            NSString *value = [[node stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([value length]) {
                [bodyDictionary setObject:value forKey:[node name]];
            }
        }
        else if (childCount > 1) {
            NSDictionary *dictionary = CXMLNodeToNSDictionary(node);
            [bodyDictionary setObject:dictionary forKey:[node name]];
        }
    }
    return bodyDictionary;
}

- (id)init {
    
    if (self = [super init]) {
        _queue = [[NSOperationQueue alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(_updateContext:) 
                                                     name:NSManagedObjectContextDidSaveNotification 
                                                   object:nil];
        [_queue addObserver:self forKeyPath:@"operations.@count" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_queue removeObserver:self forKeyPath:@"operations.@count"];
    [context release];
    [applId release];
    [applKey release];
    [_queue release];
    [super dealloc];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // Update network activity indicator
    if ([keyPath isEqualToString:@"operations.@count"]) {
        NSUInteger count = [[change objectForKey:@"new"] integerValue];
        UIApplication *sharedApp = [UIApplication sharedApplication];
        if (count && !sharedApp.networkActivityIndicatorVisible) {
            sharedApp.networkActivityIndicatorVisible = YES;
        }
        else if (!count && sharedApp.networkActivityIndicatorVisible) {
            sharedApp.networkActivityIndicatorVisible = NO;
        }
    }
}


- (void)syncAllLocations {
    
    NSAssert (context != nil, @"You've forgotten to set context");
    @synchronized (context) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"Phone" inManagedObjectContext:context]];
        NSArray *results = [context executeFetchRequest:request error:nil];
         [request release];
        for (Phone *phone in results) {
            OASGetLocationOperation *getLocation = [[OASGetLocationOperation alloc] initWithApplId:applId 
                                                                                           applKey:applKey
                                                                                         requestId:nil
                                                                                       phoneNumber:phone.phone 
                                                                                 requestedAccuracy:[NSNumber numberWithInt:defaultRequestedAccuracy] 
                                                                                acceptableAccuracy:[NSNumber numberWithInt:defaultAcceptableAccuract]
                                                                                        maximumAge:[NSNumber numberWithLongLong:defaultMaximumAge]
                                                                                      responceTime:[NSNumber numberWithLongLong:defaultResponseTime]
                                                                                         tolerance:OASDelayToleranceTolerant];
            getLocation.delegate = self;
            [self _addOperation:getLocation];
            [getLocation release];
        }
    }
}


- (void)syncAllLocationsForContact:(NSManagedObjectID *)contactId {
    
    NSParameterAssert(![contactId isTemporaryID]);
    
    NSAssert (context != nil, @"You've forgotten to set context");
    @synchronized (context) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"Phone" inManagedObjectContext:context]];
        Contact *contact = (Contact *)[context existingObjectWithID:contactId error:nil];
        [request setPredicate:[NSPredicate predicateWithFormat:@"contact = %@", contact]];
        NSArray *results = [context executeFetchRequest:request error:nil];
        [request release];
        for (Phone *phone in results) {
            OASGetLocationOperation *getLocation = [[OASGetLocationOperation alloc] initWithApplId:applId 
                                                                                           applKey:applKey
                                                                                         requestId:nil
                                                                                       phoneNumber:phone.phone
                                                                                 requestedAccuracy:[NSNumber numberWithInt:defaultRequestedAccuracy]
                                                                                acceptableAccuracy:[NSNumber numberWithInt:defaultAcceptableAccuract]
                                                                                        maximumAge:[NSNumber numberWithLongLong:defaultMaximumAge]
                                                                                      responceTime:[NSNumber numberWithLongLong:defaultResponseTime]
                                                                                         tolerance:OASDelayToleranceTolerant];
            getLocation.delegate = self;
            [self _addOperation:getLocation];
            [getLocation release];
        }
    }
}


- (void)syncLocationForPhone:(NSManagedObjectID *)phoneId {
    
    NSParameterAssert(![phoneId isTemporaryID]);
    NSAssert (context != nil, @"You've forgotten to set context");
    @synchronized (context) {
        Phone *phone = (Phone *)[context existingObjectWithID:phoneId error:nil];
        OASGetLocationOperation *getLocation = [[OASGetLocationOperation alloc] initWithApplId:applId
                                                                                       applKey:applKey
                                                                                     requestId:nil
                                                                                   phoneNumber:phone.phone
                                                                             requestedAccuracy:[NSNumber numberWithInt:defaultRequestedAccuracy]
                                                                            acceptableAccuracy:[NSNumber numberWithInt:defaultAcceptableAccuract]
                                                                                    maximumAge:[NSNumber numberWithLongLong:defaultMaximumAge]
                                                                                  responceTime:[NSNumber numberWithLongLong:defaultResponseTime]
                                                                                     tolerance:OASDelayToleranceTolerant];
        getLocation.delegate = self;
        [self _addOperation:getLocation];
        [getLocation release];
    }
}


- (void)cancellAllOperations:(BOOL)waitUntilDone {
    [_queue cancelAllOperations];
    if (waitUntilDone) {
        [_queue waitUntilAllOperationsAreFinished];
    }
}


- (void)_updateContext:(NSNotification *)notification {
    
    NSManagedObjectContext *changedMOC = [notification object];
    if (changedMOC != context) {
    NSAssert (context != nil, @"You've forgotten to set context");
        @synchronized (context) {
            [context mergeChangesFromContextDidSaveNotification:notification];
//        [context performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
//                                  withObject:notification 
//                               waitUntilDone:NO];
        }
    }
}


- (void)_addOperation:(OASAPIOperation *)operation {
    if (![[_queue operations] containsObject:operation]) {
        [_queue addOperation:operation];
    }
}


#pragma mark -
#pragma mark OASAPIOperationDelegate

- (void)apiOperation:(OASAPIOperation *)operation didEndWithResponse:(NSHTTPURLResponse *)response body:(NSData *)aBody error:(NSError *)anError {
    
    if ([operation isKindOfClass:[OASGetLocationOperation class]]) {
        /*      
                Example of Success Response
        <ns:getLocationResponse xmlns:ns="http://service.las.alu.com/xsd"> 
            <ns:return>SU100</ns:return>
            <ns:reason>Success</ns:reason>
            <ns:requestId>R82962</ns:requestId>                 <--- Optional
            <ns:phoneNumber>19175550001</ns:phoneNumber>
            <ns:location> 
                <ns:latitude>41.0355</ns:latitude> 
                <ns:longitude>-82.2419</ns:longitude> 
                <ns:altitude>0.0</ns:altitude> 
                <ns:accuracy>150</ns:accuracy> 
                <ns:timestamp>1242399982540</ns:timestamp>
            </ns:location> 
         </ns:getLocationResponse>
         
                Example of Failure Response
        <ns:getLocationResponse xmlns:ns="http://service.las.alu.com/xsd"> 
            <ns:return>RE402</ns:return> 
            <ns:reason>Wrong key for application 1</ns:reason> 
            <ns:requestId>R82962</ns:requestId>                 <--- Optional
            <ns:phoneNumber>19175550001</ns:phoneNumber>
        </ns:getLocationResponse>
         */
        NSInteger statusCode = [response statusCode];
        if (statusCode >= 200 && statusCode < 400) {
            // Convert xml body to nsdictionary
            CXMLDocument *xmlDocument = [[CXMLDocument alloc] initWithData:aBody options:0 error:NULL];
            NSDictionary *bodyDictionary = CXMLNodeToNSDictionary([xmlDocument rootElement]);
            [xmlDocument release];

            NSString *returnCode = [bodyDictionary objectForKey:@"return"];
            NSAssert (returnCode != nil, @"OAS responses always have return code");
            if ([returnCode hasPrefix:@"SU"]) { // TODO: add normal return code checking
                // Get location attributes
                long long phoneNumber = strtoll([[bodyDictionary objectForKey:@"phoneNumber"] UTF8String], NULL, 10);
                NSDictionary *location = [bodyDictionary objectForKey:@"location"];
                float latitude = strtof([[location objectForKey:@"latitude"] UTF8String], NULL);
                float longitude = strtof([[location objectForKey:@"longitude"] UTF8String], NULL);
                float altitude = strtof([[location objectForKey:@"altitude"] UTF8String], NULL);
                int accuracy = strtol([[location objectForKey:@"accuracy"] UTF8String], NULL, 10);
                long long timestamp = strtoll([[location objectForKey:@"timestamp"] UTF8String], NULL, 10);
                
                // Fetch all Phone objects with same phone number and update them
                @synchronized (context) {
                    NSFetchRequest *request = [[NSFetchRequest alloc] init];
                    [request setEntity:[NSEntityDescription entityForName:@"Phone" inManagedObjectContext:context]];
                    [request setPredicate:[NSPredicate predicateWithFormat:@"phone = %qi", phoneNumber]];
                    NSArray *phones = [context executeFetchRequest:request error:nil];
                    [request release];
                    for (Phone *phone in phones) {
                        // Set phone location attributes
                        phone.latitude = [NSNumber numberWithFloat:latitude];
                        phone.longitude = [NSNumber numberWithFloat:longitude];
                        phone.altitude = [NSNumber numberWithFloat:altitude];
                        phone.accuracy = [NSNumber numberWithInt:accuracy];
                        phone.timestamp = [NSNumber numberWithLongLong:timestamp];
                    }
                    [context save:nil];
                }
            }
            else {
                NSLog(@"error: %@\nreason: %@", [bodyDictionary objectForKey:@"return"], [bodyDictionary objectForKey:@"reason"]);
            }

        }
    }
}


- (void)apiOperationDidCancel:(OASGetLocationOperation *)operation {
    NSLog(@"apiOperationDidCancel:");
}

@end
