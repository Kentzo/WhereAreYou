//
//  PhoneNumberFormatter.m
//  Locale
//
//  Created by iPhone SDK Articles on 11/11/08.
//  Copyright www.iPhoneSDKArticles.com 2008.
//

#import "PhoneNumberFormatter.h"


@implementation PhoneNumberFormatter

@synthesize locale;

- (id) initWithLocale {
	[super init];
	
	locale = [NSLocale currentLocale];
	
	return self;
}

- (NSString *) stringFromPhoneNumber:(NSNumber *)aNumber {
	
    if([[locale localeIdentifier] compare:@"en_US"] == NSOrderedSame) {
        NSString *numberString = [aNumber stringValue];
        NSUInteger length = [numberString length];
        
        if (length > 1 && length < 12) {
            if (length <= 4) {
                return [NSString stringWithFormat:@"%@(%@)", [numberString substringToIndex:1], 
                        [numberString substringFromIndex:1]];
            }
            else if (length <= 7) {
                return [NSString stringWithFormat:@"%@(%@)%@", [numberString substringToIndex:1], 
                        [numberString substringWithRange:NSMakeRange(1, 3)],
                        [numberString substringFromIndex:4]];
            }
            else {
                return [NSString stringWithFormat:@"%@(%@)%@-%@", [numberString substringToIndex:1],
                        [numberString substringWithRange:NSMakeRange(1, 3)],
                        [numberString substringWithRange:NSMakeRange(4, 3)],
                        [numberString substringFromIndex:7]];
            }
        }
        else {
            return numberString;
        }
    }
    else {
        return [aNumber stringValue];
    }
}

#pragma mark -
#pragma mark <Method Override>

- (NSString *) stringForObjectValue:(id)anObject {
	
	if(![anObject isKindOfClass:[NSNumber class]])
		return nil;
	else
		return [self stringFromPhoneNumber:anObject];
}

- (BOOL) getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error {
	
	BOOL returnValue = NO;
		
	return returnValue;
}

- (NSAttributedString *) attirbutedStringForObjectValue:(id)anObject withDefaultAttributes:(NSDictionary *)attributes {
	
	return nil;
}

- (void) dealloc {
	
	[locale release];
	[super dealloc];
}

@end
