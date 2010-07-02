#import "NSNumber+LongLongFromString.h"


@implementation NSNumber (LongLongFromString)

+ (NSNumber *)numberWithLongLongFromString:(NSString *)string {
    NSParameterAssert(string != nil);
    
    NSCharacterSet *nonDecimalDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSMutableString *numberString = [NSMutableString string];
    
    NSUInteger i, count;
    for (i=0, count=CFStringGetLength((CFStringRef)string); i<count; ++i) {
        unichar character = CFStringGetCharacterAtIndex((CFStringRef)string, i);
        if (![nonDecimalDigits characterIsMember:character]) {
            CFStringAppendCharacters((CFMutableStringRef)numberString, &character, 1);
        }
    }
    
    if (![numberString length]) {
        return nil;
    }
    else {
        long long number = strtoll([numberString UTF8String], NULL, 10);
        if (errno == ERANGE || number == 0) { // Phone number cannot start with 0
            return nil;
        }
        else {
            return [NSNumber numberWithLongLong:number];
        }
    }
}

@end
