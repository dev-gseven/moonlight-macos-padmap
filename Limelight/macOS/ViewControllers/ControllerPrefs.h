//
//  ControllerPrefs.h
//  Moonlight for macOS
//
//  Created by Felipe Morais on 16/09/25.
//  Copyright © 2025 Moonlight Game Streaming Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HIDSupport.h"

NS_ASSUME_NONNULL_BEGIN

@class TableViewController;

@interface ControllerPrefs : NSWindowController

@property (strong) HIDSupport *hidSupport;
@property (weak) IBOutlet TableViewController *tableViewController;

@end

NS_ASSUME_NONNULL_END
