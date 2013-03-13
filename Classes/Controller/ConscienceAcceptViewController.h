/**
Accessory accept screen.  View that allows User to approve purchase/selection.
 
Last screen in the workflow of User attempting to purchase/outfit the Conscience with a ConscienceAsset.

@class ConscienceAcceptViewController
@see ConscienceListViewController
@see ConscienceModalViewController
@see ConscienceViewController

@author Copyright 2010 Team Axe, LLC. All rights reserved. http://www.teamaxe.org
@date 08/25/2010
 */

@class ModelManager, UserConscience;

@interface ConscienceAcceptViewController : UIViewController

@property (nonatomic, assign) int accessorySlot;		/**< which slot is ConscienceAsset, set from ConscienceListViewController */
@property (nonatomic, strong) NSString *assetSelection;	/**< which ConscienceAsset, set from ConscienceListViewController */
@property (nonatomic, strong) UIImage *screenshot;       /**< screenshot of previous screen for transition */

/**
 Creates the viewController with the User's Conscience
 @param modelManager ModelManager data persistence
 @param userConscience UserConscience for modals and help screens
 @return id instance of ConscienceAcceptViewController
 */
-(id)initWithModelManager:(ModelManager *)modelManager andConscience:(UserConscience *)userConscience;

/**
Accepts User input to commit the choice of ConscienceAsset to persistence.  Returns User to ConscienceViewController.
@param sender id of object which requested method
@return IBAction referenced from Interface Builder
 */
-(IBAction)acceptThoughtModal:(id)sender;

@end
