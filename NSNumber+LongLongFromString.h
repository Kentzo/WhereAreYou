

@interface NSNumber (LongLongFromString)

// Returns nsnumber with long long if string contatins digits that can be converted to long long
// Otherwise returns nil
+ (NSNumber *)numberWithLongLongFromString:(NSString *)string;

@end
