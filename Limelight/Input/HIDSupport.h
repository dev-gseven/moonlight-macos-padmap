//
//  HIDSupport.h
//  Moonlight for macOS
//
//  Created by Michael Kenny on 26/12/17.
//  Copyright © 2017 Moonlight Stream. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TableViewController;

@interface HIDSupport : NSObject
@property (atomic) BOOL shouldSendInputEvents;
@property (nonatomic, strong, readonly) NSMutableArray *deviceList;
@property (nonatomic, weak) TableViewController *mapping;
@property (nonatomic, assign) BOOL isMapping;
@property (nonatomic, copy) NSString *lastMappedHex;
@property (nonatomic, strong) NSDictionary *bindingToFlag;
@property (nonatomic, strong) NSDictionary *bindingToAxis;
@property (nonatomic, strong) NSDictionary *savedMapping;
@property (atomic, assign) BOOL invertLeftY;
@property (atomic, assign) BOOL invertLeftX;
@property (atomic, assign) BOOL invertRightY;
@property (atomic, assign) BOOL invertRightX;



- (void)flagsChanged:(NSEvent *)event;
- (void)keyDown:(NSEvent *)event;
- (void)keyUp:(NSEvent *)event;

- (void)releaseAllModifierKeys;

- (void)mouseDown:(NSEvent *)event withButton:(int)button;
- (void)mouseUp:(NSEvent *)event withButton:(int)button;
- (void)mouseMoved:(NSEvent *)event;
- (void)scrollWheel:(NSEvent *)event;

- (void)rumbleLowFreqMotor:(unsigned short)lowFreqMotor highFreqMotor:(unsigned short)highFreqMotor;

- (void)tearDownHidManager;

- (NSArray<NSString *> *)populateControllerList;
- (void)connectToDeviceAtIndex:(NSInteger)index;
@end

static NSString * const kInvertLeftXKey  = @"InvertLeftX";
static NSString * const kInvertLeftYKey  = @"InvertLeftY";
static NSString * const kInvertRightXKey = @"InvertRightX";
static NSString * const kInvertRightYKey = @"InvertRightY";
