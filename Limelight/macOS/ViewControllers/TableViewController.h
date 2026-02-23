//
//  TableViewController.h
//  Moonlight for macOS
//
//  Created by Felipe Morais on 10/10/25.
//  Copyright © 2025 Moonlight Game Streaming Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BindingData.h"
#import "HIDSupport.h"
#import "ControllerPrefs.h"

NS_ASSUME_NONNULL_BEGIN

@interface TableViewController : NSObject <NSTableViewDataSource>{
@private
    IBOutlet NSTableView *tableView;
    NSMutableArray *list;
}

@property (weak) IBOutlet NSButton *leftYCheckbox;
@property (weak) IBOutlet NSButton *leftXCheckbox;
@property (weak) IBOutlet NSButton *rightYCheckbox;
@property (weak) IBOutlet NSButton *rightXCheckbox;

@property (strong)HIDSupport *hidSupport;
@property (weak) IBOutlet NSPopUpButton *controllerList;
@property (weak) IBOutlet NSTextField *statusLabel;
@property (nonatomic) NSInteger mappingIndex;

- (void)didReceiveMappingHex:(NSString *)hex;
- (void)restoreInvertStates;

- (IBAction)startMapping:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)reload:(id)sender;

- (IBAction)invertLeftY:(id)sender;
- (IBAction)invertLeftX:(id)sender;
- (IBAction)invertRightY:(id)sender;
- (IBAction)invertRightX:(id)sender;

@end

NS_ASSUME_NONNULL_END
