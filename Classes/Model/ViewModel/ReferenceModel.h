/**
 Reference view model.  Generate the various reference assets to which the User has access.

 @class ReferenceModel
 @see ReferenceListViewController

 @author Copyright 2012 Team Axe, LLC. All rights reserved. http://www.teamaxe.org
 @date 08/16/2012
 @file
 */

#import "ModelManager.h"

/**
 Possible Reference Types
 typedef utilized to avoid having to use enum declaration
 */
typedef enum {
	MLReferenceModelTypeConscienceAsset,
	MLReferenceModelTypeBelief,
	MLReferenceModelTypeText,
	MLReferenceModelTypePerson,
	MLReferenceModelTypeMoral,
	MLReferenceModelTypeReferenceAsset
} MLReferenceModelTypeEnum;

@interface ReferenceModel : NSObject

@property (nonatomic, assign) int referenceType;    /**< current reference type */
@property (nonatomic, strong) NSString *referenceKey; /**< pkey for requested asset */

//Raw, readonly data of all entered choices
@property (nonatomic, readonly, strong) NSString *title;    /**< Title of Reference type */
@property (nonatomic, readonly) BOOL hasQuote;              /**< Determine if Reference Type has quotes */
@property (nonatomic, readonly) BOOL hasLink;              /**< Determine if Reference Type has URLs */

@property (nonatomic, readonly, strong) NSMutableArray *references;			/**< reference names */
@property (nonatomic, readonly, strong) NSMutableArray *referenceKeys;     	/**< pkeys for references */
@property (nonatomic, readonly, strong) NSMutableArray *details;			/**< description of Reference */
@property (nonatomic, readonly, strong) NSMutableArray *icons;				/**< associated images */
@property (nonatomic, readonly, strong) NSMutableArray *longDescriptions;			/**< long description of Reference */
@property (nonatomic, readonly, strong) NSMutableArray *links;				/**< associated urls */
@property (nonatomic, readonly, strong) NSMutableArray *originYears;				/**< when the reference was created/born */
@property (nonatomic, readonly, strong) NSMutableArray *endYears;				/**< when the reference ceased to be/died */
@property (nonatomic, readonly, strong) NSMutableArray *originLocations;				/**< origination geography */
@property (nonatomic, readonly, strong) NSMutableArray *orientations;				/**<  */
@property (nonatomic, readonly, strong) NSMutableArray *quotes;				/**<  */
@property (nonatomic, readonly, strong) NSMutableArray *relatedMorals;				/**<  */


/**
 Builds model with dependency injection
 @param modelManager ModelManager for either production or testing
 @param prefs NSUserDefaults for dependency injection
 @param userCollection NSArray of currently owned objects for comparison
 @return id ReferenceModel
 */
- (id)initWithModelManager:(ModelManager *) modelManager andDefaults:(NSUserDefaults *) prefs andUserCollection:(NSArray *) userCollection;

/**
 Retrieve reference for display
 @param reference NSString of requested pkey
 */
- (void) selectReference:(NSString *) referenceKey;

@end
