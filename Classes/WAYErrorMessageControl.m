#import "WAYErrorMessageControl.h"


@interface WAYErrorMessageControl (/* Private stuff here */)
@property (nonatomic, readwrite, retain) IBOutlet UIImageView *imageView;

- (void)_highlight:(BOOL)highlight;

@end

@implementation WAYErrorMessageControl
@synthesize textLabel;
@synthesize imageView;


- (void)dealloc {
    [textLabel release];
    [imageView release];
    [super dealloc];
}


- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    BOOL result = [super beginTrackingWithTouch:touch withEvent:event];
    [self _highlight:YES];
    return result;
}


- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    BOOL result = [super continueTrackingWithTouch:touch withEvent:event];
    if (CGRectContainsPoint(self.bounds, [touch locationInView:self])) {
        [self _highlight:YES];
    }
    else {
        [self _highlight:NO];
    }

    return result;
}


- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    [self _highlight:NO];
}


- (void)_highlight:(BOOL)highlight {
    // Change background color and textLabel color
    // Do it smoothly
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.1f];
    if (highlight) {
        textLabel.textColor = [UIColor whiteColor];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 4.0f;
        self.backgroundColor = [UIColor grayColor];
    }
    else {
        self.textLabel.textColor = [UIColor blackColor];
        self.backgroundColor = [UIColor clearColor];
    }
    [UIView commitAnimations];
}

@end
