#import "MoraLifeAppDelegate.h"
#import "ReferenceAssetDAO.h"

@implementation ReferenceAssetDAO 

- (id) init {
    return [self initWithKey:nil];
}

- (id)initWithKey:(NSString *)key {
    MoraLifeAppDelegate *appDelegate = (MoraLifeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    return [self initWithKey:key andModelManager:[appDelegate moralModelManager]];
}

- (id)initWithKey:(NSString *)key andModelManager:(ModelManager *)moralModelManager {
    
    self = [super initWithKey:key andModelManager:moralModelManager andClassType:kContextReadOnly];
    
    if (self) {
        [self.predicateDefaultName setString:@"nameReference"];
        [self.sortDefaultName setString:@"nameReference"];
        [self.managedObjectClassName setString:@"ReferenceAsset"];
    }
    
    return self;
    
}

- (ReferenceAsset *)create {
    return (ReferenceAsset *)[self createObject];
}

- (ReferenceAsset *)read:(NSString *)key {
    return (ReferenceAsset *)[self readObject:key];
}

-(void)dealloc {
    [super dealloc];
}

@end