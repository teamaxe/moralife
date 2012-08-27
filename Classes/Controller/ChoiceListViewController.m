/**
Implementation:  Present User with list of User-entered Choices.  Dilemma-entered choices are filtered from view.
UITableView is populated by a second set of container arrays, so that we can search on that data set without having to refetch.
Refetches of table data are necessary when sorting and ordering are requested.

@class ChoiceListViewController ChoiceListViewController.h
 */

#import "ChoiceListViewController.h"
#import "MoraLifeAppDelegate.h"
#import "ChoiceViewController.h"
#import "ChoiceHistoryModel.h"
#import "ViewControllerLocalization.h"

@interface ChoiceListViewController () <ViewControllerLocalization> {
	
	MoraLifeAppDelegate *appDelegate;		/**< delegate for application level callbacks */
	NSUserDefaults *prefs;				/**< serialized user settings/state retention */
    
	//Data for filtering/searching sourced from raw data
	NSMutableArray *dataSource;			/**< array for storing of Choices populated from previous view*/
	NSMutableArray *tableData;			/**< array for stored data displayed in table populated from dataSource */
	NSMutableArray *tableDataColorBools;	/**< array for stored data booleans for Virtue/Vice distinction */
	NSMutableArray *tableDataImages;		/**< array for stored data images */
	NSMutableArray *tableDataDetails;		/**< array for stored data details */
	NSMutableArray *tableDataKeys;		/**< array for stored data primary keys */
	
	IBOutlet UISearchBar *choiceSearchBar;	/**< ui element for limiting choices in table */
	
	IBOutlet UITableView *choicesTableView;	/**< table of User choices*/
	IBOutlet UIView *choicesView;			/**< ui surrounding tableview */
    
	IBOutlet UIButton *moralSortButton;		/**< button for sorting criteria */
	IBOutlet UIButton *moralOrderButton;	/**< button for ordering criteria */

    //Refactor into model
	NSMutableString *choiceSortDescriptor;	/**< sort descriptor for filtering Core Data */
	BOOL isAscending;					/**< is data ascending or descending order */
}

@property (nonatomic, retain) ChoiceHistoryModel *choiceHistoryModel;   /**< Model to handle data/business logic */

/**
 Retrieve all User entered Choices
 */
- (void) retrieveAllChoices;

/**
 Filter the list based on User search string
 @param searchText NSString of requested pkey
 */
- (void) filterResults: (NSString *)searchText;

///**
// Delete the particular choice
// @param choiceKey NSString of requested pkey
// @todo v2.0 determine best course for Choice deletion
// */
//- (void) deleteChoice:(NSString *) choiceKey;

@end

@implementation ChoiceListViewController

#pragma mark -
#pragma mark View lifecycle

- (id)initWithModel:(ChoiceHistoryModel *)choiceHistoryModel {
    self = [super init];

    if (self) {
        _choiceHistoryModel = [choiceHistoryModel retain];
        _choiceHistoryModel.choiceType = kChoiceHistoryModelTypeAll;
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	//appDelegate needed to retrieve CoreData Context, prefs used to save form state
	appDelegate = (MoraLifeAppDelegate *)[[UIApplication sharedApplication] delegate];
	prefs = [NSUserDefaults standardUserDefaults];
    
	//Set default listing and sort order
	isAscending = FALSE;
	choiceSortDescriptor = [[NSMutableString alloc] initWithString:kChoiceListSortDate];
    
	//Retrieve localized view title string
	/** 
	@todo utilize consistent localization string references 
	*/
	[moralSortButton setTitle:@"Sort" forState: UIControlStateNormal];
	[moralOrderButton setTitle:@"Order" forState: UIControlStateNormal];
        
	choiceSearchBar.barStyle = UIBarStyleBlack;
	choiceSearchBar.delegate = self;
	choiceSearchBar.showsCancelButton = NO;
	choicesTableView.delegate = self;
	choicesTableView.dataSource = self;
        
	//Initialize filtered data containers
	dataSource = [[NSMutableArray alloc] init];
	tableData = [[NSMutableArray alloc] init];
	tableDataColorBools = [[NSMutableArray alloc] init];
	tableDataImages = [[NSMutableArray alloc] init];
	tableDataKeys = [[NSMutableArray alloc] init];
	tableDataDetails = [[NSMutableArray alloc] init];
	
    [self localizeUI];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    
	//Refresh Data in case something changed since last time onscreen
	[self retrieveAllChoices];
	
	//Retrieve previous search if available
	NSString *searchString = [prefs objectForKey:@"searchTextChoice"];	
	
	if (searchString != nil) {
		[prefs removeObjectForKey:@"searchTextChoice"];
		[self filterResults:searchString];
		[choiceSearchBar setText:searchString];
	}
	
	//The scrollbars won't flash unless the tableview is long enough.
	[choicesTableView flashScrollIndicators];
	
	//Unselect the selected row if any was previously selected
	NSIndexPath* selection = [choicesTableView indexPathForSelectedRow];
	
	if (selection){
		[choicesTableView deselectRowAtIndexPath:selection animated:YES];
	}
	
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	
	//If search text was present, retain it for retrieval upon return to this UIViewController
	if (choiceSearchBar.text != nil && ![choiceSearchBar.text isEqualToString:@""]) {
		[prefs setObject:choiceSearchBar.text forKey:@"searchTextChoice"];
		
	}
}

#pragma mark -
#pragma mark UI Interaction

/**
Implementation: Cycle between Name, Date and Weight for sorting and Ascending and Descending for ordering.  Change button names and set sortDescriptor for next Core Data refresh.
 */
-(IBAction)switchList:(id) sender{
    
	//Set boolean to determine which version of screen to present
	if ([sender isKindOfClass:[UIButton class]]) {
		
		UIButton *senderButton = sender;
		int choiceIndex = senderButton.tag;
        
		//Determine if Sort or Order change is requested
		switch (choiceIndex) {

		//Sort change requested, cycle between Name, Date, Weight
            case 0:{    
                if ([choiceSortDescriptor isEqualToString:kChoiceListSortName]) {

                    [choiceSortDescriptor setString:kChoiceListSortDate];
                    [moralSortButton setTitle:@"Date" forState: UIControlStateNormal];
                } else if ([choiceSortDescriptor isEqualToString:kChoiceListSortDate]){

                    [choiceSortDescriptor setString:kChoiceListSortWeight];
                    [moralSortButton setTitle:@"Weight" forState: UIControlStateNormal];
                    
                } else {

                    [choiceSortDescriptor setString:kChoiceListSortName];
                    [moralSortButton setTitle:@"Alpha" forState: UIControlStateNormal];
                }

                [self.choiceHistoryModel setSortKey:choiceSortDescriptor];

            } break;

		//Order change requested, cycle between Ascending, Descending
            case 1:{    
                if (isAscending) {
                    isAscending = FALSE;
                    [moralOrderButton setTitle:@"Des" forState: UIControlStateNormal];
                } else {
                    isAscending = TRUE;
                    [moralOrderButton setTitle:@"Asc" forState: UIControlStateNormal];
                }
                [self.choiceHistoryModel setIsAscending:isAscending];
            }
                break;                 
            default:
                break;
        }
        
		//Refresh data view based on new criteria
		[self retrieveAllChoices];   
    }
}

#pragma mark -
#pragma mark Data Manipulation

/**
Implementation: Retrieve all User entered Choices, and then populate a working set of data containers upon which to filter.
 */
- (void) retrieveAllChoices {
		
	[dataSource removeAllObjects];
	[tableData removeAllObjects];
	[tableDataImages removeAllObjects];
	[tableDataKeys removeAllObjects];
	[tableDataDetails removeAllObjects];
	[tableDataColorBools removeAllObjects];
    	
	//Populate datasource arrays for filtering
	[dataSource addObjectsFromArray:self.choiceHistoryModel.choices];
	[tableData addObjectsFromArray:dataSource];
	[tableDataImages addObjectsFromArray:self.choiceHistoryModel.icons];
	[tableDataKeys addObjectsFromArray:self.choiceHistoryModel.choiceKeys];
	[tableDataDetails addObjectsFromArray:self.choiceHistoryModel.details];
	[tableDataColorBools addObjectsFromArray:self.choiceHistoryModel.choicesAreGood];

	[choicesTableView reloadData];
	
}

///**
//Implementation:  VERSION 2.0 Delete selected choice and remove its influence from calculations and reports
//@todo determine best deletion affect
// */
//- (void) deleteChoice:(NSString *) choiceKey {
//	
//    UserChoiceDAO *currentUserChoiceDAO = [[UserChoiceDAO alloc] initWithKey:@""];
//	
//	if (choiceKey != nil) {
//		NSPredicate *pred = [NSPredicate predicateWithFormat:@"entryKey == %@", choiceKey];
//        currentUserChoiceDAO.predicates = @[pred];
//	}
//	
//    [currentUserChoiceDAO delete:nil];
//    		
//	[currentUserChoiceDAO release];
//	
//}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [tableData count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *cellIdentifier = @"Choices";
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (cell == nil) {
      	cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
	}
    
    /** @todo check NSArrays for length*/
	//Setup cell contents
	[[cell textLabel] setText:[tableData objectAtIndex:indexPath.row]];
	[[cell textLabel] setMinimumFontSize:12.0];    
	[[cell detailTextLabel] setText:[tableDataDetails objectAtIndex:indexPath.row]];
    
	//Determine if Choice is good or bad
	BOOL isRowGood = [[tableDataColorBools objectAtIndex:indexPath.row] boolValue];
    
	if (isRowGood) {
		[[cell detailTextLabel] setTextColor:[UIColor colorWithRed:0.0/255.0 green:176.0/255.0 blue:0.0/255.0 alpha:1]];
	} else {
		[[cell detailTextLabel] setTextColor:[UIColor colorWithRed:200.0/255.0 green:25.0/255.0 blue:2.0/255.0 alpha:1]];
	}
    
	//Set cell content wrapping
	[[cell textLabel] setFont:[UIFont systemFontOfSize:18.0]];
	[[cell textLabel] setNumberOfLines:1];
	[[cell textLabel] setAdjustsFontSizeToFitWidth:TRUE];
	
	NSMutableString *rowImageName = [[NSMutableString alloc]  initWithString:[tableDataImages objectAtIndex:indexPath.row]];
    //	[rowImageName appendString:@".png"];
    
    UIImage *rowImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:rowImageName ofType:@"png"]];
    //	[[cell imageView] setImage:[UIImage imageNamed:rowImageName]];
    [[cell imageView] setImage:rowImage];
    [rowImage release];
    [rowImageName release];
    
	return cell;
}


/** @todo VERSION 2.0 determine logical choice deletion */
//#pragma mark -
//#pragma mark Table view edit
//
//-(void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
//{
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	
//	NSMutableString *selectedRow = [[NSMutableString alloc] initWithString:[tableDataKeys objectAtIndex:indexPath.row]];
//	
//	[self deleteChoice:selectedRow];
//	
//	[selectedRow release];
//	
//	[self retrieveAllChoices];
//	[choicesTableView reloadData];
//	
//	/** @todo make nice animation deletion work */
//	/*
//     // If row is deleted, remove it from the list.
//     if (editingStyle == UITableViewCellEditingStyleDelete)
//     {
//     
//     // Animate the deletion from the table.
//     [choicesTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//     
//     }
//	 */
//}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSMutableString *selectedRow = [[NSMutableString alloc] initWithString:[tableDataKeys objectAtIndex:indexPath.row]];

	//Get selected row and commit to NSUserDefaults    
	[self.choiceHistoryModel retrieveChoice:selectedRow];
	[selectedRow release];
	
	//Create subsequent view controller to be pushed onto stack
	//ChoiceViewController gets data from NSUserDefaults
	ChoiceViewController *choiceCont = [[ChoiceViewController alloc] init];
	
	//Push view onto stack
	[self.navigationController pushViewController:choiceCont animated:YES];
	[choiceCont release];
    
	//[self dismissModalViewControllerAnimated:NO];	
	
}

#pragma mark -
#pragma mark UISearchBar delegate methods
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	// only show the status bar’s cancel button while in edit mode
	searchBar.showsCancelButton = YES;
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	//flush the previous search content
	//[tableData removeAllObjects];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
	searchBar.showsCancelButton = NO;
}

- (void)filterResults: (NSString *)searchText{
    
	//Remove all data that belongs to previous search
	[tableData removeAllObjects];
	[tableDataImages removeAllObjects];
	[tableDataDetails removeAllObjects];
	[tableDataKeys removeAllObjects];
	[tableDataColorBools removeAllObjects];
	
    
	//Remove all entries once User starts typing
	if([searchText isEqualToString:@""] || searchText==nil){
		[choicesTableView reloadData];
		
		return;
	}
	
	BOOL isFound = FALSE;
	
	//Spin through datasource looking for match on cell.textLabel
	NSInteger counter = 0;
	for(NSString *name in dataSource)
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
		
		//Convert both searches to lowercase and compare search string to name in cell.textLabel
		NSRange searchRange = [[name lowercaseString] rangeOfString:[searchText lowercaseString]];
		NSRange searchRangeDetails = [[[self.choiceHistoryModel.details objectAtIndex:counter] lowercaseString] rangeOfString:[searchText lowercaseString]];
		NSRange searchRangeMorals = [[[self.choiceHistoryModel.icons objectAtIndex:counter] lowercaseString] rangeOfString:[searchText lowercaseString]];
		
		//A match was found in row name, details or moral
		if(searchRange.location != NSNotFound)
		{
			isFound = TRUE;
		}else if(searchRangeDetails.location != NSNotFound){
			isFound = TRUE;
		}else if(searchRangeMorals.location != NSNotFound){
			isFound = TRUE;
		}		
		
		if (isFound) {
			//If search is slow, only search prefix
			//if(searchRange.location== 0)
			//{
			
			//Add back cell.textLabel, cell.detailTextLabel and cell.imageView
			[tableData addObject:[self.choiceHistoryModel.choices objectAtIndex:counter]];
			[tableDataImages addObject:[self.choiceHistoryModel.icons objectAtIndex:counter]];
			[tableDataDetails addObject:[self.choiceHistoryModel.details objectAtIndex:counter]];
			[tableDataKeys addObject:[self.choiceHistoryModel.choiceKeys objectAtIndex:counter]];
            	[tableDataColorBools addObject:[self.choiceHistoryModel.choicesAreGood objectAtIndex:counter]];

			//}
		}
		
		isFound = FALSE;
		counter++;
		[pool release];
	}
	
	[choicesTableView reloadData];
	
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	[self filterResults:searchText];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	// if a valid search was entered but the user wanted to cancel, bring back the main list content
	[tableData removeAllObjects];
	[tableDataImages removeAllObjects];
	[tableDataDetails removeAllObjects];
	[tableDataKeys removeAllObjects];
	[tableDataColorBools removeAllObjects];

    
	[tableData addObjectsFromArray:dataSource];
	[tableDataImages addObjectsFromArray:self.choiceHistoryModel.icons];
	[tableDataDetails addObjectsFromArray:self.choiceHistoryModel.details];
	[tableDataKeys addObjectsFromArray:self.choiceHistoryModel.choiceKeys];
	[tableDataColorBools addObjectsFromArray:self.choiceHistoryModel.choicesAreGood];

    
	@try{
		[choicesTableView reloadData];
	}
	@catch(NSException *e){
	}
	[searchBar resignFirstResponder];
	searchBar.text = @"";
}


// called when Search (in our case “Done”) button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
}

#pragma mark -
#pragma mark ViewControllerLocalization Protocol

- (void) localizeUI {
    self.title = NSLocalizedString(@"ChoiceListScreenTitle",@"Label for Choice List Screen");
    moralSortButton.accessibilityLabel = NSLocalizedString(@"ChoiceListScreenSortButtonLabel",@"Label for Sort Button");
	moralSortButton.accessibilityHint = NSLocalizedString(@"ChoiceListScreenSortButtonHint",@"Hint for Sort Button");
    
    moralOrderButton.accessibilityLabel = NSLocalizedString(@"ChoiceListScreenOrderButtonLabel",@"Label for Order Button");
	moralOrderButton.accessibilityHint = NSLocalizedString(@"ChoiceListScreenOrderButtonHint",@"Hint for Order Button");

}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    [super viewDidUnload];

}


- (void)dealloc {
	
	[tableData release];
	[tableDataImages release];
	[tableDataColorBools release];
	[tableDataDetails release];
	[tableDataKeys release];
	[dataSource release];	
	[choiceSortDescriptor release];
    
	[super dealloc];
}

@end