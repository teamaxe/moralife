/**
Moralife UI Main Navigation traversal validation
 
@author Copyright 2012 Team Axe, LLC. All rights reserved. http://www.teamaxe.org

@date 05/28/2012
@file mainnavigation.js
*/

#import "include/uiajsinclude.js"

var testSuiteName = "Main UITabBar Navigation";
var testCaseName;

UIALogger.logMessage(testSuiteName + " Testing Begins");

testCaseName = testSuiteName + " ConscienceView (Home)";

UIALogger.logStart(testCaseName + " Test");

if (app.tabBar().buttons()["Home"].checkIsValid()) {
    app.tabBar().buttons()["Home"].tap();
    
    UIALogger.logPass(testCaseName + " loaded"); 
} else {
   UIALogger.logFail(testCaseName + " NOT loaded"); 
} 

testCaseName = testSuiteName + " rankButton";

UIALogger.logStart(testCaseName + " Test");

if (window.buttons()["Rank"].checkIsValid()) {
    window.buttons()["Rank"].tap();
    
    UIALogger.logPass(testCaseName + " loaded"); 
} else {
    UIALogger.logFail(testCaseName + " NOT loaded"); 
} 

testCaseName = testSuiteName + " viceButton";

UIALogger.logStart(testCaseName + " Test");

if (window.buttons()["Vice"].checkIsValid()) {
    window.buttons()["Vice"].tap();
    
    UIALogger.logPass(testCaseName + " loaded"); 
} else {
    UIALogger.logFail(testCaseName + " NOT loaded"); 
} 

testCaseName = testSuiteName + " virtueButton";

UIALogger.logStart(testCaseName + " Test");

if (window.buttons()["Virtue"].checkIsValid()) {
    window.buttons()["Virtue"].tap();
    
    UIALogger.logPass(testCaseName + " loaded"); 
} else {
    UIALogger.logFail(testCaseName + " NOT loaded"); 
} 

testCaseName = testSuiteName + " ChoiceInit (Journal)";

UIALogger.logStart(testCaseName + " Test");

if (app.tabBar().buttons()["Journal"].checkIsValid()){ 

    app.tabBar().buttons()["Journal"].tap();
    window.buttons()["Moral Choice"].tap();
    app.navigationBar().leftButton().tap();
        
    window.buttons()["Immoral Choice"].tap();
    app.navigationBar().leftButton().tap();    
    
    window.buttons()["All Choices"].tap();
    app.navigationBar().leftButton().tap();

    UIALogger.logPass(testCaseName + " loaded"); 
} else {
    UIALogger.logFail(testCaseName + " NOT loaded"); 
}

testCaseName = testSuiteName + " Choice (Moral)";

UIALogger.logStart(testCaseName + " Test");

if (app.tabBar().buttons()["Journal"].checkIsValid()){ 
    app.tabBar().buttons()["Journal"].tap();
    window.buttons()["Moral Choice"].tap();
    window.buttons()["Moral History"].tap();
    window.buttons()["Previous"].tap();
    window.buttons()["Moral Reference"].tap();
    window.buttons()["Previous"].tap();
    window.buttons()["Select a Virtue"].tap();
    window.buttons()["Previous"].tap();    
    app.navigationBar().rightButton().tap();
    app.navigationBar().leftButton().tap();
    app.navigationBar().leftButton().tap();
    
    UIALogger.logPass(testCaseName + " loaded"); 
} else {
    UIALogger.logFail(testCaseName + " NOT loaded"); 
}

testCaseName = testSuiteName + " Choice (Immoral)";

UIALogger.logStart(testCaseName + " Test");

if (app.tabBar().buttons()["Journal"].checkIsValid()){ 
    app.tabBar().buttons()["Journal"].tap();    
    
    window.buttons()["Immoral Choice"].tap();
    app.navigationBar().rightButton().tap();
    app.navigationBar().leftButton().tap();
    app.navigationBar().leftButton().tap();
    
    UIALogger.logPass(testCaseName + " loaded"); 
} else {
    UIALogger.logFail(testCaseName + " NOT loaded"); 
}

testCaseName = testSuiteName + " All Choices Screen";

UIALogger.logStart(testCaseName + " Test");

if (app.tabBar().buttons()["Journal"].checkIsValid()){ 
    app.tabBar().buttons()["Journal"].tap();
    
    window.buttons()["All Choices"].tap();
    window.buttons()["Sort"].tap();
    window.buttons()["Order"].tap();    
    app.navigationBar().leftButton().tap();

    UIALogger.logPass(testCaseName + " loaded"); 
} else {
    UIALogger.logFail(testCaseName + " NOT loaded"); 
}

testCaseName = testSuiteName + " Collection Init";

UIALogger.logStart(testCaseName + " Test");

if (app.tabBar().buttons()["Collection"].checkIsValid()) {
    app.tabBar().buttons()["Collection"].tap();
    
    UIALogger.logPass(testCaseName + " loaded"); 
} else {
    UIALogger.logFail(testCaseName + " NOT loaded"); 
}

testCaseName = testSuiteName + " Accessories";

UIALogger.logStart(testCaseName + " Test");

if (window.buttons()["Accessories"].checkIsValid()){ 
    window.buttons()["Accessories"].tap();
    app.navigationBar().leftButton().tap();
    
    UIALogger.logPass(testCaseName + " loaded"); 
} else {
    UIALogger.logFail(testCaseName + " NOT loaded"); 
}

testCaseName = testSuiteName + " Figures";

UIALogger.logStart(testCaseName + " Test");

if (window.buttons()["Figures"].checkIsValid()){ 
    window.buttons()["Figures"].tap();
    app.navigationBar().leftButton().tap();
    
    UIALogger.logPass(testCaseName + " loaded"); 
} else {
    UIALogger.logFail(testCaseName + " NOT loaded"); 
}

testCaseName = testSuiteName + " Morals";

UIALogger.logStart(testCaseName + " Test");

if (window.buttons()["Morals"].checkIsValid()){ 
    window.buttons()["Morals"].tap();
    app.navigationBar().leftButton().tap();
    
    UIALogger.logPass(testCaseName + " loaded"); 
} else {
    UIALogger.logFail(testCaseName + " NOT loaded"); 
}

app.tabBar().buttons()["Home"].tap();
