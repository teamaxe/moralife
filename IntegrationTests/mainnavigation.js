/**
Moralife UI Main Navigation traversal validation
 
@author Copyright 2012 Team Axe, LLC. All rights reserved. http://www.teamaxe.org

@date 05/28/2012
@file mainnavigation.js
*/

var target = UIATarget.localTarget().frontMostApp();
var testSuiteName = "Main UITabBar Navigation";
var testCaseName;

UIALogger.logMessage("MoraLife " + testSuiteName + " Testing Begins");

testCaseName = testSuiteName + " Home Screen";

UIALogger.logStart(testCaseName + " Test");

if (target.tabBar().buttons()["Home"]!=null) {
    target.tabBar().buttons()["Home"].tap();
    
    UIALogger.logPass(testCaseName + " loaded"); 
} else {
   UIALogger.logFail(testCaseName + " NOT loaded"); 
} 

testCaseName = testSuiteName + " Rank Button";

UIALogger.logStart(testCaseName + " Test");

if (target.mainWindow().buttons()["Rank"]!=null) {
    target.mainWindow().buttons()["Rank"].tap();
    
    UIALogger.logPass(testCaseName + " loaded"); 
} else {
    UIALogger.logFail(testCaseName + " NOT loaded"); 
} 

testCaseName = testSuiteName + " Vice Button";

UIALogger.logStart(testCaseName + " Test");

if (target.mainWindow().buttons()["Vice"]!=null) {
    target.mainWindow().buttons()["Vice"].tap();
    
    UIALogger.logPass(testCaseName + " loaded"); 
} else {
    UIALogger.logFail(testCaseName + " NOT loaded"); 
} 

testCaseName = testSuiteName + " Virtue Button";

UIALogger.logStart(testCaseName + " Test");

if (target.mainWindow().buttons()["Virtue"]!=null) {
    target.mainWindow().buttons()["Virtue"].tap();
    
    UIALogger.logPass(testCaseName + " loaded"); 
} else {
    UIALogger.logFail(testCaseName + " NOT loaded"); 
} 

testCaseName = testSuiteName + " Journal Screen";

UIALogger.logStart(testCaseName + " Test");

if (target.tabBar().buttons()["Journal"]!=null){ 

    target.tabBar().buttons()["Journal"].tap();
    target.mainWindow().buttons()["Moral Choice"].tap();
    target.navigationBar().leftButton().tap();
        
    target.mainWindow().buttons()["Immoral Choice"].tap();
    target.navigationBar().leftButton().tap();    
    
    target.mainWindow().buttons()["All Choices"].tap();
    target.navigationBar().leftButton().tap();

    UIALogger.logPass(testCaseName + " loaded"); 
} else {
    UIALogger.logFail(testCaseName + " NOT loaded"); 
}

testCaseName = testSuiteName + " Moral Choice Screen";

UIALogger.logStart(testCaseName + " Test");

if (target.tabBar().buttons()["Journal"]!=null){ 
    target.tabBar().buttons()["Journal"].tap();
    target.mainWindow().buttons()["Moral Choice"].tap();
    target.mainWindow().buttons()["Moral History"].tap();
    target.mainWindow().buttons()["Previous"].tap();
    target.mainWindow().buttons()["Moral Reference"].tap();
    target.mainWindow().buttons()["Previous"].tap();
    target.mainWindow().buttons()["Select a Virtue"].tap();
    target.mainWindow().buttons()["Previous"].tap();    
    target.navigationBar().rightButton().tap();
    target.navigationBar().leftButton().tap();
    target.navigationBar().leftButton().tap();
    
    UIALogger.logPass(testCaseName + " loaded"); 
} else {
    UIALogger.logFail(testCaseName + " NOT loaded"); 
}

testCaseName = testSuiteName + " Immoral Choice Screen";

UIALogger.logStart(testCaseName + " Test");

if (target.tabBar().buttons()["Journal"]!=null){ 
    target.tabBar().buttons()["Journal"].tap();    
    
    target.mainWindow().buttons()["Immoral Choice"].tap();
    target.navigationBar().rightButton().tap();
    target.navigationBar().leftButton().tap();
    target.navigationBar().leftButton().tap();
    
    UIALogger.logPass(testCaseName + " loaded"); 
} else {
    UIALogger.logFail(testCaseName + " NOT loaded"); 
}

testCaseName = testSuiteName + " All Choices Screen";

UIALogger.logStart(testCaseName + " Test");

if (target.tabBar().buttons()["Journal"]!=null){ 
    target.tabBar().buttons()["Journal"].tap();
    
    target.mainWindow().buttons()["All Choices"].tap();
    target.mainWindow().buttons()["Sort"].tap();
    target.mainWindow().buttons()["Order"].tap();    
    target.navigationBar().leftButton().tap();

    UIALogger.logPass(testCaseName + " loaded"); 
} else {
    UIALogger.logFail(testCaseName + " NOT loaded"); 
}

testCaseName = testSuiteName + " Collection Screen";

UIALogger.logStart(testCaseName + " Test");

if (target.tabBar().buttons()["Collection"]!=null) {
    target.tabBar().buttons()["Collection"].tap();
    target.mainWindow().buttons()["Accessories"].tap();
    target.navigationBar().leftButton().tap();
    target.mainWindow().buttons()["Figures"].tap();
    target.navigationBar().leftButton().tap();
    target.mainWindow().buttons()["Morals"].tap();
    target.navigationBar().leftButton().tap();
    target.tabBar().buttons()["Home"].tap();
    
    UIALogger.logPass(testCaseName + " loaded"); 
} else {
    UIALogger.logFail(testCaseName + " NOT loaded"); 
}

target.tabBar().buttons()["Home"].tap();
