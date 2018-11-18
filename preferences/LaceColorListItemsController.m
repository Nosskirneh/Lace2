#import "LaceColorListItemsController.h"

#define LaceColor [UIColor colorWithRed:0.73 green:0.06 blue:0.58 alpha:1.0]

@implementation LaceColorListItemsController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Tint
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = LaceColor;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = nil;
}

@end
