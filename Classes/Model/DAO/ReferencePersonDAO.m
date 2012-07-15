#import "ReferencePersonDAO.h"
#import "MoraLifeAppDelegate.h"

@implementation ReferencePersonDAO 

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
        [self.managedObjectClassName setString:@"ReferencePerson"];
    }
    
    return self;
    
}

- (ReferencePerson *)create {
    return (ReferencePerson *)[self createObject];
}

- (ReferencePerson *)read:(NSString *)key {
    return (ReferencePerson *)[self readObject:key];
}

-(void)dealloc {
    [super dealloc];
}

@end