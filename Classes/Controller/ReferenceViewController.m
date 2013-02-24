/**
Implementation:  UIViewController allows subsequent screen selection, controls button animation and resets choices by clearing NSUserDefaults.
 
@class ReferenceViewController ReferenceViewController.h
 */

#import "MoraLifeAppDelegate.h"
#import "ReferenceViewController.h"
#import "ReferenceListViewController.h"
#import "ReferenceModel.h"
#import "ConscienceHelpViewController.h"
#import "ViewControllerLocalization.h"
#import "ConscienceViewController.h"
#import "UIViewController+Screenshot.h"
#import "UIFont+Utility.h"

@interface ReferenceViewController () <ViewControllerLocalization> {

    IBOutlet UIImageView *accessoriesImageView;    /**< view for Accessories */
    IBOutlet UIImageView *peopleImageView;        /**< view for People */
    IBOutlet UIImageView *moralsImageView;        /**< view for Morals */

    IBOutlet UIView *accessoriesView;    /**< view for Accessories */
    IBOutlet UIView *peopleView;        /**< view for People */
    IBOutlet UIView *moralsView;        /**< view for Morals */

	IBOutlet UILabel *peopleLabel;		/**< label for People button */
	IBOutlet UILabel *moralsLabel;		/**< label for Morals button */
	IBOutlet UILabel *accessoriesLabel;	/**< label for Accessories button */
	
	IBOutlet UIButton *peopleButton;		/**< label for People button */
	IBOutlet UIButton *moralsButton;		/**< label for Places button */
	IBOutlet UIButton *booksButton;		/**< label for Books button */
	IBOutlet UIButton *beliefsButton;		/**< label for Beliefs button */
	IBOutlet UIButton *reportsButton;		/**< label for Reports button */
	IBOutlet UIButton *accessoriesButton;	/**< label for Accessories button */

}

@property (nonatomic, strong) NSTimer *buttonTimer;		/**< determines when Conscience thought disappears */

@end

@implementation ReferenceViewController

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    //Assign buttons to reference Types
    peopleButton.tag = MLReferenceModelTypePerson;
    moralsButton.tag = MLReferenceModelTypeMoral;
    booksButton.tag = MLReferenceModelTypeText;
    beliefsButton.tag = MLReferenceModelTypeBelief;
    reportsButton.tag = MLReferenceModelTypeReferenceAsset;
    accessoriesButton.tag = MLReferenceModelTypeConscienceAsset;

    self.navigationItem.hidesBackButton = YES;
    peopleLabel.font = [UIFont fontForScreenButtons];
    moralsLabel.font = [UIFont fontForScreenButtons];
    accessoriesLabel.font = [UIFont fontForScreenButtons];

    UIBarButtonItem *choiceBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:self.navigationController action:@selector(popToRootViewControllerAnimated:)];
    [self.navigationItem setLeftBarButtonItem:choiceBarButton];

    [self localizeUI];

}

-(void)viewDidAppear:(BOOL)animated {
    
	//Present help screen after a split second
    [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(showInitialHelpScreen) userInfo:nil repeats:NO];

    [self refreshButtons];
	self.buttonTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(refreshButtons) userInfo:nil repeats:YES];

}

#pragma mark -
#pragma mark UI Interaction

/**
 Implementation: Show an initial help screen if this is the User's first use of the screen.  Set a User Default after help screen is presented.  Launch a ConscienceHelpViewController and populate a localized help message.
 */
-(void)showInitialHelpScreen {
    
    //If this is the first time that the app, then show the intro

	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    NSObject *firstReferenceCheck = [prefs objectForKey:@"firstReference"];
    
    if (firstReferenceCheck == nil) {
        
        ConscienceHelpViewController *conscienceHelpViewController = [[ConscienceHelpViewController alloc] init];
        conscienceHelpViewController.viewControllerClassName = NSStringFromClass([self class]);
		conscienceHelpViewController.isConscienceOnScreen = FALSE;
        conscienceHelpViewController.numberOfScreens = 1;

        conscienceHelpViewController.screenshot = [self takeScreenshot];

		[self presentModalViewController:conscienceHelpViewController animated:NO];
        
        [prefs setBool:FALSE forKey:@"firstReference"];
        
    }
}

/**
Implementation: Determine which type of reference is requested by the User.
 */
- (IBAction) selectReferenceType:(id) sender{
	
	//Create view controller to be pushed upon navigation stack
    ReferenceModel *referenceModel = [[ReferenceModel alloc] init];

	//Determine which choice was selected
	if ([sender isKindOfClass:[UIButton class]]) {
		UIButton *senderButton = sender;
        referenceModel.referenceType = senderButton.tag;

	}

    ReferenceListViewController *referenceListViewCont = [[ReferenceListViewController alloc] initWithModel:referenceModel];
    [self.navigationController pushViewController:referenceListViewCont animated:TRUE];

}

/**
 Implementation: Only animate at most 4 buttons at a time.  Otherwise, too visually distracting
 */
- (void) refreshButtons{
    static BOOL isForward = TRUE;

    NSArray *images = [self animationFramesForButtonName:@"accessories" withDirection: isForward];

    accessoriesImageView.animationImages = images;
    accessoriesImageView.image = [images lastObject];
	accessoriesImageView.animationDuration = 0.5;
	accessoriesImageView.animationRepeatCount = 1;
	[accessoriesImageView startAnimating];

    images = [self animationFramesForButtonName:@"figures" withDirection: isForward];
	peopleImageView.animationImages = images;
    peopleImageView.image = [images lastObject];
	peopleImageView.animationDuration = 0.5;
	peopleImageView.animationRepeatCount = 1;
	[peopleImageView startAnimating];

    images = [self animationFramesForButtonName:@"choicebad" withDirection: isForward];
	moralsImageView.animationImages = images;
    moralsImageView.image = [images lastObject];
	moralsImageView.animationDuration = 0.5;
	moralsImageView.animationRepeatCount = 1;
	[moralsImageView startAnimating];

    isForward = !isForward;
}

/**
 Implementation: Build animated UIImage from sequential icon files
 */
- (NSArray *)animationFramesForButtonName:(NSString *)buttonName withDirection:(BOOL)isForward {
    NSMutableArray *images = [[NSMutableArray alloc] init];

    if (isForward) {
        for (int i = 1; i <= 60; i++) {
            NSString *iconFileName = [NSString stringWithFormat:@"%@-ani%d.png", buttonName, i];
            NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
            NSString *filePath = [bundlePath stringByAppendingPathComponent:iconFileName];
            if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                UIImage *iconani = [UIImage imageNamed:iconFileName];
                [images addObject:iconani];
            }

        }
    } else {
        for (int i = 60; i > 0; i--) {
            NSString *iconFileName = [NSString stringWithFormat:@"%@-ani%d.png", buttonName, i];
            NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
            NSString *filePath = [bundlePath stringByAppendingPathComponent:iconFileName];
            if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                UIImage *iconani = [UIImage imageNamed:iconFileName];
                [images addObject:iconani];
            }
        }
    }

    return (NSArray *)images;

}

#pragma mark -
#pragma mark ViewControllerLocalization Protocol

- (void) localizeUI {
    self.title = NSLocalizedString(@"ReferenceScreenTitle",nil);
    
    //Local Button Titles.  Do no do this in init, XIB is not loaded until viewDidLoad
    accessoriesLabel.text = NSLocalizedString(@"ReferenceScreenAccessoriesTitle",nil);
    peopleLabel.text = NSLocalizedString(@"ReferenceScreenPeopleTitle",nil);
    moralsLabel.text = NSLocalizedString(@"ReferenceScreenMoralsTitle",nil);
    
	peopleLabel.accessibilityHint = NSLocalizedString(@"ReferenceScreenPeopleHint",nil);
	peopleButton.accessibilityHint = NSLocalizedString(@"ReferenceScreenPeopleHint",nil);
	peopleButton.accessibilityLabel = NSLocalizedString(@"ReferenceScreenPeopleLabel",nil);
	moralsLabel.accessibilityHint = NSLocalizedString(@"ReferenceScreenMoralsHint",nil);
	moralsButton.accessibilityHint = NSLocalizedString(@"ReferenceScreenMoralsHint",nil);
	moralsButton.accessibilityLabel = NSLocalizedString(@"ReferenceScreenMoralsLabel",nil);
	accessoriesLabel.accessibilityHint = NSLocalizedString(@"ReferenceScreenAccessoriesHint",nil);
	accessoriesButton.accessibilityHint = NSLocalizedString(@"ReferenceScreenAccessoriesHint",nil);
	accessoriesButton.accessibilityLabel = NSLocalizedString(@"ReferenceScreenAccessoriesLabel",nil);    
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


@end