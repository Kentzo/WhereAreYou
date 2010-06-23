#import "AddressBookAdditions.h"


NSMutableArray* CollectMobilePhones(ABRecordRef person) {
    
    assert(person != NULL);
    NSMutableArray *mobilePhones = [NSMutableArray array];
    
    // Extract all objects for kABPersonPhoneProperty property
    ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
    CFIndex count = 0;
    CFIndex index = 0;
    for (index=0, count=ABMultiValueGetCount(phones); index<count; ++index) {
        CFStringRef label = ABMultiValueCopyLabelAtIndex(phones, index);
        // If label equals to kABPersonPhoneMobileLabel then add it to mobilePhones array
        if (CFStringCompare(label, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
            CFStringRef mobilePhone = ABMultiValueCopyValueAtIndex(phones, index);
            [mobilePhones addObject:(NSString *)mobilePhone];
            CFRelease(mobilePhone);
        }
        CFRelease(label);
    }
    CFRelease(phones);
    
    return mobilePhones;
}

NSMutableArray* CollectUrlsThatContainString(ABRecordRef person, CFStringRef string) {
    
    assert(person != NULL);
    NSMutableArray *filtredUrls = [NSMutableArray array];
    
    // Extract all objects for kABPersonURLProperty property
    ABMultiValueRef urls = ABRecordCopyValue(person, kABPersonURLProperty);
    CFIndex count = 0;
    CFIndex index = 0;
    for (index=0, count=ABMultiValueGetCount(urls); index<count; ++index) {
        CFStringRef value = ABMultiValueCopyValueAtIndex(urls, index);
        // If value contains "string" then add it to filtredUrls
        if (CFStringFindWithOptions(value, string, CFRangeMake(0, CFStringGetLength(value)), kCFCompareCaseInsensitive, NULL) == true) {
            [filtredUrls addObject:(NSString *)value];
        }
        CFRelease(value);
    }
    CFRelease(urls);
    
    return filtredUrls;
}