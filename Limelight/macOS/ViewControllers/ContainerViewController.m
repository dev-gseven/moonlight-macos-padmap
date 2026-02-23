//
//  ContainerViewController.m
//  Moonlight for macOS
//
//  Created by Michael Kenny on 23/12/17.
//  Copyright © 2017 Moonlight Stream. All rights reserved.
//

#import <objc/message.h>
#import "ContainerViewController.h"
#import "NSWindow+Moonlight.h"
#import "BackgroundColorView.h"
#import "Helpers.h"

@interface CustomSearchField : NSSearchField
@end

@implementation CustomSearchField

- (void)cancelOperation:(id)sender {
    [self makeVCFirstResponder];
}

- (void)textDidEndEditing:(NSNotification *)notification {
    [super textDidEndEditing:notification];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self makeVCFirstResponder];
    });
}

- (void)makeVCFirstResponder {
    NSArray<NSViewController *> *vcs = NSApplication.sharedApplication.mainWindow.contentViewController.childViewControllers;
    for (NSViewController *vc in vcs) {
        [self.window makeFirstResponder:vc];
    }
}

@end


@interface ContainerViewController () <NSToolbarDelegate>
@property (weak) IBOutlet BackgroundColorView *titleContainer;

@end

@implementation ContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.wantsLayer = YES;
    
    NSViewController *hostsVC = [self.storyboard instantiateControllerWithIdentifier:@"hostsVC"];
    [self addChildViewController:hostsVC];

    if (@available(macOS 11.0, *)) {
        [self.titleContainer removeFromSuperview];
        [self.view addSubview:hostsVC.view];
    } else {
        [self.view addSubview:hostsVC.view positioned:NSWindowBelow relativeTo:self.titleContainer];
    }
    
    hostsVC.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    hostsVC.view.frame = self.view.bounds;
    
    if (@available(macOS 11.0, *)) {
    } else {
        self.titleContainer.backgroundColor = [NSColor selectedTextBackgroundColor];
        self.titleContainer.wantsLayer = YES;
        self.titleContainer.layer.masksToBounds = YES;
        self.titleContainer.layer.cornerRadius = self.titleContainer.frame.size.height / 2;
    }
    
    #if TARGET_OS_OSX
    NSWindow *window = self.view.window;
    if (window) {
        SEL setterSel = NSSelectorFromString(@"setTitlebarSeparatorStyle:");

        if ([window respondsToSelector:setterSel]) {
            // titlebarSeparatorStyle exists on macOS 11+
            NSInteger style = 1; // default to NSTitlebarSeparatorStyleLine

            if (@available(macOS 13.0, *)) {
                style = 2; // NSTitlebarSeparatorStyleAutomatic
            }

            // Call [window setTitlebarSeparatorStyle:style] using objc_msgSend
            void (*msgSendSetter)(id, SEL, NSInteger) = (void *)objc_msgSend;
            msgSendSetter(window, setterSel, style);
        }
    }
    #endif
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    NSToolbar *toolbar = [Helpers getMainWindow].toolbar;
    toolbar.delegate = self;
    
    NSString *searchToolbarItemIdentifier;
    if (@available(macOS 11.0, *))  {
        searchToolbarItemIdentifier = @"NewSearchToolbarItem";
    } else {
        searchToolbarItemIdentifier = @"OldSearchToolbarItem";
    }
    
    if (![toolbar.items.lastObject.itemIdentifier isEqualToString:searchToolbarItemIdentifier]) {
        [toolbar insertItemWithItemIdentifier:searchToolbarItemIdentifier atIndex:toolbar.items.count];
    }
}

- (void)viewDidAppear {
    [super viewDidAppear];

    NSWindow *window = self.view.window;

    window.frameAutosaveName = @"Main Window";
    [window moonlight_centerWindowOnFirstRunWithSize:CGSizeMake(852, 566)];

    if (@available(macOS 11.0, *)) {
        [window setTitleVisibility:NSWindowTitleVisible];
    }

    #if TARGET_OS_OSX
    if (@available(macOS 11.0, *)) {
        NSToolbarItem *preferencesToolbarItem = [window moonlight_toolbarItemForIdentifier:@"PreferencesToolbarItem"];
        NSButton *preferencesButton = (NSButton *)preferencesToolbarItem.view;

        // Checar se classe NSImageSymbolConfiguration existe
        Class NSImageSymbolConfigurationClass = NSClassFromString(@"NSImageSymbolConfiguration");
        if (NSImageSymbolConfigurationClass) {
            SEL configSelector = NSSelectorFromString(@"configurationWithPointSize:weight:scale:");
            SEL symbolSelector = NSSelectorFromString(@"imageWithSystemSymbolName:accessibilityDescription:");
            SEL applyConfigSelector = NSSelectorFromString(@"imageWithSymbolConfiguration:");

            if ([NSImage respondsToSelector:symbolSelector] &&
                [NSImageSymbolConfigurationClass respondsToSelector:configSelector]) {

                id (*configWithSizeWeightScale)(id, SEL, CGFloat, NSFontWeight, NSInteger) = (void *)objc_msgSend;
                id imgConfig = configWithSizeWeightScale(NSImageSymbolConfigurationClass, configSelector, 13.0, NSFontWeightMedium, 2); // 2 = NSImageSymbolScaleLarge

                id (*symbolImage)(id, SEL, NSString *, id) = (void *)objc_msgSend;
                NSImage *baseImage = symbolImage([NSImage class], symbolSelector, @"gear", nil);

                if ([baseImage respondsToSelector:applyConfigSelector]) {
                    NSImage *(*applyConfig)(id, SEL, id) = (void *)objc_msgSend;
                    NSImage *finalImage = applyConfig(baseImage, applyConfigSelector, imgConfig);

                    [preferencesButton setImage:finalImage];
                }
            }
        }

        // macOS 13.0+: definir tooltip
        if (@available(macOS 13.0, *)) {
            preferencesButton.toolTip = @"Settings";
        }
    }
    #endif
}

- (void)setTitle:(NSString *)title {
    if (@available(macOS 11.0, *)) {
    } else {
        ((NSTextField *)self.titleContainer.subviews.firstObject).stringValue = title;
    }
    self.view.window.title = title;
}


- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSToolbarItemIdentifier)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    /*if (@available(macOS 11.0, *)) {
        NSSearchToolbarItem *newSearchItem = [[NSSearchToolbarItem alloc] initWithItemIdentifier:@"NewSearchToolbarItem"];
        newSearchItem.searchField = [[CustomSearchField alloc] init];
        return newSearchItem;
    } else {
        */NSToolbarItem *OldSearchItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"OldSearchToolbarItem"];
        OldSearchItem.minSize = NSMakeSize(96, 22);
        OldSearchItem.maxSize = NSMakeSize(256, 22);
        
        NSSearchField *searchField = [[CustomSearchField alloc] init];
        [OldSearchItem setView:searchField];
        
        return OldSearchItem;
    }


@end
