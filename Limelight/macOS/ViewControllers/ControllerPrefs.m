//
//  ControllerPrefs.m
//  Moonlight for macOS
//
//  Created by Felipe Morais on 16/09/25.
//  Copyright © 2025 Moonlight Game Streaming Project. All rights reserved.
//

#import "ControllerPrefs.h"
#import "TableViewController.h"
#import "AppDelegateForAppKit.h"

@interface ControllerPrefs ()

@end

@implementation ControllerPrefs


- (void)showWindow:(id)sender{
    [super showWindow:sender];
    [self.window center];
    
    if (!self.tableViewController.hidSupport){
        self.tableViewController.hidSupport = [[HIDSupport alloc] init];
    }
    
    [self reloadControllers];
    [self.tableViewController restoreInvertStates];
}

- (void)reloadControllers{
    NSArray *controllers = [self.tableViewController.hidSupport populateControllerList];
    [self.tableViewController.controllerList removeAllItems];
    [self.tableViewController.controllerList addItemsWithTitles:controllers];
}


- (void)windowWillClose:(NSNotification *)notification {
    id appDelegate = NSApp.delegate;
    [appDelegate destroyControllerWindow];
}

@end
