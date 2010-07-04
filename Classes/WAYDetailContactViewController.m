#import "WAYDetailContactViewController.h"
#import "WAYEditableTableViewCell.h"
#import "AddressBookAdditions.h"
#import "Contact.h"
#import "Phone.h"


/*!
 * @enum Sections
 * @abstract Indexes of table view sections.
 * @constant kTwitterSectionIndex Section for twitter account.
 * @constant kPhonesSectionIndex Section for phone numbers.
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
static NSString * const WAYDetailContactIsCheckingKey = @"WAYDetailContactIsCheckingKey";

@interface WAYDetailContactViewController (/* Private stuff here */)

/*!
 * @property _editingRowIndexPath
 * @abstract Keeps index path of currently edited row.
 * @discussion Has value only when there is a row that is being edited. Otherwise nil.
 */
@property (nonatomic, retain) NSIndexPath *_editingRowIndexPath;

@property (nonatomic, retain) NSIndexPath *_currentIndexPath;

/*!
 * @property _editingRowIndexPath
 * @abstract Keeps pointer to UITextField in currently edited row.
 * @discussion Has value only when some row is edited. Otherwise nil.
 */
@property (nonatomic, assign) UITextField *_editingTextField;

/*!
 * @property _nonDecimalDigits
 * @abstract NSCharacterSet that represents all characters except of decimal digits.
 */
@property (nonatomic, retain) NSCharacterSet *_nonDecimalDigits;

/*!
 * @method _stopEditingTextField
 * @abstract Stops editing cell at index path _editingRowIndexPath.
 * @discussion Resigns first responder, switches contentView.userInteractionEnabled to NO and nullyfies _editingRowIndexPath and _editingTextField.
 */
- (void)_stopEditingTextField;

/*!
 * @method _textFieldValueChanged:
 * @abstract Is called when value of any textfield is changed
 */
- (void)_textFieldValueChanged:(UITextField *)sender;

@end


@implementation WAYDetailContactViewController
@synthesize contact;
@synthesize phoneFormatter;
@synthesize _editingRowIndexPath;
@synthesize _currentIndexPath;
@synthesize _editingTextField;
@synthesize _nonDecimalDigits;

#pragma mark -
#pragma mark Initialization

- (void)dealloc {
    [contact release];
    [phoneFormatter release];
    [_editingRowIndexPath release];
    [_currentIndexPath release];
    [_contactMobilePhones release];
    [_nonDecimalDigits release];
    [super dealloc];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsSelectionDuringEditing = YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [contact addObserver:self forKeyPath:@"phones" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [self.tableView reloadData];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [contact removeObserver:self forKeyPath:@"phones"];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    self._nonDecimalDigits = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_contactMobilePhones count] inSection:kPhonesSectionIndex];
    if (animated) {
        if (editing) {
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        else {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    else {
        [self.tableView reloadData];
    }
}


#pragma mark -
#pragma mark Data managment

- (void)setContact:(Contact *)newContact {
    [newContact retain];
    [contact release];
    contact = newContact;
    [_contactMobilePhones release];
    _contactMobilePhones = [[contact.phones allObjects] mutableCopy];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"phone" ascending:YES];
    [_contactMobilePhones sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [sortDescriptor release];
    self.title = contact.name;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    NSKeyValueChange changeType = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];
    if ([keyPath isEqualToString:@"phones"]) { // Contact
        if (changeType == NSKeyValueChangeRemoval)
        {
            // Collect indexes of removed objects in _contactMobilePhones.
            NSArray *removedObjects = [change objectForKey:NSKeyValueChangeOldKey];
            NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
            for (Phone *phone in removedObjects) {
                [indexSet addIndex:[_contactMobilePhones indexOfObjectIdenticalTo:phone]];
            }
            
            [self removePhonesAtIndexes:indexSet];

            [indexSet release];
        }
        else if (changeType == NSKeyValueChangeInsertion) {
            
            // Collect indexes of inserted objects.
            // Objects will be insertes at the end of _contactMobilePhones.
            NSArray *insertedObjects = [[change objectForKey:NSKeyValueChangeNewKey] allObjects];
            NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
            NSUInteger index = [_contactMobilePhones count];
            for (Phone *phone in insertedObjects) {
                [indexSet addIndex:index++];
            }
            
            [self insertPhones:insertedObjects atIndexes:indexSet];
            
            [indexSet release];
        }
    }
}


- (void)insertPhones:(NSArray *)phones atIndexes:(NSIndexSet *)indexSet {
    
    // Extract indexes to C array.
    NSUInteger count = [indexSet count];
    NSUInteger *indexes = calloc(count, sizeof(NSUInteger));
    [indexSet getIndexes:indexes maxCount:count inIndexRange:nil];
    
    // Create index paths from indexes in order to delete them from the table.
    [_contactMobilePhones insertObjects:phones atIndexes:indexSet];

    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:count];
    NSUInteger i;
    for (i=0; i<count; ++i) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:indexes[i] inSection:kPhonesSectionIndex]];
    }
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    [indexPaths release];
    free(indexes), indexes = NULL;
}


- (void)removePhonesAtIndexes:(NSIndexSet *)indexSet {
    
    // Extract indexes to C array.
    NSUInteger count = [indexSet count];
    NSUInteger *indexes = calloc(count, sizeof(NSUInteger));
    [indexSet getIndexes:indexes maxCount:count inIndexRange:nil];
    
    [_contactMobilePhones removeObjectsAtIndexes:indexSet];
    
    // Update _currentIndexPath if needed.
    if (_currentIndexPath != nil && [_currentIndexPath section] == kPhonesSectionIndex) {
        NSUInteger i, currentRow, countOfUpperRows;
        for (i=0, currentRow=[_currentIndexPath row], countOfUpperRows=0; i<count; ++i) {
            if (indexes[i] < currentRow) {
                ++countOfUpperRows;
            }
            else if (indexes[i] == currentRow) {
                self._currentIndexPath = nil;
                break;
            }
            
        }
        if (_currentIndexPath != nil) {
            self._currentIndexPath = [NSIndexPath indexPathForRow:(currentRow - countOfUpperRows) inSection:kPhonesSectionIndex];
        }
    }
    
    // Create index paths from indexes in order to delete them from the table.
    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:count];
    NSUInteger i;
    for (i=0; i<count; ++i) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:indexes[i] inSection:kPhonesSectionIndex]];
    }
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    [indexPaths release];
    
    free(indexes), indexes = NULL;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case kTwitterSectionIndex:
            return 1;
        case kPhonesSectionIndex:
            // Return number of phones + 1 for add button
            if ([self isEditing]) {
                return [_contactMobilePhones count] + 1;
            }
            else {
                return [_contactMobilePhones count];
            }
        default:
            NSAssert(NO, @"You've added new section, but forget add hook here");
            return 0;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case kTwitterSectionIndex:
            return @"Twitter account";
        case kPhonesSectionIndex:
            return @"Phone numbers";
        default:
            NSAssert(NO, @"You've added new section, but forget add hook here");
            return nil;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case kTwitterSectionIndex:
            return nil;
        case kPhonesSectionIndex:
            return @"Including country code\nAt least one number";
        default:
            NSAssert(NO, @"You've added new section, but forget add hook here");
            return nil;
    }
}
 

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *AddCellIdentifier = @"AddCell";
    static NSString *WAYEditableCellIdentifier = @"WAYEditableCell";
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    if (section == kTwitterSectionIndex || section == kPhonesSectionIndex && row < [_contactMobilePhones count]) {
        WAYEditableTableViewCell *cell = (WAYEditableTableViewCell *)[tableView dequeueReusableCellWithIdentifier:WAYEditableCellIdentifier];
        if (cell == nil) {
            cell = [[[WAYEditableTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WAYEditableCellIdentifier] autorelease];
            cell.textField.delegate = self;
            [cell.textField addTarget:self action:@selector(_textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
            cell.textField.returnKeyType = UIReturnKeyDone;
            cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (section == kTwitterSectionIndex) {
            // Use URL keyboard for twitter account cells
            cell.textField.keyboardType = UIKeyboardTypeURL;
            cell.textField.placeholder = @"URL";
            
            cell.textField.text = contact.twitter;
        }
        else {
            // Use Number pad for phone number cells
            cell.textField.keyboardType = UIKeyboardTypePhonePad;
            cell.textField.placeholder = @"Phone";
            
            cell.textField.text = [self.phoneFormatter stringFromPhoneNumber:[[_contactMobilePhones objectAtIndex:row] valueForKey:@"phone"]];
        }
        
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AddCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AddCellIdentifier] autorelease];
            // Make text color like text color of add row in Contacts.app on iPhone
            cell.textLabel.textColor = [UIColor colorWithRed:0.294 green:0.345 blue:0.447 alpha:1.0];
        }
        cell.textLabel.text = @"Add new";
        
        return cell;
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // User can edit only phone numbers section
    return [indexPath section] == kPhonesSectionIndex;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
        
    NSAssert([indexPath section] == kPhonesSectionIndex, @"User can edit only phone numbers section");
    
    self._currentIndexPath = indexPath;
    if (_editingRowIndexPath != nil) {
        [self _stopEditingTextField];
    }
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // If user tries to delete currently edited row which has text field with no text, do nothing,
        // because this row was deleted after commiting changes.
        if (_currentIndexPath != nil) {
            Phone *phone = [_contactMobilePhones objectAtIndex:[_currentIndexPath row]];
            [contact.managedObjectContext deleteObject:phone];
            [contact removePhonesObject:phone];
        }
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        Phone *newPhone = [NSEntityDescription insertNewObjectForEntityForName:@"Phone" inManagedObjectContext:contact.managedObjectContext];
        newPhone.contact = contact;
        WAYEditableTableViewCell *cell = (WAYEditableTableViewCell *)[tableView cellForRowAtIndexPath:_currentIndexPath];
        [cell.textField becomeFirstResponder];
    }
    self._currentIndexPath = nil;
}


#pragma mark -
#pragma mark Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath section] == kPhonesSectionIndex && [indexPath row] == [_contactMobilePhones count]) {
        return indexPath;
    }
    else {
        return nil;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSAssert([indexPath section] == kPhonesSectionIndex, @"User can edit only phone numbers section");
    
    [self.tableView beginUpdates];
    self._currentIndexPath = indexPath;
    if (_editingRowIndexPath != nil) {
        [self _stopEditingTextField];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Phone *newPhone = [NSEntityDescription insertNewObjectForEntityForName:@"Phone" inManagedObjectContext:contact.managedObjectContext];
    newPhone.contact = contact;
    [self.tableView endUpdates];
    WAYEditableTableViewCell *cell = (WAYEditableTableViewCell *)[tableView cellForRowAtIndexPath:_currentIndexPath];
    [cell.textField becomeFirstResponder];
    self._currentIndexPath = nil;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Use UITableViewCellEditingStyleDelete style for all rows except add buttons. Use UITableViewCellEditingStyleInsert for them.
    if ([indexPath row] < [_contactMobilePhones count]) {
        return UITableViewCellEditingStyleDelete;
    }
    else {
        return UITableViewCellEditingStyleInsert;
    }
}


#pragma mark -
#pragma mark Text Input

- (PhoneNumberFormatter *)phoneFormatter {
    if (phoneFormatter == nil) {
        phoneFormatter = [[PhoneNumberFormatter alloc] init];
    }
    return phoneFormatter;
}


- (NSCharacterSet *)_nonDecimalDigits {
    if (_nonDecimalDigits == nil) {
        self._nonDecimalDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    }
    return _nonDecimalDigits;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [self _stopEditingTextField];
    return NO;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (_editingRowIndexPath != nil) {
        [self _stopEditingTextField];
    }
    
    CGPoint point = [self.tableView convertPoint:textField.frame.origin fromView:textField.superview];
    self._editingRowIndexPath = [self.tableView indexPathForRowAtPoint:point];
    self._editingTextField = textField;
    
    // Remove formatting from string
    if ([_editingRowIndexPath section] == kPhonesSectionIndex) {
        Phone *phone = [_contactMobilePhones objectAtIndex:[_editingRowIndexPath row]];
        textField.text = [phone.phone stringValue];
    }
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    NSAssert(_editingRowIndexPath != nil, @"_editingRowIndexPath must not be nil");
    
    if ([_editingRowIndexPath section] == kPhonesSectionIndex) {
        if (![textField.text length]) {
            // Remove phone if it has no value
            [contact removePhonesObject:[_contactMobilePhones objectAtIndex:[_editingRowIndexPath row]]];
        }
        else {
            // Format textfield
            Phone *phone = [_contactMobilePhones objectAtIndex:[_editingRowIndexPath row]];
            textField.text = [phoneFormatter stringFromPhoneNumber:phone.phone];
        }
    }
    
    self._editingTextField = nil;
    self._editingRowIndexPath = nil;
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    // User can edit rows only in editing mode.
    return [self isEditing];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSParameterAssert(textField == _editingTextField);
    
    NSString *inputString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([_editingRowIndexPath section] == kPhonesSectionIndex && (
                                                                  [string rangeOfCharacterFromSet:self._nonDecimalDigits].location != NSNotFound  || 
                                                                  range.location == 0 && [string hasPrefix:@"0"] ||
                                                                  [inputString length] >= 20
                                                                  ))
    {
        return NO;
    }
    else {
        return YES;
    }
}


- (void)_textFieldValueChanged:(UITextField *)sender {
    
    if ([sender isEditing]) {
        NSParameterAssert(sender == _editingTextField);
        if ([_editingRowIndexPath section] == kPhonesSectionIndex) {
            Phone *phone = [_contactMobilePhones objectAtIndex:[_editingRowIndexPath row]];
            phone.phone = [NSNumber numberWithLongLongFromString:sender.text];
        }
        else if ([_editingRowIndexPath section] == kTwitterSectionIndex) {
            contact.twitter = sender.text;
        }
    }
}


#pragma mark -
#pragma mark Private

- (void)_stopEditingTextField {
    
    NSAssert(_editingRowIndexPath != nil, @"_editingRowIndexPath must not be nil");
    NSAssert(_editingTextField != nil, @"_editingTextField must not be nil");

    [_editingTextField resignFirstResponder];
    [self becomeFirstResponder];
}

@end

