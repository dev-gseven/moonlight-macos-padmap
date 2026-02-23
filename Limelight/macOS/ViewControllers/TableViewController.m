//
//  TableViewController.m
//  Moonlight for macOS
//
//  Created by Felipe Morais on 10/10/25.
//  Copyright © 2025 Moonlight Game Streaming Project. All rights reserved.
//

#import "TableViewController.h"
#import "HIDSupport.h"
#import <IOKit/hid/IOHIDManager.h>

@interface TableViewController()

@end

@implementation TableViewController

- (id)init {
    self = [super init];
    if (self) {
        list = [[NSMutableArray alloc] init];

        NSArray *bindings = @[@"Up", @"Down", @"Left", @"Right", @"Start", @"Back",
                              @"LS Click", @"RS Click",@"Left Stick ↑ (Move Up)",@"Left Stick ← (Move Left)",@"Right Stick ↑ (Move Up)",@"Right Stick → (Move Right)", @"LB", @"RB", @"LT", @"RT", @"Special", @"A", @"B", @"X", @"Y"];
        NSArray *inputs   = @[@"1", @"2", @"3", @"4", @"5", @"6",
                              @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15",@"16",@"17",@"18",@"19",@"20",@"21"];

        for (NSInteger i = 0; i < [bindings count]; i++) {
            BindingData *data = [[BindingData alloc] initWithBinding:bindings[i] input:inputs[i]];
            [list addObject:data];
        }
    }
    return self;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [list count];
}

// Display the tableView
- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    BindingData *b = [list objectAtIndex:row];
    NSString *identifier = [tableColumn identifier];
    return [b valueForKey:identifier];
}

- (void)showTemporaryStatus:(NSString *)text {
    self.statusLabel.stringValue = text;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        // TODO: fazer algma merda aqui
        if ([self.statusLabel.stringValue isEqualToString:text]) {
            self.statusLabel.stringValue = @"";
        }
    });
}

- (void)saveCurrentMapping {
    
    NSInteger selectedIndex = self.controllerList.indexOfSelectedItem;
    if (selectedIndex < 0) return;

    IOHIDDeviceRef device = (__bridge IOHIDDeviceRef)self.hidSupport.deviceList[selectedIndex];

    NSNumber *vendor = (__bridge NSNumber *)IOHIDDeviceGetProperty(device, CFSTR(kIOHIDVendorIDKey));
    NSNumber *product = (__bridge NSNumber *)IOHIDDeviceGetProperty(device, CFSTR(kIOHIDProductIDKey));

    if (!vendor || !product) return;

    NSString *deviceKey = [NSString stringWithFormat:@"%@_%@", vendor, product];

    NSMutableDictionary *hexToBinding = [NSMutableDictionary dictionary];

    for (BindingData *row in self->list) {
        if (row.input && ![row.input isEqualToString:@"<Waiting for inputs>"]) {
            hexToBinding[row.input] = row.binding;
        }
    }

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *allMappings = [[defaults dictionaryForKey:@"controllerMappings"] mutableCopy];

    if (!allMappings)
        allMappings = [NSMutableDictionary dictionary];

    allMappings[deviceKey] = hexToBinding;

    [defaults setObject:allMappings forKey:@"controllerMappings"];
    [defaults synchronize];

    NSLog(@"[SAVE] Mapping saved to %@", deviceKey);
}


- (void)focusMappingRow {
    
    if (self.mappingIndex < self->list.count){
        BindingData *row = self->list[self.mappingIndex];
        row.input = @"<Waiting for inputs>";
        
        [self->tableView reloadData];
        [self->tableView scrollRowToVisible:self.mappingIndex];
        [self->tableView selectRow:self.mappingIndex byExtendingSelection:NO];
    }
}


- (void)didReceiveMappingHex:(NSString *)hex {

    if (!self.hidSupport.isMapping)
        return;
    
    BindingData *row = self->list[self.mappingIndex];
    row.input = hex;
    self.mappingIndex++;

    if (self.mappingIndex >= self->list.count) {
        self.hidSupport.isMapping = NO;
        
        [self saveCurrentMapping];
        [self showTemporaryStatus:@"Mapping Completed"];
        [self->tableView reloadData];
        return;
    }

    [self focusMappingRow];
    
}


- (void)restoreInvertStates {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.leftXCheckbox.state =
    [defaults boolForKey:kInvertLeftXKey]
    ? NSControlStateValueOn
    : NSControlStateValueOff;
    
    self.leftYCheckbox.state =
    [defaults boolForKey:kInvertLeftYKey]
    ? NSControlStateValueOn
    : NSControlStateValueOff;
    
    self.rightXCheckbox.state =
    [defaults boolForKey:kInvertRightXKey]
    ? NSControlStateValueOn
    : NSControlStateValueOff;
    
    self.rightYCheckbox.state =
    [defaults boolForKey:kInvertRightYKey]
    ? NSControlStateValueOn
    : NSControlStateValueOff;
}

- (IBAction)invertLeftY:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL current = [defaults boolForKey:kInvertLeftYKey];
    [defaults setBool:!current forKey:kInvertLeftYKey];
}

- (IBAction)invertLeftX:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL current = [defaults boolForKey:kInvertLeftXKey];
    [defaults setBool:!current forKey:kInvertLeftXKey];
}

- (IBAction)invertRightY:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL current = [defaults boolForKey:kInvertRightYKey];
    [defaults setBool:!current forKey:kInvertRightYKey];
}

- (IBAction)invertRightX:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL current = [defaults boolForKey:kInvertRightXKey];
    [defaults setBool:!current forKey:kInvertRightXKey];
}

// Connect and start mapping
- (IBAction)startMapping:(id)sender {
    
    NSInteger selectedIndex = self.controllerList.indexOfSelectedItem;
    [self.hidSupport connectToDeviceAtIndex:selectedIndex];
    
    [self showTemporaryStatus:@"Connected"];
    
    self.hidSupport.mapping = self;
    self.hidSupport.isMapping = YES;
    self.mappingIndex = 0;
    
    [self focusMappingRow];
}

// Set as Default
- (IBAction)save:(id)sender {
    
    NSInteger selectedIndex = [self.controllerList indexOfSelectedItem];
    if (selectedIndex < 0 || selectedIndex >= self.hidSupport.deviceList.count) {
        [self showTemporaryStatus:@"No Device Selected"];
        return;
    }

    IOHIDDeviceRef device = (__bridge IOHIDDeviceRef)self.hidSupport.deviceList[selectedIndex];
    NSNumber *vendor = (__bridge NSNumber *)IOHIDDeviceGetProperty(device, CFSTR(kIOHIDVendorIDKey));
    NSNumber *product = (__bridge NSNumber *)IOHIDDeviceGetProperty(device, CFSTR(kIOHIDProductIDKey));

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:vendor.intValue forKey:@"controllerVendorID"];
    [defaults setInteger:product.intValue forKey:@"controllerProductID"];
    [defaults synchronize];

    NSLog(@"[SAVE] Device %@_%@ is now Default", vendor, product);
    
    [self showTemporaryStatus:@"Saved"];

}

- (IBAction)reload:(id)sender {

    NSArray *controllers = [self.hidSupport populateControllerList];
     
    [self.controllerList removeAllItems];
    [self.controllerList addItemsWithTitles:controllers];
    
    [self showTemporaryStatus:@"Reloaded"];
}

@end
