//
//  PhoneNumberFormatter.h
//  Locale
//
//  Created by iPhone SDK Articles on 11/11/08.
//  Copyright www.iPhoneSDKArticles.com 2008.
//

#import <UIKit/UIKit.h>


@interface PhoneNumberFormatter : NSFormatter {

	NSLocale *locale;
}

@property (nonatomic, copy) NSLocale *locale;

- (id) initWithLocale;
- (NSString *) stringFromPhoneNumber:(NSNumber *)aNumber;

@end
