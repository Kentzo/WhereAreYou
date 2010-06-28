#import "WAYDetailContactViewController.h"
#import "WAYEditableTableViewCell.h"
#import "Contact.h"

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

@interface WAYDetailContactViewController ()

/*!
 * @property _editingRowIndexPath
 * @abstract Keeps index path of currently edited row.
 * @discussion Has value only when some row is edited. Otherwise nil.
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
 * @method _stopEditingTextField
 * @abstract Stops editing cell at index path _editingRowIndexPath.
 * @discussion Resigns first responder, switches contentView.userInteractionEnabled to NO and nullyfies _editingRowIndexPath and _editingTextField.
 */
- (void)_stopEditingTextField;

@end


@implementation WAYDetailContactViewController
@synthesize contact;
@synthesize phoneFormatter;
@synthesize _editingRowIndexPath;
@synthesize _currentIndexPath;
@synthesize _editingTextField;

#pragma mark -
#pragma mark Initialization

- (void)dealloc {
    [contact release];
    [phoneFormatter release];
    [_editingRowIndexPath release];
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
    self.title = contact.name;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    NSKeyValueChange changeType = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];
    if ([keyPath isEqualToString:@"phones"]) {
        if (changeType == NSKeyValueChangeRemoval)
        {
            // Collect indexes of removed objects in _contactMobilePhones.
            NSArray *removedObjects = [change objectForKey:NSKeyValueChangeOldKey];
            NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
            for (NSManagedObject *phone in removedObjects) {
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
            for (NSManagedObject *phone in insertedObjects) {
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
    
    // Remove objects at indexes.
    [_contactMobilePhones removeObjectsAtIndexes:indexSet];
    
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
            return @"";
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case kPhonesSectionIndex:
            return @"Including country code\nAt least one number";
        default:
            return nil;
    }
}
 

// Customize the appearance of table view cells.
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
            NSString *text = [[_contactMobilePhones objectAtIndex:row] valueForKey:@"phone"];
            if ([text isKindOfClass:[NSNull class]]) {
                text = @"";
            }
            cell.textField.text = text;
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
    [self.tableView beginUpdates];
    if (_editingRowIndexPath != nil) {
        [self _stopEditingTextField];
    }
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // If user tries to delete currently edited row which has text field with no text, do nothing,
        // because this row was deleted after commiting changes.
        if (_currentIndexPath != nil) {
            [contact removePhonesObject:[_contactMobilePhones objectAtIndex:[_currentIndexPath row]]];
        }
        [self.tableView endUpdates];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        NSManagedObject *newPhone = [NSEntityDescription insertNewObjectForEntityForName:@"Phone" inManagedObjectContext:contact.managedObjectContext];
        [newPhone setValue:contact forKey:@"contact"];
        [contact addPhonesObject:newPhone];
        [self.tableView endUpdates];
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
    
    NSManagedObject *newPhone = [NSEntityDescription insertNewObjectForEntityForName:@"Phone" inManagedObjectContext:contact.managedObjectContext];
    [newPhone setValue:contact forKey:@"contact"];
    [contact addPhonesObject:newPhone];
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
#pragma mark Text editing

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [self _stopEditingTextField];
    return NO;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (_editingRowIndexPath != nil) {
        [self _stopEditingTextField];
    }
    
    CGPoint point = [self.tableView convertPoint:textField.frame.origin fromView:textField];
    self._editingRowIndexPath = [self.tableView indexPathForRowAtPoint:point];
    self._editingTextField = textField;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    NSAssert(_editingRowIndexPath != nil, @"_editingRowIndexPath must not be nil");
    
    if ([_editingRowIndexPath section] == kPhonesSectionIndex && ![textField.text length]) {
        [contact removePhonesObject:[_contactMobilePhones objectAtIndex:[_editingRowIndexPath row]]];
    }
    
    self._editingTextField = nil;
    self._editingRowIndexPath = nil;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSAssert(textField == _editingTextField, @"You are changing textfield, that isn't marked as _editingTextField");
    
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self setText:text forRowAtIndexPath:_editingRowIndexPath];
    return YES;
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textFiel {
    // User can edit rows only in editing mode.
    return [self isEditing];
}


- (void)setText:(NSString *)text forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch ([indexPath section]) {
        case kTwitterSectionIndex:
            contact.twitter = text;
            break;
        case kPhonesSectionIndex:
            [[_contactMobilePhones objectAtIndex:[indexPath row]] setValue:text forKey:@"phone"];
            break;
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

