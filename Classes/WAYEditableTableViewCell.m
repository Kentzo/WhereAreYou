#import "WAYEditableTableViewCell.h"


@interface WAYEditableHightlightableView : UIView {
    UITextField *textField;
    UIActivityIndicatorView *activityIndicator;
    BOOL highlighted;
}

@property (nonatomic, assign) UITextField *textField;
@property (nonatomic, assign) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;

@end

@implementation WAYEditableHightlightableView
@synthesize textField;
@synthesize activityIndicator;
@synthesize highlighted;

- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        static const CGFloat elementMargin = 8.0f;
        
        self.opaque = YES;
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGRect newIndicatorFrame = indicator.frame;
        newIndicatorFrame.origin.x = CGRectGetWidth(frame) - CGRectGetWidth(indicator.frame);
        newIndicatorFrame.origin.y = (CGRectGetHeight(frame) - CGRectGetHeight(indicator.frame))/2;
        indicator.frame = newIndicatorFrame;
        indicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        indicator.opaque = YES;
        self.activityIndicator = indicator;
        [self addSubview:indicator];    
        [indicator release];
        
        UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMinX(indicator.frame) - elementMargin, CGRectGetHeight(frame))];
        field.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        field.clearButtonMode = UITextFieldViewModeWhileEditing;
        field.opaque = YES;
        field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        field.font = [UIFont boldSystemFontOfSize:17.0f];
        self.textField = field;
        [self addSubview:field];
        [field release];
    }
    return self;
}


- (void)setBackgroundColor:(UIColor *)newColor {
    
    [super setBackgroundColor:newColor];
    textField.backgroundColor = newColor;
    activityIndicator.backgroundColor = newColor;
}


- (void)setHighlighted:(BOOL)isHighlighted {
    highlighted = isHighlighted;
    textField.textColor = isHighlighted ? [UIColor whiteColor] : [UIColor blackColor];
    activityIndicator.activityIndicatorViewStyle = isHighlighted ? UIActivityIndicatorViewStyleWhite : UIActivityIndicatorViewStyleGray;
}

@end


@implementation WAYEditableTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _view = [[WAYEditableHightlightableView alloc] initWithFrame:CGRectInset(self.contentView.frame, 10.0f, 7.0f)];
        _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _view.contentMode = UIViewContentModeRedraw;
        [self.contentView addSubview:_view];
    }
    return self;
}


- (void)dealloc {
    [_view release];
    [super dealloc];
}


- (UITextField *)textField {
    return _view.textField;
}


- (UIActivityIndicatorView *)activityIndicator {
    return _view.activityIndicator;
}


- (void)setBackgroundColor:(UIColor *)newColor {
    [super setBackgroundColor:newColor];
    _view.backgroundColor = self.backgroundColor;
}


@end
