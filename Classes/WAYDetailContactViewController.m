#import "WAYDetailContactViewController.h"
#import "AddressBookAdditions.h"


@interface WAYDetailContactViewController ()
@property (nonatomic, retain) NSMutableArray *_twitterUrls;
@property (nonatomic, retain) NSMutableArray *_mobilePhones;

// Make properties observable
- (NSUInteger)countOf_twitterUrls;
- (void)get_twitterUrls:(id *)aBuffer range:(NSRange)aRange;
- (void)insertObject:(NSMutableDictionary *)object in_twitterUrlsAtIndex:(NSUInteger)index;
- (void)removeObjectFrom_twitterUrlsAtIndex:(NSUInteger)index;
- (void)replaceObjectIn_twitterUrlsAtIndex:(NSUInteger)index withObject:(NSMutableDictionary *)object;

- (NSUInteger)countOf_mobilePhones;
- (void)get_mobilePhones:(id *)aBuffer range:(NSRange)aRange;
- (void)insertObject:(NSMutableDictionary *)object in_mobilePhonesAtIndex:(NSUInteger)index;
- (void)removeObjectFrom_mobilePhonesAtIndex:(NSUInteger)index;
- (void)replaceObjectIn_mobilePhonesAtIndex:(NSUInteger)index withObject:(NSMutableDictionary *)object;

// Reloads data from address book
- (void)reloadData;

// Done button was pressed
- (void)done:(id)sender;

// Layouts cell with text field on label place
- (void)layoutCellWithTextField:(UITableViewCell *)cell;

// Inserts empty dictionary to a data array at index path indexPath
//- (void)insertNewObjectAtIndexPath:(NSIndexPath *)indexPath;
//
// Removes dictionary from a data array at index path indexPath
//- (void)removeObjectAtIndexPath:(NSIndexPath *)indexPath;
//
// Sets text of dictionary in a data array at index path indexPath
//- (void)setText:(NSString *)text ofObjectAtIndexPath:(NSIndexPath *)indexPath;
//
// Sets selection of dictionary in a data array at index path indexPath
//- (void)setIsSelected:(BOOL)selected ofObjectAtIndexPath:(NSIndexPath *)indexPath;
//
// Returns isSelected value of object in a data array at index path indexPath
//- (BOOL)objectAtIndexPathIsSelected:(NSIndexPath *)indexPath;
//
// Returns text of object in a data array at index path indexPath
//- (NSString *)textOfObjectAtIndexPath:(NSIndexPath *)indexPath;
//
//- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)sender;
//
// Returns text field on cell at index path
//- (UITextField *)textFieldForRowAtIndexPath:(NSIndexPath *)indexPath;
//
// Starts editing text field on cell at index path indexPath
//- (void)startEditingTextFieldAtIndexPath:(NSIndexPath *)indexPath;
//
// Stops editing text field on cell at current _editingRowIndexPath index path and saves entered data
// Nullifes _editingRowIndexPath
// Returns YES, if text is saved. Otherwise returns NO
//- (BOOL)stopEditingTextField;
//
//- (void)keyboardDidShow:(NSNotification *)notification;
   
@end


#pragma mark -
#pragma mark Local constants

enum {
    kTwitterSectionIndex = 0,
    kPhonesSectionIndex = 1
};

static NSString * const kTextKey = @"text";
static NSString * const kIsSelectedKey = @"isSelected";

static const NSUInteger kTextFieldTag = 100;


@implementation WAYDetailContactViewController
@synthesize personID;
@synthesize delegate;
@synthesize _mobilePhones;
@synthesize _twitterUrls;
@synthesize _editingRowIndexPath;

#pragma mark -
#pragma mark Initialization

- (void)dealloc {
    [_twitterUrls release];
    [_mobilePhones release];
    [_editingRowIndexPath release];
    [super dealloc];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.allowsSelectionDuringEditing = YES;
    self.editing = YES;
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                              target:self action:@selector(done:)];
    self.navigationItem.rightBarButtonItem = doneItem;
    [doneItem release];
}


- (BOOL)canBecomeFirstResponder {
    return YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // Clean up undo manager
    [self resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_data[section] count] + 1;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Return title for section
    if (section == kTwitterSectionIndex) {
        return @"Twitter accounts";
    }
    else {
        return @"Mobile phone numbers";
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"cellForRowAtIndexPath:");
    static NSString *TextCellIdentifier = @"TextCell";
    static NSString *AddCellIdentifier = @"AddCell";
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    UITableViewCell *cell = nil;
    if (row < [_data[section] count]) {
        cell = [tableView dequeueReusableCellWithIdentifier:TextCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TextCellIdentifier] autorelease];
            [self layoutCellWithTextField:cell];
        }
        UITextField *textField = (UITextField *)[cell viewWithTag:kTextFieldTag];
        
        // Set up text field keyboard
        if (section == kTwitterSectionIndex) {
            // Use URL keyboard for twitter account cells
            textField.keyboardType = UIKeyboardTypeURL;
            textField.placeholder = @"URL";
        }
        else {
            // Use Number pad for phone number cells
            textField.keyboardType = UIKeyboardTypePhonePad;
            textField.placeholder = @"Phone";
        }
        
        // Set up text field data
        textField.text = [self textOfObjectAtIndexPath:indexPath];
        cell.editingAccessoryType = [self objectAtIndexPathIsSelected:indexPath] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:AddCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AddCellIdentifier] autorelease];
            // Make text color like text color of add row in Contacts.app on iPhone
            cell.textLabel.textColor = [UIColor colorWithRed:0.294 green:0.345 blue:0.447 alpha:1.0];
        }
        cell.textLabel.text = @"Add new";
    }
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self removeObjectAtIndexPath:indexPath];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        [self insertNewObjectAtIndexPath:indexPath];
    }   
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([indexPath row] < [_data[[indexPath section]] count]) {
        if ([self objectAtIndexPathIsSelected:indexPath]) {
            [self setIsSelected:NO ofObjectAtIndexPath:indexPath];
        }
        else {
            [self setIsSelected:YES ofObjectAtIndexPath:indexPath];
        }
        if (_editingRowIndexPath != nil) {
            // Stop editing row
            [self stopEditingTextField];
        }
    }
    else {
        // Click was made on add button. Insert new object.
        [self insertNewObjectAtIndexPath:indexPath];
    }
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Use UITableViewCellEditingStyleDelete style for all rows except add buttons. Use UITableViewCellEditingStyleInsert for them.
    if ([indexPath row] < [_data[[indexPath section]] count]) {
        return UITableViewCellEditingStyleDelete;
    }
    else {
        return UITableViewCellEditingStyleInsert;
    }
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self stopEditingTextField];
    return NO;
}


#pragma mark -
#pragma mark Private

- (NSUInteger)countOf_twitterUrls {
    return [_twitterUrls count];
}


- (void)get_twitterUrls:(id *)aBuffer range:(NSRange)aRange {
    [_twitterUrls getObjects:aBuffer range:aRange];
}


- (void)insertObject:(NSMutableDictionary *)object in_twitterUrlsAtIndex:(NSUInteger)index {
    [_twitterUrls insertObject:object atIndex:index];
}


- (void)removeObjectFrom_twitterUrlsAtIndex:(NSUInteger)index {
    [_twitterUrls removeObjectAtIndex:index];
}


- (void)replaceObjectIn_twitterUrlsAtIndex:(NSUInteger)index withObject:(NSMutableDictionary *)object {
    [_twitterUrls replaceObjectAtIndex:index withObject:object];
}


- (NSUInteger)countOf_mobilePhones {
    return [_mobilePhones count];
}


- (void)get_mobilePhones:(id *)aBuffer range:(NSRange)aRange {
    [_mobilePhones getObjects:aBuffer range:aRange];
}


- (void)insertObject:(NSMutableDictionary *)object in_mobilePhonesAtIndex:(NSUInteger)index {
    [_mobilePhones insertObject:object atIndex:index];
}


- (void)removeObjectFrom_mobilePhonesAtIndex:(NSUInteger)index {
    [_mobilePhones removeObjectAtIndex:index];
}


- (void)replaceObjectIn_mobilePhonesAtIndex:(NSUInteger)index withObject:(NSMutableDictionary *)object {
    [_mobilePhones replaceObjectAtIndex:index withObject:object];
}


- (void)reloadData {
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, personID);
    if (person != NULL) {
        // Collect all urls that contain "twitter.com/" substring
        NSArray *urls = CollectUrlsThatContainString(person, (CFStringRef)@"twitter.com/");
        NSMutableArray *newUrls = [NSMutableArray arrayWithCapacity:[urls count]];
        for (NSString *url in urls) {
            // All rows are deselected by defauld
            NSMutableDictionary *selectableUrl = [NSMutableDictionary dictionaryWithObjectsAndKeys:url, kTextKey, [NSNumber numberWithBool:NO], kIsSelectedKey, nil];
            [newUrls addObject:selectableUrl];
        }
        self._twitterUrls = newUrls;
        _data[kTwitterSectionIndex] = _twitterUrls;
        _selectedTwitterUrl = [_twitterUrls count] + 1;
        
        // Collect all mobile phones
        NSArray *phones = CollectMobilePhones(person);
        NSMutableArray *newPhones = [NSMutableArray arrayWithCapacity:[phones count]];
        for (NSString *phone in phones) {
            // All phone are selected by default
            NSMutableDictionary *selectablePhone = [NSMutableDictionary dictionaryWithObjectsAndKeys:phone, kTextKey, [NSNumber numberWithBool:YES], kIsSelectedKey, nil];
            [newPhones addObject:selectablePhone];
        }
        self._mobilePhones = newPhones;
        _data[kPhonesSectionIndex] = _mobilePhones;
        
        self.title = (NSString *)ABRecordCopyCompositeName(person);
    }
    CFRelease(addressBook);
}


- (void)done:(id)sender {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isSelected = YES"];
    NSArray *selectedUrls = [[_twitterUrls filteredArrayUsingPredicate:predicate] valueForKey:kTextKey];
    NSArray *selectedPhones = [[_mobilePhones filteredArrayUsingPredicate:predicate] valueForKey:kTextKey];
    [delegate detailContactViewController:self didDoneWithTwitterURLs:selectedUrls phoneNumbers:selectedPhones];
}


- (void)layoutCellWithTextField:(UITableViewCell *)cell {
    
    CGRect frame = cell.contentView.frame;
    // Make frame size like textLabel has
    frame.origin.x = 10;
    frame.size.width -= 20;
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.tag = kTextFieldTag;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.returnKeyType = UIReturnKeyDone;
    textField.delegate = self;
    // Make font size like textLabel has
    textField.font = [UIFont boldSystemFontOfSize:17.0];
    // Disable iteraction because of using gestures
    textField.userInteractionEnabled = NO;
    
    [cell.contentView addSubview:textField];
    [textField release];
    
    // Create long press gesture
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [cell addGestureRecognizer:longPress];
    [longPress release];
}

//
//- (void)insertNewObjectAtIndexPath:(NSIndexPath *)indexPath {
//    
//    NSUInteger section = [indexPath section];
//    NSUInteger row = [indexPath row];
//    if (section == kTwitterSectionIndex) {
//        NSMutableDictionary *newItem = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", kTextKey, [NSNumber numberWithBool:NO], kIsSelectedKey, nil];
//        [_twitterUrls insertObject:newItem atIndex:row];
//    }
//    else {
//        NSMutableDictionary *newItem = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", kTextKey, [NSNumber numberWithBool:YES], kIsSelectedKey, nil];
//        [_mobilePhones insertObject:newItem atIndex:row];
//    }
//    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
//    [self startEditingTextFieldAtIndexPath:indexPath];
//}
//
//
//- (void)removeObjectAtIndexPath:(NSIndexPath *)indexPath {
//    NSMutableArray *dataArray = _data[[indexPath section]];
//    [dataArray removeObjectAtIndex:[indexPath row]];
//    if ([_editingRowIndexPath section] == [indexPath section] && [_editingRowIndexPath row] > [indexPath row]) {
//        NSIndexPath *newEditingIndexPath = [NSIndexPath indexPathForRow:([_editingRowIndexPath row] - 1) inSection:[_editingRowIndexPath section]];
//        self._editingRowIndexPath = newEditingIndexPath;
//    }
//    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
//}
//
//
//- (void)setText:(NSString *)text ofObjectAtIndexPath:(NSIndexPath *)indexPath {
//    NSMutableDictionary *dataItem = [_data[[indexPath section]] objectAtIndex:[indexPath row]];
//    [dataItem setObject:text forKey:kTextKey];
//    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
//}
//
//
//- (void)setIsSelected:(BOOL)selected ofObjectAtIndexPath:(NSIndexPath *)indexPath {
//    if ([indexPath section] == kTwitterSectionIndex) {
//        // Only one twitter url can be selected in the same time
//        NSUInteger index = 0;
//        for (NSMutableDictionary *url in _twitterUrls) {
//            if ([[url objectForKey:kIsSelectedKey] boolValue]) {
//                [url setObject:[NSNumber numberWithBool:NO] forKey:kIsSelectedKey];
//                NSIndexPath *urlIndexPath = [NSIndexPath indexPathForRow:index inSection:kTwitterSectionIndex];
//                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:urlIndexPath] withRowAnimation:UITableViewRowAnimationNone];
//                break;
//            }
//            ++index;
//        }
//    }
//
//    NSMutableDictionary *dataItem = [_data[[indexPath section]] objectAtIndex:[indexPath row]];
//    [dataItem setObject:[NSNumber numberWithBool:selected] forKey:kIsSelectedKey];
//    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
//}
//
//
//- (BOOL)objectAtIndexPathIsSelected:(NSIndexPath *)indexPath {
//    return [[[_data[[indexPath section]] objectAtIndex:[indexPath row]] objectForKey:kIsSelectedKey] boolValue];
//}
//
//
//- (NSString *)textOfObjectAtIndexPath:(NSIndexPath *)indexPath {
//    return [[_data[[indexPath section]] objectAtIndex:[indexPath row]] objectForKey:kTextKey];
//}
//
//
//- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)sender {
//    
//    if ([sender state] == UIGestureRecognizerStateBegan) {
//        CGPoint point = [sender locationInView:self.tableView];
//        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
//        if (_editingRowIndexPath != nil) {
//            [self stopEditingTextField];
//        }
//        [self startEditingTextFieldAtIndexPath:indexPath];
//    }
//}
//
//
//- (UITextField *)textFieldForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITextField *textField = (UITextField *)[[self.tableView cellForRowAtIndexPath:indexPath] viewWithTag:kTextFieldTag];
//    return textField;
//}
//
//
//- (void)startEditingTextFieldAtIndexPath:(NSIndexPath *)indexPath {
//
//    UITextField *textField = [self textFieldForRowAtIndexPath:indexPath];
//    textField.userInteractionEnabled = YES;
//    [textField becomeFirstResponder];
//    if (_editingRowIndexPath != nil) {
//        NSIndexPath *editingIndexPath = [_editingRowIndexPath retain];
//        if (![self stopEditingTextField]) {
//            if ([editingIndexPath section] == [indexPath section] && [editingIndexPath row] < [indexPath row]) {
//                indexPath = [NSIndexPath indexPathForRow:([indexPath row] - 1) inSection:[indexPath section]];
//            }
//        }
//        [editingIndexPath release];
//    }
//    self._editingRowIndexPath = indexPath;
//}
//
//
//- (BOOL)stopEditingTextField {
//    
//    NSAssert(_editingRowIndexPath != nil, @"_editingRowIndexPath must not be nil");
//    
//    BOOL result = YES;
//    UITextField *textField = [self textFieldForRowAtIndexPath:_editingRowIndexPath];
//    
//    // Save entered text
//    if ([textField.text length]) {
//        [self setText:textField.text ofObjectAtIndexPath:_editingRowIndexPath];
//    }
//    else {
//        [self removeObjectAtIndexPath:_editingRowIndexPath];
//        result = NO;
//    }
//    
//    // End editing
//    [textField resignFirstResponder];
//    textField.userInteractionEnabled = NO;
//    self._editingRowIndexPath = nil;
//    
//    return result;
//}
//
//
//- (void)keyboardDidShow:(NSNotification *)notification {
//    // Scroll table to row at index path _editingRowIndexPath when keyboard shows
//    if (_editingRowIndexPath) {
//        [self.tableView scrollToRowAtIndexPath:_editingRowIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
//    }
//}


@end

