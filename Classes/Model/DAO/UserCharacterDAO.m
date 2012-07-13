#import "UserCharacterDAO.h"
#import "MoraLifeAppDelegate.h"
#import "ModelManager.h"

@interface UserCharacterDAO ()

@property (nonatomic, retain) NSString *currentKey;
@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic, retain) NSMutableArray *persistedObjects;

- (UserCharacter *)findPersistedObject:(NSString *)key;
- (NSArray *)retrievePersistedObjects;

@end

@implementation UserCharacterDAO 

@synthesize sorts = _sorts;
@synthesize predicates = _predicates;

@synthesize currentKey = _currentKey;
@synthesize context = _context;
@synthesize persistedObjects = _persistedObjects;

- (id)init {    
    return [self initWithKey:nil];
}

- (id)initWithKey:(NSString *)key {
    
    MoraLifeAppDelegate *appDelegate = (MoraLifeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    return [self initWithKey:key andModelManager: [appDelegate moralModelManager]];
}

- (id)initWithKey:(NSString *)key andModelManager:(ModelManager *)moralModelManager {
    
    self = [super init];
    
    if (self) {
        _context = [[moralModelManager readWriteManagedObjectContext] retain];
        
        _sorts = [[NSArray alloc] init];
        _predicates = [[NSArray alloc] init];
        
        if (key) {
            _currentKey = [[NSString alloc] initWithFormat:key];
        } else {
            _currentKey = [[NSString alloc] initWithFormat:@""];
        }
        
        _persistedObjects = [[NSMutableArray alloc] initWithArray:[self retrievePersistedObjects]];
        
    }
    
    return self;
}

- (UserCharacter *)create {
    return [NSEntityDescription insertNewObjectForEntityForName:@"UserCharacter" inManagedObjectContext:self.context];   
}

- (UserCharacter *)read:(NSString *)key {
    return [self findPersistedObject:key];
}

- (NSArray *)readAll {
    [self refreshData];    
    return self.persistedObjects;
}

- (BOOL)update {
    NSError *error = nil;
    
    if ([_context hasChanges]) {
        [_context save:&error];
    }
    
    return error ? TRUE : FALSE;
}

- (BOOL)delete:(UserCharacter *)character {
    NSError *error = nil;
    
    if (character) {
        [_context delete:character];
    } else {
        [_context delete:[self findPersistedObject:self.currentKey]];
    }     
    
    if ([_context hasChanges]) {
        [_context save:&error];
    }
        
    return error ? TRUE : FALSE;
    
}

#pragma mark -
#pragma mark Private API
- (UserCharacter *)findPersistedObject:(NSString *)key {  
        
    [self refreshData];
    
    NSPredicate *findPred;
    NSArray *objects;
    
    if (![key isEqualToString:@""]) {
        findPred = [NSPredicate predicateWithFormat:@"characterName == %@", key];
        objects = [self.persistedObjects filteredArrayUsingPredicate:findPred];
    } else {
        objects = self.persistedObjects;
    }

    if (objects.count > 0) {
        return [objects objectAtIndex:0];
    } else {
        return nil;
    }
    
}

- (void)refreshData {
    [self.persistedObjects removeAllObjects];
    [self.persistedObjects addObjectsFromArray:[self retrievePersistedObjects]];
    
}

- (NSArray *)retrievePersistedObjects {	
	NSError *outError;
	
	NSEntityDescription *entityAssetDesc = [NSEntityDescription entityForName:@"UserCharacter" inManagedObjectContext:self.context];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityAssetDesc];
    
    NSMutableArray *currentPredicates = [[NSMutableArray alloc] initWithArray:self.predicates];
    
    if (![self.currentKey isEqualToString:@""]) {
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"characterName == %@", self.currentKey];
        [currentPredicates addObject:pred];
    }
    
    NSPredicate *currentPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:currentPredicates];
    [request setPredicate:currentPredicate];
    
    [currentPredicates release];    
    
	if (self.sorts.count > 0) {
        [request setSortDescriptors:self.sorts];
    } else {
        NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"characterName" ascending:YES];
        NSArray* sortDescriptors = [[NSArray alloc] initWithObjects: sortDescriptor, nil];
        [request setSortDescriptors:sortDescriptors];
        [sortDescriptor release];
        [sortDescriptors release];
    }    
    	
	NSArray *objects = [self.context executeFetchRequest:request error:&outError];
    	
	[request release];
    
    return objects;

}

-(void)dealloc {
    [_predicates release];
    [_sorts release];
    [_currentKey release];
    [_context release];
    [_persistedObjects release];
    [super dealloc];
}

@end
