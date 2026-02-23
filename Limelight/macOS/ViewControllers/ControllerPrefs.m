//
//  ControllerPrefs.m
//  Moonlight for macOS
//
//  Created by Felipe Morais on 16/09/25.
//  Copyright © 2025 Moonlight Game Streaming Project. All rights reserved.
//

#import "ControllerPrefs.h"
#import "TableViewController.h"

@interface ControllerPrefs ()

@end

@implementation ControllerPrefs


//- (void)windowDidLoad {
- (void)showWindow:(id)sender{
    [super windowDidLoad];
    [self.window center];
    
    if (!self.hidSupport){
        self.hidSupport = [[HIDSupport alloc] init];
    }
    self.tableViewController.hidSupport = self.hidSupport;
    
    [self reloadControllers];
    [self.tableViewController restoreInvertStates];
}

- (void)reloadControllers{
    NSArray *controllers = [self.hidSupport populateControllerList];
    [self.tableViewController.controllerList removeAllItems];
    [self.tableViewController.controllerList addItemsWithTitles:controllers];
}


- (void)windowWillClose:(NSNotification *)notification {
    [self.hidSupport tearDownHidManager];
    self.hidSupport = nil;
}

@end
