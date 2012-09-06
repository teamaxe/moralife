#import "MoraLifeAppDelegate.h"
#import "ReferenceModel.h"
#import "ModelManager.h"
#import "UserChoiceDAO.h"
#import "ConscienceAssetDAO.h"
#import "ReferenceAssetDAO.h"
#import "ReferenceBeliefDAO.h"
#import "ReferencePersonDAO.h"
#import "ReferenceTextDAO.h"
#import "MoralDAO.h"

@interface ReferenceModel () {
    NSUserDefaults *preferences;            /**< User defaults to write to file system */
    MoralDAO *currentMoralDAO;              /**< retrieve morals User has utilized */
    NSArray *currentUserCollection;                /**< collection of owned Assets */

}

@property (nonatomic, readwrite, retain) NSMutableArray *references;			/**< Array of User-entered choice titles */
@property (nonatomic, readwrite, retain) NSMutableArray *referenceKeys;			/**< Array of User-entered choice titles */
@property (nonatomic, readwrite, retain) NSMutableArray *details;			/**< Array of User-entered details */
@property (nonatomic, readwrite, retain) NSMutableArray *icons;				/**< Array of associated images */

/**
 Retrieve all User entered Choices
 */
- (void) retrieveAllReferences;

@end

@implementation ReferenceModel

- (id)init {
    MoraLifeAppDelegate *appDelegate = (MoraLifeAppDelegate *)[[UIApplication sharedApplication] delegate];

    return [self initWithModelManager:[appDelegate moralModelManager] andDefaults:[NSUserDefaults standardUserDefaults] andUserCollection:appDelegate.userCollection];
}

- (id)initWithModelManager:(ModelManager *) modelManager andDefaults:(NSUserDefaults *) prefs andUserCollection:(NSArray *) userCollection{

    self = [super init];
    if (self) {

        _referenceType = kReferenceModelTypeConscienceAsset;
        _references = [[NSMutableArray alloc] init];
        _referenceKeys = [[NSMutableArray alloc] init];
        _details = [[NSMutableArray alloc] init];
        _icons = [[NSMutableArray alloc] init];
        preferences = prefs;
        currentUserCollection = userCollection;

        currentMoralDAO = [[MoralDAO alloc] initWithKey:@"" andModelManager:modelManager];

    }

    [self retrieveAllReferences];

    return self;
    
}

#pragma mark -
#pragma mark Overloaded Setters

/* Whenever referenceType is changed from ViewController, model is refreshed */
- (void) setReferenceType:(int)referenceType {
    if (_referenceType != referenceType) {
        _referenceType = referenceType;
        [self retrieveAllReferences];
    }
}

/**
 Implementation: Retrieve all User entered Choices, and then populate a working set of data containers upon which to filter.
 */
- (void) retrieveAllReferences {

	//Clear all datasets
	[self.references removeAllObjects];
	[self.referenceKeys removeAllObjects];
	[self.icons removeAllObjects];
	[self.details removeAllObjects];

    id currentDAO;	

    //Populate subsequent list controller with appropriate choice
	switch (_referenceType){
		case kReferenceModelTypeConscienceAsset:
			currentDAO = [[ConscienceAssetDAO alloc] init];
			break;
		case kReferenceModelTypeBelief:
			currentDAO = [[ReferenceBeliefDAO alloc] init];
			break;
		case kReferenceModelTypeText:
			currentDAO = [[ReferenceTextDAO alloc] init];
			break;
		case kReferenceModelTypePerson:
			currentDAO = [[ReferencePersonDAO alloc] init];
			break;
		case kReferenceModelTypeMoral:
			currentDAO = [[MoralDAO alloc] init];
			break;
        case kReferenceModelTypeReferenceAsset:
            currentDAO = [[ReferenceAssetDAO alloc] init];
            break;
		default:
			currentDAO = [[ReferenceAssetDAO alloc] init];
			break;
	}

    if (_referenceType != kReferenceModelTypeMoral) {
        NSSortDescriptor* sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"shortDescriptionReference" ascending:YES];

        NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects: sortDescriptor1, nil] autorelease];
        [sortDescriptor1 release];
        [currentDAO setSorts:sortDescriptors];
    }


	/** @bug leaks complaint */
	NSArray *objects = [currentDAO readAll];

	if ([objects count] > 0) {

        if (_referenceType != kReferenceModelTypeMoral) {
            for (ReferenceAsset *matches in objects){

                //Is the asset owned
                if([currentUserCollection containsObject:[matches nameReference]]){

                    [self.references addObject:[matches displayNameReference]];
                    [self.icons addObject:[matches imageNameReference]];
                    [self.details addObject:[matches shortDescriptionReference]];
                    [self.referenceKeys addObject:[matches nameReference]];
                }

            }
        } else {

            for (Moral *matches in objects){

                if([currentUserCollection containsObject:[matches nameMoral]]){

                    [self.references addObject:[matches displayNameMoral]];
                    [self.icons addObject:[matches imageNameMoral]];
                    [self.details addObject:[NSString stringWithFormat:@"%@: %@", [matches shortDescriptionMoral], [matches longDescriptionMoral]]];
                    [self.referenceKeys addObject:[matches nameMoral]];
                }
            }

		}
    }

    [currentDAO release];
}

/**
 Implementation: Retrieve a requested Choice and set NSUserDefaults for ChoiceViewController to read
 */
- (void) retrieveReference:(NSString *) referenceKey {

    //Set state retention for eventual call to ChoiceViewController to pick up
    [preferences setInteger:self.referenceType forKey:@"referenceType"];
    [preferences setObject:referenceKey forKey:@"referenceKey"];

    [preferences synchronize];

}

-(void)dealloc {

    [_references release];
    [_referenceKeys release];
    [_details release];
    [_icons release];
    [currentMoralDAO release];

    [super dealloc];
}


@end
