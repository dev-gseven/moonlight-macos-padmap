//
//  BindingData.m
//  Moonlight for macOS
//
//  Created by Felipe Morais on 13/10/25.
//  Copyright © 2025 Moonlight Game Streaming Project. All rights reserved.
//

#import "BindingData.h"

@implementation BindingData

@synthesize binding;
@synthesize input;

- (id)initWithBinding:(NSString *)b input:(NSString *)i {
    self = [super init];
    if (self) {
        binding = b;
        input = i;
    }
    return self;
}

@end
