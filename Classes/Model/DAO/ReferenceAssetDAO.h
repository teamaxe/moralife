@class ModelManager;

@interface ReferenceAssetDAO : NSObject

@property (nonatomic, retain) NSArray *sorts;
@property (nonatomic, retain) NSArray *predicates;

- (id)initWithKey:(NSString *)key;
- (id)initWithKey:(NSString *)key andModelManager:(ModelManager *)moralModelManager;

- (NSString *)readShortDescription:(NSString *)key;
- (NSString *)readLongDescription:(NSString *)key;
- (NSString *)readDisplayName:(NSString *)key;
- (NSString *)readImageName:(NSString *)key;
- (NSString *)readLink:(NSString *)key;

- (NSArray *)readAllNames;
- (NSArray *)readAllDisplayNames;
- (NSArray *)readAllImageNames;
- (NSArray *)readAllLongDescriptions;
- (NSArray *)readAllShortDescriptions;
- (NSArray *)readAllLinks;

@end
