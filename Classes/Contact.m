#import "Contact.h"
#import "Phone.h"


@implementation Contact 

@dynamic recordID;
@dynamic twitter;
@dynamic name;
@dynamic phones;

- (BOOL)validatePhonesForUpdate:(NSError **)error {
    for (NSManagedObject *phone in self.phones) {
        if (![phone validateForUpdate:error]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)validateForUpdate:(NSError **)error {
    return ([super validateForUpdate:error] && [self validatePhonesForUpdate:error]);
}

@end
