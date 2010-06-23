#import "WAYDetailContactViewController.h"
#import "AddressBookAdditions.h"


@interface WAYDetailContactViewController ()

// Reloads data from address book
- (void)reloadData;

// Done button was pressed
- (void)done:(id)sender;

// Layouts cell with text field on label place
- (void)layoutCellWithTextField:(UITableViewCell *)cell;

- (void)keyboardDidShow:(NSNotification *)notification;
   
@end


#pragma mark -
#pragma mark Local constants

enum {
    kTwitterSectionIndex = 0,
    kPhonesSectionIndex = 1
};

static NSString * const kTextKey = @"text";
static NSString * const kIsSelectedKey = @"isSelected";
static NSString * const kIsEditingKey = @"isEditing";

static const NSUInteger kTextFieldTag = 100;


@implementation WAYDetailContactViewController
@synthesize personID;
@synthesize delegate;
@synthesize twitterUrls;
@synthesize mobilePhones;

#pragma mark -
#pragma mark Initialization

- (void)dealloc {
    [twitterUrls release];
    [mobilePhones release];
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
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [self addObserver:self forKeyPath:@"twitterUrls" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"mobilePhones" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // Clean up undo manager
    [self resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:@"twitterUrls"];
    [self removeObserver:self forKeyPath:@"mobilePhones"];
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
        NSDictionary *dataItem = [_data[section] objectAtIndex:row];
        textField.text = [dataItem objectForKey:kTextKey];
        cell.editingAccessoryType = [[dataItem objectForKey:kIsEditingKey] boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        if ([[dataItem objectForKey:kIsEditingKey] boolValue]) {
            textField.userInteractionEnabled = YES;
            cell.userInteractionEnabled = NO;
            [textField becomeFirstResponder];
        }
        else {
            [textField resignFirstResponder];
            cell.userInteractionEnabled = YES;
            textField.userInteractionEnabled = NO;
        }
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
        if ([indexPath section] == kTwitterSectionIndex) {
            [self removeObjectFromTwitterUrlsAtIndex:[indexPath row]];
        }
        else {
            [self removeObjectFromMobilePhonesAtIndex:[indexPath row]];
        }
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        NSMutableDictionary *newObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", kTextKey, 
                                          [NSNumber numberWithBool:YES], kIsSelectedKey,
                                          [NSNumber numberWithBool:YES], kIsEditingKey, nil];
        if ([indexPath section] == kTwitterSectionIndex) {
            [self insertObject:newObject inTwitterUrlsAtIndex:[indexPath row]];
        }
        else {
            [self insertObject:newObject inMobilePhonesAtIndex:[indexPath row]];
        }
    }   
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    //[self stopEditingTextField];
    return NO;
}


#pragma mark -
#pragma mark Private

- (NSUInteger)countOfTwitterUrls {
    return [twitterUrls count];
}


- (id)objectInTwitterUrlsAtIndex:(NSUInteger)index {
    return [twitterUrls objectAtIndex:index];
}


- (void)insertObject:(NSMutableDictionary *)object inTwitterUrlsAtIndex:(NSUInteger)index {
    [twitterUrls insertObject:object atIndex:index];
}


- (void)removeObjectFromTwitterUrlsAtIndex:(NSUInteger)index {
    [twitterUrls removeObjectAtIndex:index];
}


- (void)replaceObjectInTwitterUrlsAtIndex:(NSUInteger)index withObject:(NSMutableDictionary *)object {
    [twitterUrls replaceObjectAtIndex:index withObject:object];
}


- (NSUInteger)countOfMobilePhones {
    return [mobilePhones count];
}


- (id)objectInMobilePhonesAtIndex:(NSUInteger)index {
    return [mobilePhones objectAtIndex:index];
}


- (void)insertObject:(NSMutableDictionary *)object inMobilePhonesAtIndex:(NSUInteger)index {
    [mobilePhones insertObject:object atIndex:index];
}


- (void)removeObjectFromMobilePhonesAtIndex:(NSUInteger)index {
    [mobilePhones removeObjectAtIndex:index];
}


- (void)replaceObjectInMobilePhonesAtIndex:(NSUInteger)index withObject:(NSMutableDictionary *)object {
    [mobilePhones replaceObjectAtIndex:index withObject:object];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    NSKeyValueChange type = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];
    [self.tableView beginUpdates];
    if (type == NSKeyValueChangeInsertion) {
        NSIndexSet *indexesToRemove = [change objectForKey:NSKeyValueChangeIndexesKey];
        NSUInteger indexesCount = [indexesToRemove count];
        NSUInteger *buffer = calloc(indexesCount, sizeof(NSUInteger));
        [indexesToRemove getIndexes:buffer maxCount:indexesCount inIndexRange:nil];
        NSUInteger section = [keyPath isEqualToString:@"twitterUrls"] ? kTwitterSectionIndex : kPhonesSectionIndex;
        NSUInteger i;
        for (i=0; i<indexesCount; ++i) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:buffer[i] inSection:section];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        }
        free(buffer);
    }
    else if (type = NSKeyValueChangeRemoval) {
        NSIndexSet *indexesToRemove = [change objectForKey:NSKeyValueChangeIndexesKey];
        NSUInteger indexesCount = [indexesToRemove count];
        NSUInteger *buffer = calloc(indexesCount, sizeof(NSUInteger));
        [indexesToRemove getIndexes:buffer maxCount:indexesCount inIndexRange:nil];
        NSUInteger section = [keyPath isEqualToString:@"twitterUrls"] ? kTwitterSectionIndex : kPhonesSectionIndex;
        NSUInteger i;
        for (i=0; i<indexesCount; ++i) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:buffer[i] inSection:section];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        }
        free(buffer);
    }
    [self.tableView reloadData];
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
        self.twitterUrls = newUrls;
        _data[kTwitterSectionIndex] = twitterUrls;
        
        // Collect all mobile phones
        NSArray *phones = CollectMobilePhones(person);
        NSMutableArray *newPhones = [NSMutableArray arrayWithCapacity:[phones count]];
        for (NSString *phone in phones) {
            // All phone are selected by default
            NSMutableDictionary *selectablePhone = [NSMutableDictionary dictionaryWithObjectsAndKeys:phone, kTextKey, [NSNumber numberWithBool:YES], kIsSelectedKey, nil];
            [newPhones addObject:selectablePhone];
        }
        self.mobilePhones = newPhones;
        _data[kPhonesSectionIndex] = mobilePhones;
        
        self.title = (NSString *)ABRecordCopyCompositeName(person);
    }
    CFRelease(addressBook);
}


- (void)done:(id)sender {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isSelected = YES"];
    NSArray *selectedUrls = [[twitterUrls filteredArrayUsingPredicate:predicate] valueForKey:kTextKey];
    NSArray *selectedPhones = [[mobilePhones filteredArrayUsingPredicate:predicate] valueForKey:kTextKey];
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


@end

