/**
Reference Menu screen.  

Primary screen of Reference selection Workflow.  User can select what type of Reference is desired.

@class ReferenceViewController
@see ReferenceListViewController
 
@author Copyright 2020 Adam Axe. All rights reserved. http://www.adamaxe.com
@date 05/17/2010
@file
@todo rename to ReferenceInitViewController
*/

#import "MoraLifeViewController.h"

@interface ReferenceViewController : MoraLifeViewController

/**
Accepts User input to determine type of Reference requested
@param sender id Object which requested method
@return IBAction referenced from Interface Builder
 */
- (IBAction) selectReferenceType:(id)sender;

@end
