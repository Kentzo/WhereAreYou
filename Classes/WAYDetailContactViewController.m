#import "WAYDetailContactViewController.h"
#import "WAYEditableTableViewCell.h"
#import "AddressBookAdditions.h"

/*!
 * @enum Sections
 * @abstract Indexes of table view sections.
 * @constant kTwitterSectionIndex Section of twitter accounts.
 * @constant kPhonesSectionIndex Section of phone numbers.
 */
enum {
    kTwitterSectionIndex = 0,
    kPhonesSectionIndex = 1
};

/*!
 * @var WAYDetailContactTextKey
 * @abstract Use this key to get text from data dictionary.
 */
static NSString * const WAYDetailContactTextKey = @"WAYDetailContactTextKey";

/*!
 * @var WAYDetailContactIsSelectedKey
 * @abstract Use this key to get selection status from data dictionary.
 */
static NSString * const WAYDetailContactIsSelectedKey = @"WAYDetailContactIsSelectedKey";

@interface WAYDetailContactViewController ()
/*!
 * @property _twitterAccounts
 * @abstract Contains data for the Twitter Accounts section.
 * @discussion Obects of ths array are NSMutableDictionary instances.
 */
@property (nonatomic, retain) NSMutableArray *_twitterAccounts;

/*!
 * @property _mobilePhones
 * @abstract Contains data for the Phones section.
 * @discussion Obects of ths array are NSMutableDictionary instances.
 */
@property (nonatomic, retain) NSMutableArray *_mobilePhones;

/*!
 * @property _editingRowIndexPath
 * @abstract Keeps index path of currently edited row.
 * @discussion Has value only when some row is edited. Otherwise nil.
 */
@property (nonatomic, retain) NSIndexPath *_editingRowIndexPath;

/*!
 * @property _editingRowIndexPath
 * @abstract Keeps pointer to UITextField in currently edited row.
 * @discussion Has value only when some row is edited. Otherwise nil.
 */
@property (nonatomic, assign) UITextField *_editingTextField;

/*!
 * @method _updateData
 * @abstract Updates data arrays using provided record id personID.
 */
- (void)_updateData;

/*!
 * @method _insertNewObjectAtIndexPath:
 * @abstract Inserts new object to the data array.
 * @param indexPath Index path to insert.
 */
- (void)_insertNewObjectAtIndexPath:(NSIndexPath *)indexPath;

/*!
 * @method _startEditingTextFieldAtIndexPath:
 * @abstract Starts editing cell on row at index path indexPath.
 * @param indexPath Index path of the row to edit.
 * @discussion Makes cell's text field first responder, switches contentView.userInteractionEnabled to YES and saves index path and pointer to the text field.
 */
- (void)_startEditingTextFieldAtIndexPath:(NSIndexPath *)indexPath;

/*!
 * @method _stopEditingTextField
 * @abstract Stops editing cell at index path _editingRowIndexPath.
 * @discussion Resigns first responder, switches contentView.userInteractionEnabled to NO and nullyfies _editingRowIndexPath and _editingTextField.
 */
- (void)_stopEditingTextField;

/*!
 * @method _fixIndexPath:afterDeletionIndexPath:
 * @abstract Checks the section and row of given index paths and, if needed, fixes indexPath by moving it up.
 * @param indexPath Index path that needs to be fixed.
 * @param indexPathToDelete Index path of the row that will be deleted.
 * @result Fixed index path.
 */
- (NSIndexPath *)_fixIndexPath:(NSIndexPath *)indexPath afterDeletionIndexPath:(NSIndexPath *)indexPathToDelete;

/*!
 * @method _fixSelectedTwitterURLAfterDeletionIndexPath:
 * @abstract Checks the section and row of given index path and _selectedTwitterAccount and, if needed, fixes _selectedTwitterAccount by moving it up.
 * @param indexPathToDelete Index path of the row that will be deleted.
 */
- (void)_fixSelectedTwitterURLAfterDeletionIndexPath:(NSIndexPath *)indexPathToDelete;


/*!
 * @method _done:
 * @abstract Action for the "Done" navigation button.
 * @param sender Object that sends this message.
 */
- (void)_done:(id)sender;

/*!
 * @method _handleLongPress:
 * @abstract Action for the Long Press gesture of a cell.
 * @param gestureRecognizer Gesture that is triggered.
 */
- (void)_handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer;

@end


@implementation WAYDetailContactViewController
@synthesize personID;
@synthesize delegate;
@synthesize _twitterAccounts;
@synthesize _mobilePhones;
@synthesize _editingRowIndexPath;
@synthesize _editingTextField;

#pragma mark -
#pragma mark Initialization

- (void)dealloc {
    [_twitterAccounts release];
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
                                                                              target:self action:@selector(_done:)];
    self.navigationItem.rightBarButtonItem = doneItem;
    [doneItem release];
}


- (BOOL)canBecomeFirstResponder {
    return YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self _updateData];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return number of entires in section plus 1 for add button
    return [_data[section] count] + 1;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == kTwitterSectionIndex) {
        return @"Twitter accounts";
    }
    else {
        return @"Phone numbers";
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == kTwitterSectionIndex) {
        return @"Hold on row to edit";
    }
    else {
        return @"Including country code";
    }
}
 

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *AddCellIdentifier = @"AddCell";
    static NSString *WAYEditableCellIdentifier = @"WAYEditableCell";
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    UITableViewCell *cell = nil;
    if (row < [_data[section] count]) {
        cell = [tableView dequeueReusableCellWithIdentifier:WAYEditableCellIdentifier];
        if (cell == nil) {
            cell = [[[WAYEditableTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WAYEditableCellIdentifier] autorelease];
            ((WAYEditableTableViewCell *)cell).textField.delegate = self;
            ((WAYEditableTableViewCell *)cell).textField.returnKeyType = UIReturnKeyDone;
            ((WAYEditableTableViewCell *)cell).textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            ((WAYEditableTableViewCell *)cell).textField.autocorrectionType = UITextAutocorrectionTypeNo;
            UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLongPress:)];
            [cell addGestureRecognizer:gesture];
            [gesture release];
        }
        
        // Set up text field keyboard
        if (section == kTwitterSectionIndex) {
            // Use URL keyboard for twitter account cells
            ((WAYEditableTableViewCell *)cell).textField.keyboardType = UIKeyboardTypeURL;
            ((WAYEditableTableViewCell *)cell).textField.placeholder = @"URL";
        }
        else {
            // Use Number pad for phone number cells
            ((WAYEditableTableViewCell *)cell).textField.keyboardType = UIKeyboardTypePhonePad;
            ((WAYEditableTableViewCell *)cell).textField.placeholder = @"Phone";
        }
        
        if (_editingRowIndexPath && [_editingRowIndexPath compare:indexPath] == NSOrderedSame) {
            cell.contentView.userInteractionEnabled = YES;
        }
        else {
            cell.contentView.userInteractionEnabled = NO;
        }

        // Set up text field data
        NSDictionary *dataItem = [_data[section] objectAtIndex:row];
        ((WAYEditableTableViewCell *)cell).textField.text = [dataItem objectForKey:WAYDetailContactTextKey];
        ((WAYEditableTableViewCell *)cell).editingAccessoryType = [[dataItem objectForKey:WAYDetailContactIsSelectedKey] boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
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
    
    [tableView beginUpdates];
    if (_editingRowIndexPath && _editingTextField) {
        NSUInteger editingSection = [_editingRowIndexPath section];
        NSUInteger editingRow = [_editingRowIndexPath row];
        if ([_editingTextField.text length]) {
            // Save content of the editing text field.
            NSMutableDictionary *dataItem = [_data[editingSection] objectAtIndex:editingRow];
            [dataItem setObject:_editingTextField.text forKey:WAYDetailContactTextKey];
        }
        else if ([_editingRowIndexPath compare:indexPath] != NSOrderedSame) {
            // Remove the row, if it has no text.
            [_data[editingSection] removeObjectAtIndex:editingRow];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_editingRowIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            indexPath = [self _fixIndexPath:indexPath afterDeletionIndexPath:_editingRowIndexPath];
            [self _fixSelectedTwitterURLAfterDeletionIndexPath:_editingRowIndexPath];
        }
        [self _stopEditingTextField];
    }
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_data[section] removeObjectAtIndex:row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self _fixSelectedTwitterURLAfterDeletionIndexPath:indexPath];
        [tableView endUpdates];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        [self _insertNewObjectAtIndexPath:indexPath];
        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
        [self _startEditingTextFieldAtIndexPath:indexPath];
    }   
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView beginUpdates];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (_editingRowIndexPath && _editingTextField) {
        NSUInteger editingSection = [_editingRowIndexPath section];
        NSUInteger editingRow = [_editingRowIndexPath row];
        if ([_editingTextField.text length]) {
            // Save content of the editing text field.
            NSMutableDictionary *dataItem = [_data[editingSection] objectAtIndex:editingRow];
            [dataItem setObject:_editingTextField.text forKey:WAYDetailContactTextKey];
        }
        else {
            // Remove the row, if it has no text.
            [_data[editingSection] removeObjectAtIndex:editingRow];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_editingRowIndexPath] withRowAnimation:UITableViewRowAnimationFade];

            indexPath = [self _fixIndexPath:indexPath afterDeletionIndexPath:_editingRowIndexPath];
            [self _fixSelectedTwitterURLAfterDeletionIndexPath:_editingRowIndexPath];
        }
        [self _stopEditingTextField];
    }
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];    
    
    if (row < [_data[section] count]) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSMutableDictionary *dataItem = [_data[section] objectAtIndex:row];
        if (section == kTwitterSectionIndex) {
            // Only one twitter account can be seleted at the same time.
            if (row == _selectedTwitterAccount) {
                // User clicked on already selected row
                // Unmark it and set _selectedTwitterURL to NSUIntegerMax
                [dataItem setObject:[NSNumber numberWithBool:NO] forKey:WAYDetailContactIsSelectedKey];
                cell.editingAccessoryType = UITableViewCellAccessoryNone;
                _selectedTwitterAccount = NSUIntegerMax;
            }
            else {
                // Mark selected row
                [dataItem setObject:[NSNumber numberWithBool:YES] forKey:WAYDetailContactIsSelectedKey];
                cell.editingAccessoryType = UITableViewCellAccessoryCheckmark;
                if (_selectedTwitterAccount < [_twitterAccounts count]) {
                    // There is a row that is already marked. Unmark it.
                    [[_twitterAccounts objectAtIndex:_selectedTwitterAccount] setObject:[NSNumber numberWithBool:NO] forKey:WAYDetailContactIsSelectedKey];
                    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:_selectedTwitterAccount inSection:kTwitterSectionIndex];
                    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
                    oldCell.editingAccessoryType = UITableViewCellAccessoryNone;
                }
                _selectedTwitterAccount = row;
            }
        }
        else {
            // Just select and deselect phone number rows.
            if ([[dataItem objectForKey:WAYDetailContactIsSelectedKey] boolValue]) {
                [dataItem setObject:[NSNumber numberWithBool:NO] forKey:WAYDetailContactIsSelectedKey];
                cell.editingAccessoryType = UITableViewCellAccessoryNone;
            }
            else {
                [dataItem setObject:[NSNumber numberWithBool:YES] forKey:WAYDetailContactIsSelectedKey];
                cell.editingAccessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        [tableView endUpdates];
    }
    else {
        // Add button is pressed.
        [self _insertNewObjectAtIndexPath:indexPath];
        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
        [self _startEditingTextFieldAtIndexPath:indexPath];
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
    
    NSUInteger editingSection = [_editingRowIndexPath section];
    NSUInteger editingRow = [_editingRowIndexPath row];
    if ([_editingTextField.text length]) {
        // Save content of the editing text field.
        NSMutableDictionary *dataItem = [_data[editingSection] objectAtIndex:editingRow];
        [dataItem setObject:_editingTextField.text forKey:WAYDetailContactTextKey];
    }
    else {
        // Remove the row, if it has no text.
        [_data[editingSection] removeObjectAtIndex:editingRow];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_editingRowIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self _fixSelectedTwitterURLAfterDeletionIndexPath:_editingRowIndexPath];
    }
    [self _stopEditingTextField];
    return NO;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSAssert(_editingRowIndexPath != nil, @"_editingRowIndexPath must not be nil");
    if ([_editingRowIndexPath section] == kTwitterSectionIndex) {
        return YES;
    }
    else {
        NSScanner *scanner = [NSScanner scannerWithString:string];
        return [scanner scanInteger:NULL];
    }
}


#pragma mark -
#pragma mark Private

- (void)_updateData {
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, personID);
    if (person != NULL) {
        // Collect all urls that contain "twitter.com/" substring
        NSArray *urls = CollectUrlsThatContainString(person, (CFStringRef)@"twitter.com/");
        NSMutableArray *newUrls = [NSMutableArray arrayWithCapacity:[urls count]];
        for (NSString *url in urls) {
            // All rows are deselected by defauld
            NSMutableDictionary *selectableUrl = [NSMutableDictionary dictionaryWithObjectsAndKeys:url, WAYDetailContactTextKey, [NSNumber numberWithBool:NO], WAYDetailContactIsSelectedKey, nil];
            [newUrls addObject:selectableUrl];
        }
        self._twitterAccounts = newUrls;
        _data[kTwitterSectionIndex] = _twitterAccounts;
        _selectedTwitterAccount = NSUIntegerMax;
        
        // Collect all mobile phones
        NSArray *phones = CollectMobilePhones(person);
        NSMutableArray *newPhones = [NSMutableArray arrayWithCapacity:[phones count]];
        for (NSString *phone in phones) {
            // All phone are selected by default
            NSMutableDictionary *selectablePhone = [NSMutableDictionary dictionaryWithObjectsAndKeys:phone, WAYDetailContactTextKey, [NSNumber numberWithBool:YES], WAYDetailContactIsSelectedKey, nil];
            [newPhones addObject:selectablePhone];
        }
        self._mobilePhones = newPhones;
        _data[kPhonesSectionIndex] = _mobilePhones;
        
        self.title = (NSString *)ABRecordCopyCompositeName(person);
    }
    CFRelease(addressBook);
}


- (void)_insertNewObjectAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    NSMutableDictionary *newDataItem = [[NSMutableDictionary alloc] init];        
    if (section == kTwitterSectionIndex) {
        [newDataItem setObject:[NSNumber numberWithBool:NO] forKey:WAYDetailContactIsSelectedKey];
    }
    else {
        [newDataItem setObject:[NSNumber numberWithBool:YES] forKey:WAYDetailContactIsSelectedKey];
    }
    [_data[section] insertObject:newDataItem atIndex:row];
    [newDataItem release];
}


- (void)_startEditingTextFieldAtIndexPath:(NSIndexPath *)indexPath {
    
    WAYEditableTableViewCell *cell = (WAYEditableTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.userInteractionEnabled = YES;
    self._editingRowIndexPath = indexPath;
    self._editingTextField = cell.textField;
    [cell.textField becomeFirstResponder];
}


- (void)_stopEditingTextField {
    
    NSAssert(_editingRowIndexPath != nil, @"_editingRowIndexPath must not be nil");
    NSAssert(_editingTextField != nil, @"_editingTextField must not be nil");
    
    [_editingTextField resignFirstResponder];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_editingRowIndexPath];
    cell.contentView.userInteractionEnabled = NO;
    self._editingTextField = nil;
    self._editingRowIndexPath = nil;
}


- (NSIndexPath *)_fixIndexPath:(NSIndexPath *)indexPath afterDeletionIndexPath:(NSIndexPath *)indexPathToDelete {
    
    NSAssert(indexPath != nil, @"indexPath must not be nil");
    NSAssert(indexPathToDelete != nil, @"indexPathToDelete must not be nil");
    
    if ([indexPath section] == [indexPathToDelete section] && [indexPath row] > [indexPathToDelete row]) {
        indexPath = [NSIndexPath indexPathForRow:([indexPath row] - 1) inSection:[indexPath section]];
    }
    return indexPath;
}


- (void)_fixSelectedTwitterURLAfterDeletionIndexPath:(NSIndexPath *)indexPathToDelete {
    
    NSAssert(indexPathToDelete != nil, @"indexPathToDelete must not be nil");
    
    if ([indexPathToDelete section] == kTwitterSectionIndex && _selectedTwitterAccount < [_twitterAccounts count]) {
        if ([indexPathToDelete row] == _selectedTwitterAccount) {
            // When we delete marked twitter url, we have to set _selectedTwitterURL to NSUIntegerMax
            _selectedTwitterAccount = NSUIntegerMax;
        }
        else if ([indexPathToDelete row] < _selectedTwitterAccount) {
            _selectedTwitterAccount -= 1;
        }
    }
}


- (void)_done:(id)sender {
    
    NSString *twitterAccount = nil;
    if (_selectedTwitterAccount < [_twitterAccounts count]) {
        twitterAccount = [_twitterAccounts objectAtIndex:_selectedTwitterAccount];
        NSRange range = [twitterAccount rangeOfString:@"twitter.com/"];
        if (range.location != NSNotFound) {
            twitterAccount = [twitterAccount substringFromIndex:(range.location + range.length)];
        }
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = YES", WAYDetailContactIsSelectedKey];
    NSArray *selectedPhones = [[_mobilePhones filteredArrayUsingPredicate:predicate] valueForKey:WAYDetailContactTextKey];
    [delegate detailContactViewController:self didDoneWithTwitterAccount:twitterAccount phoneNumbers:selectedPhones];
}


- (void)_handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[gestureRecognizer locationInView:self.tableView]];
        if (_editingRowIndexPath && _editingTextField) {
            NSUInteger editingSection = [_editingRowIndexPath section];
            NSUInteger editingRow = [_editingRowIndexPath row];
            if ([_editingTextField.text length]) {
                // Save content of the editing text field.
                NSMutableDictionary *dataItem = [_data[editingSection] objectAtIndex:editingRow];
                [dataItem setObject:_editingTextField.text forKey:WAYDetailContactTextKey];
            }
            else {
                // Remove the row, if it has no text.
                [_data[editingSection] removeObjectAtIndex:editingRow];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_editingRowIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                
                indexPath = [self _fixIndexPath:indexPath afterDeletionIndexPath:_editingRowIndexPath];
                [self _fixSelectedTwitterURLAfterDeletionIndexPath:_editingRowIndexPath];
            }
            [self _stopEditingTextField];
        }
        // Enable content view of touched cell
        [self _startEditingTextFieldAtIndexPath:indexPath];
    }
}

@end

