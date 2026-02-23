//
//  BindingData.h
//  Moonlight for macOS
//
//  Created by Felipe Morais on 13/10/25.
//  Copyright © 2025 Moonlight Game Streaming Project. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BindingData : NSObject {
    @private
    NSString *binding;
    NSString *input;
}

@property (copy) NSString *binding;
@property (copy) NSString *input;

- (id)initWithBinding:(NSString *)b input:(NSString *)i;

@end

NS_ASSUME_NONNULL_END
