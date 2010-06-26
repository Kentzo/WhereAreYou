#import "WAYDetailContactViewController.h"
#import "WAYEditableTableViewCell.h"
#import "AddressBookAdditions.h"


enum {
    kTwitterSectionIndex = 0,
    kPhonesSectionIndex = 1
};

static NSString * const WAYDetailContactTextKey = @"WAYDetailContactTextKey";
static NSString * const WAYDetailContactIsSelectedKey = @"WAYDetailContactIsSelectedKey";

@interface WAYDetailContactViewController ()
@property (nonatomic, readwrite, retain) NSArray *_twitterUrls;
@property (nonatomic, readwrite, retain) NSArray *_mobilePhones;
@property (nonatomic, retain) NSIndexPath *_editingRowIndexPath;
@property (nonatomic, assign) UITextField *_editingTextField;

// Reloads data from address book
- (void)_updateData;

// Done button was pressed
- (void)_done:(id)sender;

- (void)_keyboardDidShow:(NSNotification *)notification;
- (void)_handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer;

// Starts editing text field. Makes it first responder.
- (void)_startEditingTextFieldAtIndexPath:(NSIndexPath *)indexPath;

// Stops editing text field, saves changes. If text field is empty, removes a row.
// In some cases it is needed to fix indexPath when row is removed. Just provide old index path and you get fixed index path in as a result
- (NSIndexPath *)_stopEditingTextFieldAndFixIndexPath:(NSIndexPath *)indexPath;

   
@end


@implementation WAYDetailContactViewController
@synthesize personID;
@synthesize delegate;
@synthesize _twitterUrls;
@synthesize _mobilePhones;
@synthesize _editingRowIndexPath;
@synthesize _editingTextField;

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
    [self _updateData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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
    indexPath = [self _stopEditingTextFieldAndFixIndexPath:indexPath];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_data[[indexPath section]] removeObjectAtIndex:[indexPath row]];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        NSMutableDictionary *newDataItem = [[NSMutableDictionary alloc] init];        
        if ([indexPath section] == kTwitterSectionIndex) {
            [newDataItem setObject:[NSNumber numberWithBool:NO] forKey:WAYDetailContactIsSelectedKey];
        }
        else {
            [newDataItem setObject:[NSNumber numberWithBool:YES] forKey:WAYDetailContactIsSelectedKey];
        }
        [_data[[indexPath section]] insertObject:newDataItem atIndex:[indexPath row]];
        [newDataItem release];
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
    indexPath = [self _stopEditingTextFieldAndFixIndexPath:indexPath];
    
    if ([indexPath row] < [_data[[indexPath section]] count]) {
        if ([indexPath section] == kTwitterSectionIndex) {
            
        }
        else {
            NSMutableDictionary *dataItem = [_mobilePhones objectAtIndex:[indexPath row]];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
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
        // Add button
        NSMutableDictionary *newDataItem = [[NSMutableDictionary alloc] init];        
        if ([indexPath section] == kTwitterSectionIndex) {
            [newDataItem setObject:[NSNumber numberWithBool:NO] forKey:WAYDetailContactIsSelectedKey];
        }
        else {
            [newDataItem setObject:[NSNumber numberWithBool:YES] forKey:WAYDetailContactIsSelectedKey];
        }
        [_data[[indexPath section]] insertObject:newDataItem atIndex:[indexPath row]];
        [newDataItem release];
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
    [self _stopEditingTextFieldAndFixIndexPath:nil];
    return NO;
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
        self._twitterUrls = newUrls;
        _data[kTwitterSectionIndex] = _twitterUrls;
        
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


- (void)_done:(id)sender {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = YES", WAYDetailContactIsSelectedKey];
    NSArray *selectedUrls = [[_twitterUrls filteredArrayUsingPredicate:predicate] valueForKey:WAYDetailContactTextKey];
    NSString *twitterUrl = nil;
    if ([selectedUrls count]) {
        twitterUrl = [selectedUrls objectAtIndex:0];
    }
    NSArray *selectedPhones = [[_mobilePhones filteredArrayUsingPredicate:predicate] valueForKey:WAYDetailContactTextKey];
    [delegate detailContactViewController:self didDoneWithTwitterURL:twitterUrl phoneNumbers:selectedPhones];
}


- (void)_keyboardDidShow:(NSNotification *)notification {
    if (_editingRowIndexPath != nil) {
        [self.tableView scrollToRowAtIndexPath:_editingRowIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}


- (void)_handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // Enable content view of touched cell
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[gestureRecognizer locationInView:self.tableView]];
        [self _startEditingTextFieldAtIndexPath:indexPath];
    }
}


- (void)_startEditingTextFieldAtIndexPath:(NSIndexPath *)indexPath {
    WAYEditableTableViewCell *cell = (WAYEditableTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.userInteractionEnabled = YES;
    self._editingRowIndexPath = indexPath;
    [cell.textField becomeFirstResponder];
    self._editingTextField = ((WAYEditableTableViewCell *)cell).textField;
}


- (NSIndexPath *)_stopEditingTextFieldAndFixIndexPath:(NSIndexPath *)indexPath {

    if (_editingRowIndexPath && _editingTextField) {
        if ([_editingTextField.text length]) {
            NSMutableDictionary *dataItem = [_data[[_editingRowIndexPath section]] objectAtIndex:[_editingRowIndexPath row]];
            [dataItem setObject:_editingTextField.text forKey:WAYDetailContactTextKey];
        }
        else {
            // Remove row, if it has no text
            [_data[[_editingRowIndexPath section]] removeObjectAtIndex:[_editingRowIndexPath row]];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_editingRowIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            if (indexPath && [indexPath section] == [_editingRowIndexPath section] && [indexPath row] > [_editingRowIndexPath row]) {
                indexPath = [NSIndexPath indexPathForRow:([indexPath row] - 1) inSection:[indexPath section]];
            }
        }
        [_editingTextField resignFirstResponder];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_editingRowIndexPath];
        cell.contentView.userInteractionEnabled = NO;
        self._editingRowIndexPath = nil;
        self._editingTextField = nil;
    }
    
    return indexPath;
}

@end

