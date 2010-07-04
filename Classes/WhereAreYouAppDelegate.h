//
//  WhereAreYouAppDelegate.h
//  WhereAreYou
//
//  Created by Илья Кулаков on 19.06.10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@class WAYRootViewController;
@class WAYMapViewController;

@interface WhereAreYouAppDelegate : NSObject <UIApplicationDelegate> {
    
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
	
    UIWindow *window;

	UISplitViewController *splitViewController;

	WAYRootViewController *rootViewController;
	WAYMapViewController *detailViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) IBOutlet WAYRootViewController *rootViewController;
@property (nonatomic, retain) IBOutlet WAYMapViewController *detailViewController;

@end
