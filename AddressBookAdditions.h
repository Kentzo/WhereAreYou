

// Collect all values with kABPersonPhoneMobileLabel label
// Returns autoreleased NSMutableArray object
NSMutableArray* CollectMobilePhones(ABRecordRef person);

// Collect all values of kABPersonURLProperty property that contain the "twitter.com" string
// Returns autoreleased array
NSMutableArray* CollectUrlsThatContainString(ABRecordRef person, CFStringRef string);