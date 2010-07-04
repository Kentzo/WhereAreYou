

// Simple UITableViewCell subclass contains UITextField object

@class WAYEditableHightlightableView;

@interface WAYEditableTableViewCell : UITableViewCell {
@private
    WAYEditableHightlightableView *_view;
}

@property (nonatomic, readonly) UITextField *textField;
//@property (nonatomic, readonly) UIActivityIndicatorView *activityIndicator;

@end
