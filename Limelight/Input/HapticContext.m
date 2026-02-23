//
//  HapticContext.m
//  Moonlight
//
//  Created by Cameron Gutman on 9/17/20.
//  Copyright © 2020 Moonlight Game Streaming Project. All rights reserved.
//

// HapticContext.m - Mojave-compatible version

#import "HapticContext.h"
#import <objc/message.h>

@implementation HapticContext {
    id _hapticEngine;
    id _hapticPlayer;
    BOOL _playing;
    NSInteger _playerIndex;
}

- (void)cleanup {
    if (_hapticPlayer != nil) {
        SEL cancelSel = NSSelectorFromString(@"cancelAndReturnError:");
        if ([_hapticPlayer respondsToSelector:cancelSel]) {
            ((void (*)(id, SEL, NSError **))objc_msgSend)(_hapticPlayer, cancelSel, NULL);
        }
        _hapticPlayer = nil;
    }
    if (_hapticEngine != nil) {
        SEL stopSel = NSSelectorFromString(@"stopWithCompletionHandler:");
        if ([_hapticEngine respondsToSelector:stopSel]) {
            ((void (*)(id, SEL, void *))objc_msgSend)(_hapticEngine, stopSel, NULL);
        }
        _hapticEngine = nil;
    }
}

- (void)setMotorAmplitude:(unsigned short)amplitude {
    if (_hapticEngine == nil) return;

    if (amplitude == 0) {
        if (_playing && _hapticPlayer != nil) {
            SEL stopSel = NSSelectorFromString(@"stopAtTime:error:");
            if ([_hapticPlayer respondsToSelector:stopSel]) {
                ((void (*)(id, SEL, double, NSError **))objc_msgSend)(_hapticPlayer, stopSel, 0.0, NULL);
            }
            _playing = NO;
        }
        return;
    }

    if (_hapticPlayer == nil) return;

    // Create dynamic intensity param
    Class dynParamClass = NSClassFromString(@"CHHapticDynamicParameter");
    if (!dynParamClass) return;
    id dynParam = [[dynParamClass alloc] initWithParameterID:@"HapticIntensityControl"
                                                       value:(amplitude / 65535.0f)
                                                relativeTime:0];
    NSArray *params = @[ dynParam ];
    SEL sendParamsSel = NSSelectorFromString(@"sendParameters:atTime:error:");
    if ([_hapticPlayer respondsToSelector:sendParamsSel]) {
        ((void (*)(id, SEL, id, double, NSError **))objc_msgSend)(_hapticPlayer, sendParamsSel, params, 0.0, NULL);
    }

    if (!_playing) {
        SEL startSel = NSSelectorFromString(@"startAtTime:error:");
        if ([_hapticPlayer respondsToSelector:startSel]) {
            ((void (*)(id, SEL, double, NSError **))objc_msgSend)(_hapticPlayer, startSel, 0.0, NULL);
            _playing = YES;
        }
    }
}

- (id)initWithGamepad:(id)gamepad locality:(NSInteger)locality {
    if (!gamepad) return nil;

    id haptics = nil;
    SEL hapticsSel = NSSelectorFromString(@"haptics");
    if ([gamepad respondsToSelector:hapticsSel]) {
        haptics = ((id (*)(id, SEL))objc_msgSend)(gamepad, hapticsSel);
    }
    if (!haptics) {
        Log(LOG_W, @"Controller does not support haptics");
        return nil;
    }

    SEL engineSel = NSSelectorFromString(@"createEngineWithLocality:");
    if ([haptics respondsToSelector:engineSel]) {
        _hapticEngine = ((id (*)(id, SEL, NSInteger))objc_msgSend)(haptics, engineSel, locality);
    }
    if (!_hapticEngine) return nil;

    SEL startSel = NSSelectorFromString(@"startAndReturnError:");
    if ([_hapticEngine respondsToSelector:startSel]) {
        ((void (*)(id, SEL, NSError **))objc_msgSend)(_hapticEngine, startSel, NULL);
    }

    // Optional: set handlers if needed, or leave out for Mojave
    return self;
}

+ (HapticContext *)createContextForHighFreqMotor:(id)gamepad {
    return nil;
}

+ (HapticContext *)createContextForLowFreqMotor:(id)gamepad {
    return nil;
}

@end
