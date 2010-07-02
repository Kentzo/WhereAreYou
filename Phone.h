

@class Contact;

@interface Phone :  NSManagedObject <MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic, retain) NSNumber * phone;
@property (nonatomic, retain) Contact * contact;
@property (nonatomic, retain) NSNumber * accuracy;
@property (nonatomic, retain) NSNumber * altitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * timestamp;

@end



