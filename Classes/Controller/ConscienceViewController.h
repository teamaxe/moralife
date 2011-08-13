/**
MoraLife Home Screen.  Landing UIViewController for application.
Primary screen for entire Application Workflow.  Provides high-level feedback for User review.

@class ConscienceViewController
@see ConscienceModalViewController

@author Copyright 2010 Team Axe, LLC. All rights reserved. http://www.teamaxe.org
@date 06/23/2010
@file
*/

#import "CoreData/CoreData.h"

@class MoraLifeAppDelegate, ConscienceView;

@interface ConscienceViewController : UIViewController {

	MoraLifeAppDelegate *appDelegate;		/**< delegate for application level callbacks */
	NSUserDefaults *prefs;				/**< serialized user settings/state retention */
	NSManagedObjectContext *context;		/**< Core Data context */

	IBOutlet UILabel *conscienceStatus;				/**< Conscience's thought presented in bubble */
	IBOutlet ConscienceView *initialConscienceView;		/**< pointer to UserConscienceView */
	IBOutlet UIImageView *thoughtBubbleView1;			/**< bubble surrounding Conscience's thought */
	IBOutlet UIView *consciencePlayground;			/**< area in which custom ConscienceView can float */
	IBOutlet UIView *thoughtArea;					/**< area in which thought bubble appears */
	
	IBOutlet UIImageView *virtueImage;				/**< most prominent virtue image */
	IBOutlet UIImageView *viceImage;				/**< most troublesome vice image */
	IBOutlet UIImageView *rankImage;				/**< current rank image */
	IBOutlet UILabel *virtueLabel;				/**< most prominent virtue label */
	IBOutlet UILabel *viceLabel;					/**< most prominent vice label */
	IBOutlet UILabel *rankLabel;					/**< rank frame label */    
    
	IBOutlet UIButton *virtueButton;				/**< button surrounding picture frame to cue virtue thought */
	IBOutlet UIButton *viceButton;                  /**< button surrounding picture frame to cue virtue thought */
	IBOutlet UIButton *rankButton;                  /**< picture frame to launch ConscienceModalViewController */

	NSTimer *moveTimer;				/**< controls Conscience movement */
	NSTimer *shakeTimer;				/**< limits Conscience shake response */
	NSTimer *holdTapTimer;				/**< determines if long press was initiated */
	NSTimer *thoughtFadeTimer;			/**< determines when Conscience thought disappears */

	CGFloat animationDuration;			/**< assists in gesture recognition */	
	CGFloat initialTapDistance;			/**< assists in gesture recognition */
	    
	NSMutableString *homeVirtueDisplayName;	/**< most prominent virtue text */
	NSMutableString *homeViceDisplayName;	/**< most prominent vice text */
    NSMutableString *highestRankName;       /**< highest achieved rank */

	BOOL isBeingMoved;

}

-(CGFloat) angleBetweenLinesInRadians: (CGPoint)line1Start toPoint:(CGPoint)line1End fromPoint:(CGPoint)line2Start toPoint:(CGPoint)line2End;
-(CGFloat) distanceBetweenTwoPoints:(CGPoint)fromPoint toPoint:(CGPoint)toPoint;

/**
Present a thought bubble to the User, suggesting that the UserConscience is talking
 */
-(void) showThought;
/**
Hide the thought bubble.
 */
-(void) hideThought;
/**
Present the ConscienceModalViewController for Conscience interaction
 */
-(void) showConscienceModal;
/**
On first launch, play an introduction
 */
-(void) showIntroView;
/**
Accepts User input in order to determine which thought Bubble to dislay or ConscienceModalViewController
@param sender id which requested the function
 */
-(IBAction) selectNextView:(id) sender;
-(void) refreshConscience;
/**
Cancel all of shooken UserConscience behavior
 */
-(void) shakeEnd;
/**
Move the UserConscience around screen
 */
-(void) timedMovement;
/**
Setup the movement timer
 */
-(void) setTimers;
/**
Stop the movement timer
 */
-(void) stopTimers;
/**
Create welcome message thought bubble for UserConscience
 */
-(void) createWelcomeMessage;
/**
Calculate through all UserChoices which most prominent/troublesome virtue/vice is
@param isVirtue bool representing whether virtue or vice was requested
 */
-(void) retrieveBiggestChoice:(BOOL) isVirtue;
/**
Find highest rank
 */
-(void) retrieveHighestRank;
/**
User choices affect UserConscience immediately, must return Conscience to regular state
@param originalMood float representing overall Conscience mood
@param originalEnthusiasm float representing overall Conscience enthusiasm
 */
-(void) resetMood:(float) originalMood andEnthusiasm:(float) originalEnthusiasm;

-(void) createMovementReaction;
-(void) endMovementReaction;
-(void) setupModalWorkflow;

@end