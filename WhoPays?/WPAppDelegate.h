//
//  WPAppDelegate.h
//  WhoPays?
//
//  Created by sonossqa on 5/23/14.
//  Copyright (c) 2014 Malcolm Crum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
