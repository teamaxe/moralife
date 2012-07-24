/**
Implementation: Presents a series of updated screens to User prompting the User to select one or the other.
Allows for backwards perusal to reread certain parts of entry as long as choice hasn't been made.
Commits choice to UserData, updates ethicals, adds reward to MoraLifeAppDelegate::userCollection
 
@class DilemmaViewController DilemmaViewController.h
 */

#import "DilemmaViewController.h"
#import "MoraLifeAppDelegate.h"
#import "ModelManager.h"
#import "ConscienceBody.h"
#import "ConscienceAccessories.h"
#import "ConscienceMind.h"
#import "ConscienceView.h"
#import "ConscienceAsset.h"
#import "ConscienceBuilder.h"
#import "DilemmaDAO.h"
#import "Character.h"
#import "Moral.h"
#import "UserDilemmaDAO.h"
#import "UserCollectableDAO.h"
#import "ReferencePersonDAO.h"
#import "ReferenceAssetDAO.h"
#import "UserCharacterDAO.h"
#import "UserChoiceDAO.h"
#import "ViewControllerLocalization.h"

enum viewToAnimate{
kViewVersus,
kViewReward
};

@interface DilemmaViewController () <ViewControllerLocalization> {
    
	MoraLifeAppDelegate *appDelegate;		/**< delegate for application level callbacks */
	NSUserDefaults *prefs;				/**< serialized user settings/state retention */
	NSManagedObjectContext *context;		/**< Core Data context */
    
	IBOutlet UIImageView *surroundingsBackground;		/**< background image provided by dilemma */
	IBOutlet UIImageView *versusImage;				/**< animated versus decoration image */
	IBOutlet UIImageView *moral1Image;				/**< initial MoralA image decoration above vs. */
	IBOutlet UIImageView *moral2Image;				/**< initial MoralB image decoration below vs. */
	IBOutlet UIImageView *moral1ButtonImage;			/**< final MoralA selection button above "or" */
	IBOutlet UIImageView *moral2ButtonImage;			/**< final MoralB selection button above "or" */
	IBOutlet UIImageView *moralSelectedImage;			/**< final chosen Moral image decoration */
	IBOutlet UIImageView *rewardCard;				/**< card image on rewardView */
	IBOutlet UIImageView *rewardImage;				/**< actual image of reward (large) */
	IBOutlet UIImageView *rewardImageSmall;			/**< actual image of reward (small) */
	IBOutlet UILabel *moral1ChoiceLabel;			/**< MoralA text name */
	IBOutlet UILabel *moral2ChoiceLabel;			/**< MoralB text name */
	IBOutlet UIImageView *moral1ChoiceImage;			/**< MoralA decoration */
	IBOutlet UIImageView *moral2ChoiceImage;			/**< MoralB decoration */
	IBOutlet UILabel *moralSelectedChoiceLabel;		/**< completed moral title */
	IBOutlet UILabel *moralSelectedRewardLabel;		/**< completed reward description */
	IBOutlet UILabel *moralRewardLabel;				/**< increase to specific moral */
	IBOutlet UILabel *moralScoreLabel;				/**< score next to moral image */
	IBOutlet UILabel *ethicalRewardLabel;			/**< ethicals text if ethicals rewarded */
    
	//Views for progression of Dilemma
	IBOutlet UIView *thoughtModalArea;		/**< area in which Conscience floats */
	IBOutlet UIView *screen1View;			/**< intro screen with moral vs. moral */
	IBOutlet UIView *screen2View;			/**< description of dilemma */
	IBOutlet UIView *screen3View;			/**< description of Moral choice A */			
	IBOutlet UIView *screen4View;			/**< description of Moral choice B */
	IBOutlet UIView *screen5View;			/**< Moral section screen */
	IBOutlet UIView *screen6View;			/**< reward screen */
	IBOutlet UIView *rewardView;			/**< reward card containing decorations */
    
	IBOutlet UILabel *dilemmaTitle;		/**< title of Dilemma */
	IBOutlet UILabel *dilemmaTitleText;		/**< 2nd viewing of title of Dilemma */
	IBOutlet UITextView *dilemmaText;		/**< dilemma presented to User */
	IBOutlet UILabel *dilemmaMoralLabel1;	/**< MoralA associated with dilemma */
	IBOutlet UILabel *dilemmaMoralLabel2;	/**< MoralB associated with dilemma */
	IBOutlet UITextView *choiceText1;		/**< MoralA description */
	IBOutlet UITextView *choiceText2;		/**< MoralB description */
	IBOutlet UIButton *previousButton;		/**< return to previous page in dilemma */
	IBOutlet UIButton *nextButton;		/**< proceed to next page in dilemma */
	IBOutlet UIButton *selectionButton1;	/**< select Moral A */
	IBOutlet UIButton *selectionButton2;	/**< select Moral B */
	
	Dilemma *currentDilemma;			/**< information about the dilemma */
    
	NSMutableString *reward1;		/**< reward for choosing ChoiceA */
	NSMutableString *reward2;		/**< reward for choosing ChoiceB */
    NSMutableString *dilemmaName;          /**< name of dilemma used for record retention */
    NSMutableString *moralAName;    /**< name of Moral A */
    NSMutableString *moralBName;    /**< name of Moral B */    
    NSMutableString *moralADescription;    /**< description of Moral A */    
    NSMutableString *moralBDescription;    /**< description of Moral B */    
    
	BOOL isChoiceA;				/**< is ChoiceA selected */
    
}

- (void) animateViewDetail: (int) viewToAnimateIndex atBeginning: (BOOL) isBeginning;

/**
 Load the dilemma's details from SystemData
 */
-(void)loadDilemma;

/**
 Change the active UIView within the UIViewController
 @param screenVersion intDesignating which page of screen to display
 */
-(void)changeScreen:(int) screenVersion;

/**
 Commit User's choice to UserData
 */
-(void)commitDilemma;

@end

@implementation DilemmaViewController

#pragma mark -
#pragma mark ViewController Lifecycle

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
		//Create appDelegate and CD context for Conscience and data
		appDelegate = (MoraLifeAppDelegate *)[[UIApplication sharedApplication] delegate];
        prefs = [NSUserDefaults standardUserDefaults];
		context = [appDelegate.moralModelManager readWriteManagedObjectContext];
        
		//Setup default values
        reward1 = [[NSMutableString alloc] init];
        reward2 = [[NSMutableString alloc] init];
        dilemmaName = [[NSMutableString alloc] init];
        moralAName = [[NSMutableString alloc] init];
        moralBName = [[NSMutableString alloc] init];
        moralADescription = [[NSMutableString alloc] init];
        moralBDescription = [[NSMutableString alloc] init];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    	
    [self loadDilemma];
    
    isChoiceA = FALSE;
    
    [self localizeUI];    

}

-(void) viewWillAppear:(BOOL)animated{
	
	[super viewWillAppear:animated];
	
	screen1View.hidden = TRUE;
	screen1View.alpha = 0;
	
    //Build vs. image animation
	versusImage.alpha = 0;    
    versusImage.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(6.0f, 6.0f), CGAffineTransformMakeRotation(M_PI * -1));

    [self animateViewDetail: kViewVersus atBeginning: TRUE];    
    
	[thoughtModalArea addSubview:appDelegate.userConscienceView];
	
	CGPoint centerPoint = CGPointMake(kConscienceLowerLeftX, kConscienceLowerLeftY);
	
    //Animate vs. image and Consciences
	[UIView beginAnimations:@"MoveConscience" context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationBeginsFromCurrentState:YES];
	appDelegate.userConscienceView.conscienceBubbleView.transform = CGAffineTransformMakeScale(kConscienceLargeSizeX, kConscienceLargeSizeY);
    
	screen1View.alpha = 1;
	
	screen1View.hidden = FALSE;
    
    [self animateViewDetail: kViewVersus atBeginning: FALSE];
    
	appDelegate.userConscienceView.center = centerPoint;
	
	[UIView commitAnimations];
    
    [self animateViewDetail: kViewReward atBeginning: TRUE];    

	
	[appDelegate.userConscienceView setNeedsDisplay];
	
}

#pragma mark -
#pragma mark User View Interaction

/**
Implementation: Determine which screen user is own and determine if Dilemma is ready to be committed.
 */
- (IBAction) selectChoice:(id) sender{
	
	//Determine which button was pushed
	//Change options accordingly
	
    BOOL isReadyToCommit = FALSE;
    
	if ([sender isKindOfClass:[UIButton class]]) {
		UIButton *senderButton = sender;
		int choiceIndex = senderButton.tag;
		
        if (choiceIndex == 6) {
            [moralSelectedImage setImage:moral1ChoiceImage.image];
            [moralSelectedChoiceLabel setText:moral1ChoiceLabel.text];

            isChoiceA = TRUE;
            isReadyToCommit = TRUE;
        } else if (choiceIndex == 7) {
            [moralSelectedImage setImage:moral2ChoiceImage.image];
            [moralSelectedChoiceLabel setText:moral2ChoiceLabel.text];

            isChoiceA = FALSE;
            isReadyToCommit = TRUE;

        }
        
        if (isReadyToCommit) {
            
            [self commitDilemma];
        }
        
		[self changeScreen:choiceIndex];
		
	}
	
	
}

/**
Implementation: Hide or show a screen depending upon which page the User currently resides.
Show reward views once User has completed dilemma and refuse access to previous screen versions.
 */
-(void)changeScreen:(int) screenVersion {
    
	UIView *viewSelection;
	int buttonFactor = 0;
	
	screen1View.hidden = TRUE;
	screen1View.alpha = 0;
	screen2View.hidden = TRUE;
	screen2View.alpha = 0;
	screen3View.hidden = TRUE;
	screen3View.alpha = 0;
	screen4View.hidden = TRUE;
	screen4View.alpha = 0;
	screen5View.hidden = TRUE;
	screen5View.alpha = 0;
	screen6View.hidden = TRUE;
	screen6View.alpha = 0;	
	nextButton.hidden = FALSE;			
	previousButton.hidden = FALSE;
		
	/** @bug determine why screen2 doesn't fade */
	//Depending upon which screen is requested
	//Setup variables to hide views, change Next/Previous button and move Conscience
	switch (screenVersion){
		case 0:	[self.navigationController popViewControllerAnimated:NO];
				break;
		case 1:viewSelection = screen1View;buttonFactor = 0;break;
		case 2:viewSelection = screen2View;buttonFactor = 1;break;
		case 3:viewSelection = screen3View;buttonFactor = 2;break;
		case 4:viewSelection = screen4View;buttonFactor = 3;break;
		case 5:viewSelection = screen5View;buttonFactor = 4;nextButton.hidden = TRUE;break;	
		case 6:viewSelection = screen6View;buttonFactor = 5;nextButton.hidden = FALSE;previousButton.hidden = TRUE;break;
		case 7:viewSelection = screen6View;buttonFactor = 5;nextButton.hidden = FALSE;previousButton.hidden = TRUE;break;            
		case 8:[self.navigationController popViewControllerAnimated:NO];break;
		default:break;
			
	}
	
	//Change the active view except in the case of dismissing the entire ViewController
	if (screenVersion > 0 && screenVersion <= 7) {

		//Animated changes to the ViewController
		//Show/Hide relevant subview
		//Move Conscience to appropriate place on screen
		[UIView beginAnimations:@"ScreenChange" context:nil];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationBeginsFromCurrentState:YES];
	
		viewSelection.alpha = 1;
		viewSelection.hidden = FALSE;

		[UIView commitAnimations];
		
		[dilemmaText flashScrollIndicators];
		[choiceText1 flashScrollIndicators];
		[choiceText2 flashScrollIndicators];

        //Change Button tag in order to determine which "screen" is active
		nextButton.tag = 2 + buttonFactor;
		previousButton.tag = buttonFactor;
        
		//Delay appearance of score to draw attention
		if ((screenVersion == 6) || (screenVersion == 7)) {
			
            nextButton.tag = 8;
            
            [self animateViewDetail: kViewReward atBeginning: FALSE];    
            
			[UIView beginAnimations:@"ScoreChange" context:nil];
			[UIView setAnimationDuration:3];
			[UIView setAnimationBeginsFromCurrentState:YES];
			
			moralRewardLabel.alpha = 1;            
			
			[UIView commitAnimations];
			
		}
		
	}

}

/**
 Implementation: Signals User desire to return to ConscienceModalViewController
 */
-(IBAction)returnToHome:(id)sender{

    [prefs setBool:TRUE forKey:@"conscienceModalReset"];
	[self.navigationController popToRootViewControllerAnimated:NO];
    
}

#pragma mark -
#pragma mark Data Manipulation

/**
Implementation: Load requested dilemma, load into iVar for use throughout UIViewController.
Construct antagonist Conscience
@todo refactor into multiple functions
 */
-(void) loadDilemma{
        
	NSString *restoreDilemmaKey = [prefs objectForKey:@"dilemmaKey"];
    
	/** @todo determine no dilemma case */
	if (restoreDilemmaKey != nil) {
		[prefs removeObjectForKey:@"dilemmaKey"];
	}

	//Retrieve Dilemma
    DilemmaDAO *currentDilemmaDAO = [[DilemmaDAO alloc] initWithKey:restoreDilemmaKey];
    currentDilemma = [currentDilemmaDAO read:@""];
    
	if (currentDilemma) {    
		//Populate relevante dilemma information
        [dilemmaName setString:[currentDilemma nameDilemma]];
        [moralAName setString:[[currentDilemma moralChoiceA] nameMoral]];
        [moralBName setString:[[currentDilemma moralChoiceB] nameMoral]];
        [moralADescription setString:[[currentDilemma moralChoiceA] shortDescriptionMoral]];
        [moralBDescription setString:[[currentDilemma moralChoiceB] shortDescriptionMoral]];
		surroundingsBackground.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", [currentDilemma surrounding]]];
		[dilemmaTitle setText:[currentDilemma displayNameDilemma]];
		[dilemmaTitleText setText:[dilemmaTitle text]];
		[dilemmaText setText:[currentDilemma dilemmaText]];
		[choiceText1 setText:[currentDilemma choiceA]];
		[choiceText2 setText:[currentDilemma choiceB]];
        
		NSString *moral1Text = [[NSString alloc] initWithString:[[currentDilemma moralChoiceA] displayNameMoral]];
		NSString *moral2Text = [[NSString alloc] initWithString:[[currentDilemma moralChoiceB] displayNameMoral]];
		UIImage *moral1ImageFull = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", [[currentDilemma moralChoiceA] imageNameMoral]]];
		UIImage *moral2ImageFull = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", [[currentDilemma moralChoiceB] imageNameMoral]]];
        
		moral1Image.image = moral1ImageFull;
		moral2Image.image = moral2ImageFull;
		[dilemmaMoralLabel1 setText:moral1Text];
      	[dilemmaMoralLabel2 setText:moral2Text];
		[moral1ChoiceLabel setText:moral1Text];
      	[moral2ChoiceLabel setText:moral2Text];
        
		moral1ChoiceImage.image = moral1ImageFull;
		moral2ChoiceImage.image = moral2ImageFull;
        
		moral1ButtonImage.image = moral1ImageFull;
		moral2ButtonImage.image = moral2ImageFull;
        
		[selectionButton1 setTitle:moral1Text forState:UIControlStateNormal];
		[selectionButton2 setTitle:moral2Text forState:UIControlStateNormal];
        
		[moral1Text release];
		[moral2Text release];
        
		[reward1 appendString:[currentDilemma rewardADilemma]];
		[reward2 appendString:[currentDilemma rewardBDilemma]];
        
        ConscienceBody *antagonistConscienceBody = [[ConscienceBody alloc] init];
        ConscienceAccessories *antagonistConscienceAccessories = [[ConscienceAccessories alloc] init];
        ConscienceMind *antagonistConscienceMind = [[ConscienceMind alloc] init];        
        
        Character *character = [currentDilemma antagonist];
        
		//Create antagonist Conscience
		antagonistConscienceBody.eyeColor = [character eyeColor];
		antagonistConscienceBody.browColor = [character browColor];
		antagonistConscienceBody.bubbleColor = [character bubbleColor];
		antagonistConscienceBody.age = [[character ageCharacter] intValue];
		antagonistConscienceBody.bubbleType = [[character bubbleType] intValue];
		antagonistConscienceBody.symbolName = [character faceCharacter];
		antagonistConscienceBody.eyeName = [character eyeCharacter];
		antagonistConscienceBody.mouthName = [character mouthCharacter];

        if (![[character accessoryPrimaryCharacter] isEqualToString:@""]) {
            antagonistConscienceAccessories.primaryAccessory = [character accessoryPrimaryCharacter];
        }
        if (![[character accessorySecondaryCharacter] isEqualToString:@""]) {
            antagonistConscienceAccessories.secondaryAccessory = [character accessorySecondaryCharacter];
        }
        if (![[character accessoryTopCharacter] isEqualToString:@""]) {
            antagonistConscienceAccessories.topAccessory = [character accessoryTopCharacter];
        }
        if (![[character accessoryBottomCharacter] isEqualToString:@""]) {            
            antagonistConscienceAccessories.bottomAccessory = [character accessoryBottomCharacter];
        }
        
		[antagonistConscienceMind setMood:[[currentDilemma moodDilemma] floatValue]];
		[antagonistConscienceMind setEnthusiasm:[[currentDilemma enthusiasmDilemma] floatValue]];
        
		//Call conscience construction
		[ConscienceBuilder buildConscience:antagonistConscienceBody];
        
		//Add Conscience to view
		ConscienceView *antagonistConscienceView = [[ConscienceView alloc] initWithFrame:CGRectMake(kConscienceAntagonistX, kConscienceAntagonistY, kConscienceAntagonistWidth, kConscienceAntagonistHeight) withBody:antagonistConscienceBody withAccessories:antagonistConscienceAccessories withMind:antagonistConscienceMind];
        
		antagonistConscienceView.tag = kConscienceAntagonistViewTag;
		antagonistConscienceView.conscienceBubbleView.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
		antagonistConscienceView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
		[antagonistConscienceView setUserInteractionEnabled:FALSE];
		[antagonistConscienceView.conscienceBubbleView setNeedsDisplay];
        
		[thoughtModalArea addSubview:antagonistConscienceView];
        
        [antagonistConscienceView setNeedsDisplay];
		[antagonistConscienceView release];
        [antagonistConscienceBody release];
        [antagonistConscienceAccessories release];
        [antagonistConscienceMind release];
	}
    
    [currentDilemmaDAO release];
}

/**
Implementation: Determine which choice was selected.
Determine if Moral was already rewarded and add if it wasn't.  Update otherwise.
Add UserChoice to UserData and append it with key to remove from ChoiceListViewController.  Dilemma must affect User's Moral Report.
Add reward ConscienceAsset or ReferenceAsset to MoraLifeAppDelegate::userCollection.
Calculate changes to User's ethicals.  Limit to 999.
@todo refactor into multiple functions
 */
-(void)commitDilemma{
            
    //Construct Unique Primary Key from dtstamp to millisecond
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];	
    
    NSString *currentDTS = [dateFormatter stringFromDate:[NSDate date]];
    
    [dateFormatter release];
        
    NSString *dilemmaKey = [NSString stringWithFormat:@"%@%@", currentDTS, dilemmaName];
    
    UserDilemmaDAO *currentUserDilemmaDAO = [[UserDilemmaDAO alloc] init];
    
    UserDilemma *currentUserDilemma = [currentUserDilemmaDAO create];
        
    [currentUserDilemma setEntryShortDescription:dilemmaName];
    [currentUserDilemma setEntryCreationDate:[NSDate date]];
    [currentUserDilemma setEntryKey:dilemmaKey];
    
    NSString *moralKey;
    
    if (isChoiceA) {
        moralKey = [[NSString alloc] initWithString:moralAName];
    } else {
        moralKey = [[NSString alloc] initWithString:moralBName];       
    }
    
    [currentUserDilemma setEntryLongDescription:moralKey];
    
    [currentUserDilemma setEntryIsGood:[NSNumber numberWithBool:isChoiceA]];
    
    UserCollectableDAO *currentUserCollectableDAO = [[UserCollectableDAO alloc] initWithKey:@""];
    //See if moral has been rewarded before
    //Cannot assume that first instance of UserChoice implies no previous reward
    if ([appDelegate.userCollection containsObject:moralKey]) {
        
        UserCollectable *currentUserCollectable = [currentUserCollectableDAO read:moralKey];

		//Increase the moral's value
		float moralIncrease = [[currentUserCollectable collectableValue] floatValue];
        
		if (moralIncrease >= 99.0) {
			moralIncrease = 99.0;
		} else {
			moralIncrease += 1.0;
		}
        
		[currentUserCollectable setValue:[NSNumber numberWithFloat:moralIncrease] forKey:@"collectableValue"];
                
	} else {
        
		//Create a new moral reward
		UserCollectable *currentUserCollectable = [currentUserCollectableDAO create];       
		[currentUserCollectable setCollectableCreationDate:[NSDate date]];
		[currentUserCollectable setCollectableKey:dilemmaKey];
		[currentUserCollectable setCollectableName:moralKey];
		[currentUserCollectable setCollectableValue:[NSNumber numberWithFloat:1.0]];
                
		[appDelegate.userCollection addObject:moralKey];
        
	}
    
	//Determine which reward should be given
	NSMutableString *selectedReward = [[NSMutableString alloc] init];
    
	if (isChoiceA) {
		[selectedReward appendString:reward1];
	} else {
		[selectedReward appendString:reward2];
	}

	//Determine type of reward given    
	if ([selectedReward rangeOfString:kCollectableEthicals].location != NSNotFound) {
		//Ethicals are rewarded, process
		[selectedReward deleteCharactersInRange:[selectedReward rangeOfString:kCollectableEthicals]];
		[moralSelectedRewardLabel setText:[NSString stringWithString:@"Have some Ethicals!"]];        
	} else if ([selectedReward rangeOfString:@"figu-"].location != NSNotFound) {
        
		//ReferencePerson rewarded, process, use large moralRewardImage
		[ethicalRewardLabel setAlpha:0];
        
        ReferencePersonDAO *currentPersonDAO = [[ReferencePersonDAO alloc] initWithKey:selectedReward];
        ReferencePerson *currentPerson = [currentPersonDAO read:@""];
        
        [moralSelectedRewardLabel setText:[NSString stringWithString:currentPerson.displayNameReference]];
        
		[rewardImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", currentPerson.imageNameReference]]];
        
        [currentPersonDAO release];

		UserCollectable *currentUserCollectable = [currentUserCollectableDAO create];
        
		[currentUserCollectable setCollectableCreationDate:[NSDate date]];
		[currentUserCollectable setCollectableKey:[NSString stringWithFormat:@"%@%@", currentDTS, selectedReward]];
		[currentUserCollectable setCollectableName:selectedReward];
                
		[appDelegate.userCollection addObject:selectedReward];

	} else if ([selectedReward rangeOfString:@"asse-"].location != NSNotFound) {
      
		//ConscienceAsset rewarded, process, use small moralRewardImage
		[ethicalRewardLabel setAlpha:0];
        
        ReferenceAssetDAO *currentReferenceDAO = [[ReferenceAssetDAO alloc] initWithKey:selectedReward];
        ReferenceAsset *currentReference = [currentReferenceDAO read:@""];
        
		[moralSelectedRewardLabel setText:[NSString stringWithString:currentReference.displayNameReference]];
        
		[rewardImageSmall setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@-sm.png", currentReference.imageNameReference]]];
        
        [currentReferenceDAO release];
                
		UserCollectable *currentUserCollectable = [currentUserCollectableDAO create];
        
		[currentUserCollectable setCollectableCreationDate:[NSDate date]];
		[currentUserCollectable setCollectableKey:[NSString stringWithFormat:@"%@%@", currentDTS, selectedReward]];
		[currentUserCollectable setCollectableName:selectedReward];
                
		[appDelegate.userCollection addObject:selectedReward];
	}
    
	//Reward ethicals    
	UserCollectable *currentUserCollectable = [currentUserCollectableDAO read:kCollectableEthicals];
    
	//Increase the moral's value
	int ethicalIncrease = [[currentUserCollectable collectableValue] intValue];

	[moralRewardLabel setText:[NSString stringWithString:@"+1"]];
    //append epsilon to score
	[ethicalRewardLabel setText:[NSString stringWithFormat:@"+%dε", [selectedReward intValue]]];
    
	//Limit total ethicals to 999
	//@todo make constant
	if (ethicalIncrease >= 999) {
		ethicalIncrease = 999;
	} else {
		ethicalIncrease += [selectedReward intValue];
	}
    
	[currentUserCollectable setValue:[NSNumber numberWithInt:ethicalIncrease] forKey:@"collectableValue"];
        
	[selectedReward release];
    
    [currentUserDilemmaDAO update];
    [currentUserCollectableDAO update];
    [currentUserDilemmaDAO release];
    [currentUserCollectableDAO release];
    
	//Create a User Choice so that User's Moral report is affected
	//Prefix with dile- on a User prohibited field to ensure that entry is never shown on ConscienceListViewController
    UserChoiceDAO *currentUserChoiceDAO = [[UserChoiceDAO alloc] initWithKey:@""];

	UserChoice *currentUserChoice = [currentUserChoiceDAO create];    
	[currentUserChoice setEntryCreationDate:[NSDate date]];
    
	NSMutableString *moralType = [[NSMutableString alloc] initWithString:@""];
    
	//Determine Moral to go along with UserChoice
	if (isChoiceA) {
		[moralType appendString:moralADescription];
	} else {
		[moralType appendString:moralBDescription];
	}

	//Account for weight calculation, virtue = +, vice = -    
	BOOL isGood = FALSE;
	if ([moralType isEqualToString:@"Virtue"]) {
		isGood = TRUE;
	}

	[moralType release];
    
	//Commit UserChoice
	[currentUserChoice setEntryShortDescription:dilemmaName];
	[currentUserChoice setEntryLongDescription:@""];
	[currentUserChoice setEntrySeverity:[NSNumber numberWithFloat:1]];
	[currentUserChoice setEntryModificationDate:[NSDate date]];
	[currentUserChoice setEntryKey:dilemmaKey];
	[currentUserChoice setChoiceMoral:moralKey];
	[currentUserChoice setChoiceJustification:@""];
	[currentUserChoice setChoiceInfluence:[NSNumber numberWithInt:1]];
	[currentUserChoice setEntryIsGood:[NSNumber numberWithBool:isGood]];
	[currentUserChoice setChoiceConsequences:@""];
    
    [moralKey release];

	if (isGood) {
		[currentUserChoice setChoiceWeight:[NSNumber numberWithFloat:0.2]];  
	} else {
		[currentUserChoice setChoiceWeight:[NSNumber numberWithFloat:-0.2]];  
	}
    
    [currentUserChoiceDAO update];
    [currentUserChoiceDAO release];
    
    /** @todo refactor into ConscienceMind
     */
    float newMood = appDelegate.userConscienceMind.mood + 0.5;
    float newEnthusiasm = appDelegate.userConscienceMind.enthusiasm + 0.5;
    
    if (newMood > 90) {
        appDelegate.userConscienceMind.mood = 10.0;
    } else if (newMood < 10) {
        appDelegate.userConscienceMind.mood = 10.0;
    } else {
        appDelegate.userConscienceMind.mood = newMood;        
    }
    
    if (newEnthusiasm > 90) {
        appDelegate.userConscienceMind.enthusiasm = 90.0;
    } else if (newEnthusiasm < 10) {
        appDelegate.userConscienceMind.enthusiasm = 10.0;
    } else {
        appDelegate.userConscienceMind.enthusiasm = newEnthusiasm;        
    }
    
    UserCharacterDAO *currentUserCharacterDAO = [[UserCharacterDAO alloc] init];
    UserCharacter *currentUserCharacter = [currentUserCharacterDAO read:@""];
    [currentUserCharacter setCharacterMood:[NSNumber numberWithFloat:newMood]];    
    [currentUserCharacter setCharacterEnthusiasm:[NSNumber numberWithFloat:newEnthusiasm]];
    
    [currentUserCharacterDAO update];
    
    [currentUserCharacterDAO release];  
    
}

- (void) animateViewDetail: (int) viewToAnimateIndex atBeginning: (BOOL) isBeginning {
    
    int animationType = arc4random()%4;
    CGAffineTransform viewAnimationTransform;
    
    switch (animationType) {
        case 0:{
            viewAnimationTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(6.0f, 6.0f), CGAffineTransformMakeRotation(M_PI * -1));                
        }
            break;
        case 1:{
            viewAnimationTransform = CGAffineTransformMakeTranslation(0, 400);                
        }
            break;                        
        case 2:{
            viewAnimationTransform = CGAffineTransformMakeTranslation(400, 0);                
        }
            break;                        
        case 3:{
            viewAnimationTransform = CGAffineTransformMakeTranslation(-400, 0);                
        }
            break; 
        default:
            break;
    }
    
    if (isBeginning) {
    
        switch (viewToAnimateIndex) {
            case kViewVersus: {
                versusImage.alpha = 0;
                versusImage.transform = viewAnimationTransform;

            }
                break;
            case kViewReward: {
                rewardView.alpha = 0;
                rewardView.transform = viewAnimationTransform;
                
            }
                break;            
            default:
                break;
        }
        
    } else {

        switch (viewToAnimateIndex) {
            case kViewVersus: {
                //Animate vs. image and Consciences
                [UIView beginAnimations:@"Versus" context:nil];
                [UIView setAnimationDuration:0.5];
                [UIView setAnimationBeginsFromCurrentState:YES];
                versusImage.alpha = 1;
                versusImage.transform = CGAffineTransformIdentity;                        
                [UIView commitAnimations];
                
            }
                break;
            case kViewReward: {
                //Animate reward image
                [UIView beginAnimations:@"Reward" context:nil];
                [UIView setAnimationDuration:0.75];
                [UIView setAnimationBeginsFromCurrentState:YES];
                rewardView.alpha = 1;
                rewardView.transform = CGAffineTransformIdentity;                        
                [UIView commitAnimations];
            }
                break;            
            default:
                break;
        }
        
    }
}

#pragma mark -
#pragma mark ViewControllerLocalization Protocol

- (void) localizeUI {
    previousButton.accessibilityHint = NSLocalizedString(@"PreviousButtonHint", @"Hint for previous button");
	previousButton.accessibilityLabel =  NSLocalizedString(@"PreviousButtonLabel",@"Label for previous button");
    
    nextButton.accessibilityHint = NSLocalizedString(@"NextButtonHint", @"Hint for next button");
	nextButton.accessibilityLabel =  NSLocalizedString(@"NextButtonLabel",@"Label for next button");
    
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


- (void)dealloc {
    [reward1 release];
    [reward2 release];
    [dilemmaName release];
    [moralAName release];
    [moralBName release];
    [moralADescription release];
    [moralBDescription release];
    
    [super dealloc];

}


@end
