#import "Phone.h"
#import "Contact.h"


@implementation Phone 

@dynamic phone;
@dynamic contact;
@dynamic accuracy;
@dynamic altitude;
@dynamic latitude;
@dynamic longitude;
@dynamic timestamp;


#pragma mark -
#pragma mark MKAnnotation

- (CLLocationCoordinate2D)coordinate {
    coordinate.latitude = [self.latitude floatValue];
    coordinate.longitude = [self.longitude floatValue];
    return coordinate;
}


- (NSString *)title {
    static PhoneNumberFormatter *phoneFormatter = nil;
    if (phoneFormatter == nil) {
        phoneFormatter = [[PhoneNumberFormatter alloc] init];
    }
    return [phoneFormatter stringFromPhoneNumber:self.phone];
}


- (NSString *)subtitle {
    return [NSString stringWithFormat:@"accuracy is %d meters", [self.accuracy intValue]];
}
    
@end
