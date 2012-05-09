#import "TestCoreDataStack.h"
#import "UserCharacter.h"

@interface TestUserCharacter: SenTestCase {
    TestCoreDataStack *coreData;
    UserCharacter *testUserCharacter;
    
    NSString * characterAccessoryPrimary;
    NSString * characterAccessorySecondary;
    NSString * characterAccessoryTop;
    NSString * characterAccessoryBottom;
    NSString * characterFace;
    NSString * characterName;
    NSString * characterEye;
    NSString * characterMouth;
    NSNumber * characterEnthusiasm;
    NSNumber * characterAge;
    NSNumber * characterMood;
    NSString * characterEyeColor;
    NSString * characterBrowColor;
    NSString * characterBubbleColor;
    NSNumber * characterSize;
    NSNumber * characterBubbleType;    
}

@end

@implementation TestUserCharacter

- (void)setUp {
    coreData = [[TestCoreDataStack alloc] initWithManagedObjectModel:@"UserData"];
    
    characterAccessoryPrimary = @"accessoryPrimary";
    characterAccessorySecondary = @"accessorySecondary";
    characterAccessoryTop = @"accessoryTop";
    characterAccessoryBottom = @"accessoryBottom";
    characterFace = @"face";
    characterName = @"name";
    characterEye = @"eye";
    characterMouth = @"mouth";
    characterEnthusiasm = [NSNumber numberWithFloat:1.0];
    characterAge = [NSNumber numberWithFloat:1.0];
    characterMood = [NSNumber numberWithFloat:1.0];
    characterEyeColor = @"eyeColor";
    characterBrowColor = @"browColor";
    characterBubbleColor = @"bubbleColor";
    characterSize = [NSNumber numberWithFloat:1.0];
    characterBubbleType = [NSNumber numberWithFloat:1.0];
    
    testUserCharacter = [coreData insert:UserCharacter.class];
    
    testUserCharacter.characterAccessoryPrimary = characterAccessoryPrimary;
    testUserCharacter.characterAccessorySecondary = characterAccessorySecondary;
    testUserCharacter.characterAccessoryTop = characterAccessoryTop;
    testUserCharacter.characterAccessoryBottom = characterAccessoryBottom;
    testUserCharacter.characterFace = characterFace;
    testUserCharacter.characterName = characterName;
    testUserCharacter.characterEye = characterEye;
    testUserCharacter.characterMouth = characterMouth;
    testUserCharacter.characterEnthusiasm = characterEnthusiasm;
    testUserCharacter.characterAge = characterAge;
    testUserCharacter.characterMood = characterMood;
    testUserCharacter.characterEyeColor = characterEyeColor;
    testUserCharacter.characterBrowColor = characterBrowColor;
    testUserCharacter.characterBubbleColor = characterBubbleColor;
    testUserCharacter.characterSize = characterSize;
    testUserCharacter.characterBubbleType = characterBubbleType;
    
}

- (void)testUserCharacterCanBeCreated {
    
    //testUserCollectable are created in setup    
    STAssertNoThrow([coreData save], @"UserCharacter can't be created.");
    
}

- (void)testUserCharacterAccessorsAreFunctional {
    
    STAssertNoThrow([coreData save], @"UserCharacter can't be created for Accessor test.");
    
    NSArray *characters = [coreData fetch:UserCharacter.class];
    
    STAssertEquals(characters.count, (NSUInteger) 1, @"There should only be 1 UserCollectable in the context.");
    UserCharacter *retrieved = [characters objectAtIndex: 0];
    
    STAssertEqualObjects(retrieved.characterEnthusiasm, characterEnthusiasm, @"characterEnthusiasm Getter/Setter failed.");
    STAssertEqualObjects(retrieved.characterAge, characterAge, @"characterAge Getter/Setter failed.");
    STAssertEqualObjects(retrieved.characterMood, characterMood, @"characterMood Getter/Setter failed.");
    STAssertEqualObjects(retrieved.characterSize, characterSize, @"characterSize Getter/Setter failed.");
    STAssertEqualObjects(retrieved.characterBubbleType, characterBubbleType, @"characterBubbleType Getter/Setter failed.");    
    STAssertEqualObjects(retrieved.characterAccessoryPrimary, characterAccessoryPrimary, @"characterAccessoryPrimary Getter/Setter failed.");
    STAssertEqualObjects(retrieved.characterAccessorySecondary, characterAccessorySecondary, @"characterAccessorySecondary Getter/Setter failed.");
    STAssertEqualObjects(retrieved.characterAccessoryTop, characterAccessoryTop, @"characterAccessoryTop Getter/Setter failed.");
    STAssertEqualObjects(retrieved.characterAccessoryBottom, characterAccessoryBottom, @"characterAccessoryBottom Getter/Setter failed.");
    STAssertEqualObjects(retrieved.characterFace, characterFace, @"characterFace Getter/Setter failed.");
    STAssertEqualObjects(retrieved.characterName, characterName, @"characterName Getter/Setter failed.");
    STAssertEqualObjects(retrieved.characterEye, characterEye, @"characterEye Getter/Setter failed.");
    STAssertEqualObjects(retrieved.characterMouth, characterMouth, @"characterMouth Getter/Setter failed.");
    STAssertEqualObjects(retrieved.characterEyeColor, characterEyeColor, @"characterEyeColor Getter/Setter failed.");
    STAssertEqualObjects(retrieved.characterBrowColor, characterBrowColor, @"characterBrowColor Getter/Setter failed.");
    STAssertEqualObjects(retrieved.characterBubbleColor, characterBubbleColor, @"characterBubbleColor Getter/Setter failed.");
    
}

- (void)testUserCharacterDeletion {
    STAssertNoThrow([coreData save], @"UserCharacter can't be created for Delete test");
    
    STAssertNoThrow([coreData delete:testUserCharacter], @"UserCharacter can't be deleted");
    
    NSArray *characters = [coreData fetch:UserCharacter.class];
    
    STAssertEquals(characters.count, (NSUInteger) 0, @"UserCharacter is still present after delete");
    
}

- (void)testUserCharacterWithoutRequiredAttributes {
    UserCharacter *testUserCharacterBad = [coreData insert:UserCharacter.class];
    NSString *errorMessage = [NSString stringWithFormat:@"CD should've thrown on %@", testUserCharacterBad.class];
    
    STAssertThrows([coreData save], errorMessage);
}

@end