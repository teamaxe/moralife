/*
Implementation:  Retrieve all Virtues/Vices, depending upon requested type.  Present ability to search both Moral name and synonyms.

@class ChoiceModalViewController ChoiceModalViewController.h
 */

#import "ChoiceModalViewController.h"
#import "MoraLifeAppDelegate.h"
#import "ModelManager.h"
#import "ConscienceView.h"
#import "MoralDAO.h"
#import "ViewControllerLocalization.h"
#import "MoralTableViewCell.h"

@interface ChoiceModalViewController () <ViewControllerLocalization> {
    
	MoraLifeAppDelegate *appDelegate;		/**< delegate for application level callbacks */
	NSUserDefaults *prefs;				/**< serialized user settings/state retention */
	
	IBOutlet UITableView *choiceModalTableView;  	/**< table referenced by IB */
    
	//Raw data of all available morals
	NSMutableArray *searchedData;			/**< array for matched data from User search */
	NSMutableArray *moralNames;			/**< array for Moral pkey */
	NSMutableArray *moralDisplayNames;		/**< array for Moral name */
	NSMutableArray *moralImages;			/**< array for Moral Image */
	NSMutableArray *moralDetails;		/**< array for Moral synonyms */
    
	//Data for filtering/searching sourced from raw data
	NSMutableArray *dataSource;				/**< array for storing of Choices populated from previous view*/
	NSMutableArray *tableData;				/**< array for stored data displayed in table populated from dataSource */
	NSMutableArray *tableDataImages;			/**< array for stored data images */
	NSMutableArray *tableDataDetails;			/**< array for stored data details */
	NSMutableArray *tableDataKeys;			/**< array for stored data pkeys */
    
	IBOutlet UISearchBar *moralSearchBar;			/**< ui element for limiting choices in table */
	
    IBOutlet UIButton *previousButton;
	IBOutlet UIView *thoughtModalArea;				/**< ui surrounding table */
	
	BOOL isVirtue;		/**< is Moral Virtue or Vice */
    
}

/**
 Retrieve all available Morals
 */
-(void)retrieveAllSelections;

@end

@implementation ChoiceModalViewController

#pragma mark - 
#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//appDelegate needed to retrieve CoreData Context, prefs used to save form state
	appDelegate = (MoraLifeAppDelegate *)[[UIApplication sharedApplication] delegate];
	prefs = [NSUserDefaults standardUserDefaults];

	moralSearchBar.barStyle = UIBarStyleBlack;
	moralSearchBar.delegate = self;
	moralSearchBar.showsCancelButton = NO;
	choiceModalTableView.delegate = self;
	choiceModalTableView.dataSource = self;
    
	CGPoint centerPoint = CGPointMake(MLConscienceOffscreenBottomX, MLConscienceOffscreenBottomY);
	
	[thoughtModalArea addSubview:appDelegate.userConscienceView];
	
	appDelegate.userConscienceView.center = centerPoint;
        
    //User can back out of Choice Entry screen and state will be saved
	//However, user should not be able to select a virtue, and then select a vice for entry
	NSObject *boolCheck = [prefs objectForKey:@"entryIsGood"];
	
	if (boolCheck != nil) {
		isVirtue = [prefs boolForKey:@"entryIsGood"];
		
	}else {
		isVirtue = TRUE;
	}
    
    [self retrieveAllSelections];

    [self localizeUI];    
    
}

- (void) viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	thoughtModalArea.alpha = 0;
    
	CGPoint centerPoint = CGPointMake(MLConscienceLowerLeftX, MLConscienceLowerLeftY);
	
	[UIView beginAnimations:@"BottomUpConscience" context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationBeginsFromCurrentState:NO];
	thoughtModalArea.alpha = 1;
	appDelegate.userConscienceView.conscienceBubbleView.transform = CGAffineTransformMakeScale(1.25f, 1.25f);
	
	appDelegate.userConscienceView.center = centerPoint;
	
	[UIView commitAnimations];
	
	[appDelegate.userConscienceView setNeedsDisplay];
	
}

-(void) viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
    
	id placeHolderID = nil;
	
	[self dismissChoiceModal:placeHolderID];
	
}

#pragma mark - 
#pragma mark - UI Interaction
/**
Implementation: Moves Conscience gracefully off screen before dismissing controller after a delay
 */
-(IBAction)dismissChoiceModal:(id)sender{
	
	CGPoint centerPoint = CGPointMake(MLConscienceOffscreenBottomX, MLConscienceOffscreenBottomY);
	
	[UIView beginAnimations:@"ReplaceConscience" context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationBeginsFromCurrentState:YES];
	thoughtModalArea.alpha = 0;
	appDelegate.userConscienceView.conscienceBubbleView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
	
	appDelegate.userConscienceView.center = centerPoint;
	
	[UIView commitAnimations];
	
	//Call dismissFunction with a delay
	SEL selector = @selector(dismissModalViewControllerAnimated:);
	
	NSMethodSignature *signature = [UIViewController instanceMethodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setSelector:selector];
	
	BOOL timerBool = NO;
	
	//Set the arguments
	[invocation setTarget:self];
	[invocation setArgument:&timerBool atIndex:2];
	
	[NSTimer scheduledTimerWithTimeInterval:0.5 invocation:invocation repeats:NO];
    
}

#pragma mark -
#pragma mark Data Manipulation

/**
Implementation: Retrieve all available Virtues/Vices and populate searchable data set.
 */
- (void) retrieveAllSelections {
	
	NSPredicate *pred;
    
	if (isVirtue) {
        pred = [NSPredicate predicateWithFormat:@"shortDescriptionMoral == %@", @"Virtue"];
	}else {
        pred = [NSPredicate predicateWithFormat:@"shortDescriptionMoral == %@", @"Vice"];
	}
    
    MoralDAO *currentMoralDAO = [[MoralDAO alloc] init];
    currentMoralDAO.predicates = @[pred];
    
    NSArray *morals = [currentMoralDAO readAll];
    int numberOfMorals = morals.count;
    
    moralNames = [[NSMutableArray alloc] initWithCapacity:numberOfMorals];
	moralImages = [[NSMutableArray alloc] initWithCapacity:numberOfMorals];			
	moralDetails = [[NSMutableArray alloc] initWithCapacity:numberOfMorals];
	moralDisplayNames = [[NSMutableArray alloc] initWithCapacity:numberOfMorals];

    for (Moral *moral in morals) {
        [moralNames addObject:moral.nameMoral];
        [moralImages addObject:moral.imageNameMoral];
        [moralDetails addObject:moral.longDescriptionMoral];
        [moralDisplayNames addObject:moral.displayNameMoral];        
    }
    
    
	dataSource = [[NSMutableArray alloc] initWithArray:moralDisplayNames];
	searchedData = [[NSMutableArray alloc]init];
	tableData = [[NSMutableArray alloc]initWithArray:dataSource];
	tableDataImages = [[NSMutableArray alloc]initWithArray:moralImages];
	tableDataDetails = [[NSMutableArray alloc]initWithArray:moralDetails];
	tableDataKeys = [[NSMutableArray alloc]initWithArray:moralNames];
    
}

#pragma mark -
#pragma mark Table view delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	return [tableData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    //Get text that is displayed in cell's detailTextLabel
    NSString *moralSynonym = tableDataDetails[indexPath.row];

    //Set the cell height to either the default cell height or a sum of the cell's static textLabel and dynamic detailTextLabel height
    return MAX(MoralTableViewCellDefaultHeight, (MoralTableViewCellRowTextHeight + [MoralTableViewCell heightForDetailTextLabel:moralSynonym] + (MoralTableViewCellRowTextPaddingVertical * 2)));
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	MoralTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MoralTableViewCell class])];

	if (cell == nil) {
      	cell = [[MoralTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:NSStringFromClass([MoralTableViewCell class])];
	}

	//Populate cell information
    if ([tableData count] > 0) {
        cell.moralName = tableData[indexPath.row];
                
        UIImage *rowImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:tableDataImages[indexPath.row] ofType:@"png"]];
        [[cell imageView] setImage:rowImage];
        cell.moralSynonyms = tableDataDetails[indexPath.row];
    }
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//Commit selected Moral to NSUserDefaults for retrieval from ChoiceViewController
	[prefs setObject:tableDataKeys[indexPath.row] forKey:@"moralKey"];
	[prefs setObject:tableData[indexPath.row] forKey:@"moralName"];
	[prefs setObject:tableDataImages[indexPath.row] forKey:@"moralImage"];
		
	//Must create blank ID to call function typically referenced by IB
	id placeHolderID = @"";
	
	[self dismissChoiceModal:placeHolderID];
}

#pragma mark -
#pragma mark UISearchBar delegate methods
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	// only show the status bar’s cancel button while in edit mode
	searchBar.showsCancelButton = YES;
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	// flush the previous search content
	[tableData removeAllObjects];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
	searchBar.showsCancelButton = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	//Remove all data that belongs to previous search
	[tableData removeAllObjects];
	[tableDataImages removeAllObjects];
	[tableDataDetails removeAllObjects];
	[tableDataKeys removeAllObjects];
	
	//Remove all entries once User starts typing
	if([searchText isEqualToString:@""] || searchText==nil){
		[choiceModalTableView reloadData];
        
		return;
	}
	
	BOOL isFound = FALSE;
	
	//Spin through datasource looking for match on cell.textLabel
	NSInteger counter = 0;
	for(NSString *name in dataSource)
	{
		@autoreleasepool {
        
		//Convert both searches to lowercase and compare search string to name in cell.textLabel
			NSRange searchRange = [[name lowercaseString] rangeOfString:[searchText lowercaseString]];
			NSRange searchRangeDetails = [[moralDetails[counter] lowercaseString] rangeOfString:[searchText lowercaseString]];
        
			
			//A match was found
			if(searchRange.location != NSNotFound)
			{
				isFound = TRUE;
				
			}else if(searchRangeDetails.location != NSNotFound){
				isFound = TRUE;
			}		
			
			if (isFound) {
				//If search is slow, only search prefix
				//if(searchRange.location== 0)
				//{			
				//Add back cell.textLabel, cell.detailTextLabel and cell.imageView
				[tableData addObject:moralDisplayNames[counter]];
				[tableDataImages addObject:moralImages[counter]];
				[tableDataDetails addObject:moralDetails[counter]];
				[tableDataKeys addObject:moralNames[counter]];
            
				//}
			}
			
			isFound = FALSE;
			counter++;
		}
	}
	
	[choiceModalTableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	// if a valid search was entered but the user wanted to cancel, bring back the main list content
	[tableData removeAllObjects];
	[tableDataImages removeAllObjects];
	[tableDataDetails removeAllObjects];
	[tableDataKeys removeAllObjects];
    
	[tableData addObjectsFromArray:dataSource];
	[tableDataImages addObjectsFromArray:moralImages];
	[tableDataDetails addObjectsFromArray:moralDetails];
	[tableDataKeys addObjectsFromArray:moralNames];
	
	@try{
		[choiceModalTableView reloadData];
	}
	@catch(NSException *e){
	}
	[searchBar resignFirstResponder];
	[searchBar setText:@""];
}


// called when Search (in our case “Done”) button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
}

#pragma mark -
#pragma mark ViewControllerLocalization Protocol

- (void) localizeUI {
    
    previousButton.accessibilityHint = NSLocalizedString(@"PreviousButtonHint",nil);
	previousButton.accessibilityLabel =  NSLocalizedString(@"PreviousButtonLabel",nil);

}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    previousButton = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


@end
