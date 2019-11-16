#import <Preferences/PSListController.h>
#import <Preferences/PSControlTableCell.h>
#import <Preferences/PSSpecifier.h>

#define prefPath @"/var/mobile/Library/Preferences/se.nosskirneh.lace2.plist"
#define LaceColor [UIColor colorWithRed:0.73 green:0.06 blue:0.58 alpha:1.0]

@interface LacePrefsRootListController : PSListController {
    UIWindow *settingsView;
}
@end

@implementation LacePrefsRootListController

- (NSArray *)specifiers {
    if (!_specifiers)
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];

    return _specifiers;
}

- (NSString *)kEnabled {
    return @"enabled";
}

- (NSString *)kDefaultSection {
    return @"DefaultSection";
}

- (NSString *)kDefaultSectionEnabled {
    return @"DefaultSectionEnabled";
}

- (NSString *)kAutomode {
    return @"Automode";
}

// Indexpaths
- (NSIndexPath *)changeWhileDraggingIndexPath {
    return [NSIndexPath indexPathForRow:0 inSection:1];
}

- (NSIndexPath *)automodeIndexPath {
    return [NSIndexPath indexPathForRow:0 inSection:2];
}

- (NSIndexPath *)defaultSectionEnableSwitchIndexPath {
    return [NSIndexPath indexPathForRow:0 inSection:3];
}

- (NSIndexPath *)defaultSectionIndexPath {
    return [NSIndexPath indexPathForRow:1 inSection:3];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Tint
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = LaceColor;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // Restore tint
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = nil;
}

- (void)setCellForRowAtIndexPath:(NSIndexPath *)indexPath enabled:(BOOL)enabled {
    if (!indexPath)
        return;

    UITableViewCell *cell = [self tableView:self.table cellForRowAtIndexPath:indexPath];
    if (cell) {
        cell.userInteractionEnabled = enabled;
        cell.textLabel.enabled = enabled;
        cell.detailTextLabel.enabled = enabled;
        
        if ([cell isKindOfClass:[PSControlTableCell class]]) {
            PSControlTableCell *controlCell = (PSControlTableCell *)cell;
            if (controlCell.control)
                controlCell.control.enabled = enabled;
        }
    }
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:prefPath];

    NSString *key = [specifier propertyForKey:@"key"];
    BOOL enableCell = [preferences[key] boolValue];

    if ([key isEqualToString:[self kEnabled]]) {
        enableCell = preferences[key] ? enableCell : YES;
        // Change While Dragging
        [self setCellForRowAtIndexPath:[self changeWhileDraggingIndexPath] enabled:enableCell];

        // Automode
        [self setCellForRowAtIndexPath:[self automodeIndexPath] enabled:enableCell];

        // Default Section
        [self setCellForRowAtIndexPath:[self defaultSectionEnableSwitchIndexPath] enabled:enableCell];

        // Only reenable DefaultSection cell if DefaultSectionEnabled is enabled
        if (![preferences[[self kDefaultSectionEnabled]] boolValue])
            [self setCellForRowAtIndexPath:[self defaultSectionIndexPath] enabled:NO];
        else
            [self setCellForRowAtIndexPath:[self defaultSectionIndexPath] enabled:enableCell];

    } else if (!preferences[[self kEnabled]] || [preferences[[self kEnabled]] boolValue]) {
        if ([key isEqualToString:[self kAutomode]]) {
            if ([preferences[[self kDefaultSectionEnabled]] boolValue])
                [self setCellForRowAtIndexPath:[self changeWhileDraggingIndexPath] enabled:NO];
            else
                [self setCellForRowAtIndexPath:[self changeWhileDraggingIndexPath] enabled:!enableCell];

        } else if ([key isEqualToString:[self kDefaultSectionEnabled]]) {
            // Disable Change While Dragging
            [self setCellForRowAtIndexPath:[self changeWhileDraggingIndexPath] enabled:!enableCell];
            // Disable Automode
            [self setCellForRowAtIndexPath:[self automodeIndexPath] enabled:!enableCell];
            // Enable DefaultSection cell
            [self setCellForRowAtIndexPath:[self defaultSectionIndexPath] enabled:enableCell];
        }
    }

    if (!preferences[key])
        return specifier.properties[@"default"];
    return preferences[key];
}


- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSMutableDictionary *preferences = [NSMutableDictionary dictionaryWithContentsOfFile:prefPath];
    if (!preferences) preferences = [NSMutableDictionary new];
    NSString *key = [specifier propertyForKey:@"key"];

    [preferences setObject:value forKey:key];
    [preferences writeToFile:prefPath atomically:YES];

    if ([key isEqualToString:[self kEnabled]]) {
        // Change While Dragging
        [self setCellForRowAtIndexPath:[self changeWhileDraggingIndexPath] enabled:[value boolValue]];

        // Automode
        [self setCellForRowAtIndexPath:[self automodeIndexPath] enabled:[value boolValue]];

        // Default Section enable
        [self setCellForRowAtIndexPath:[self defaultSectionEnableSwitchIndexPath] enabled:[value boolValue]];

        // Only reenable Section cell if DefaultSectionEnabled is enabled
        if (![preferences[[self kDefaultSectionEnabled]] boolValue])
            [self setCellForRowAtIndexPath:[self defaultSectionIndexPath] enabled:NO];
        else
            [self setCellForRowAtIndexPath:[self defaultSectionIndexPath] enabled:[value boolValue]];
    } else if ([key isEqualToString:[self kAutomode]]) {
        // Disable Change While Dragging
        [self setCellForRowAtIndexPath:[self changeWhileDraggingIndexPath] enabled:![value boolValue]];

    } else if ([key isEqualToString:[self kDefaultSectionEnabled]]) {
        // Disable Change While Dragging
        [self setCellForRowAtIndexPath:[self changeWhileDraggingIndexPath] enabled:![value boolValue]];
        // Disable Automode
        [self setCellForRowAtIndexPath:[self automodeIndexPath] enabled:![value boolValue]];
        // Enable DefaultSection cell
        [self setCellForRowAtIndexPath:[self defaultSectionIndexPath] enabled:[value boolValue]];
    }

    [preferences writeToFile:prefPath atomically:YES];

    CFStringRef post = (CFStringRef)CFBridgingRetain(specifier.properties[@"PostNotification"]);
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), post, NULL, NULL, YES);
}

- (void)donate {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/nosskirneh"]];
}

@end


// Header
@interface LaceHeaderCell : PSTableCell {
    UILabel *_label;
}
@end

@implementation LaceHeaderCell
- (id)initWithSpecifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"headerCell" specifier:specifier];
    if (self) {
        _label = [[UILabel alloc] initWithFrame:[self frame]];
        [_label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_label setAdjustsFontSizeToFitWidth:YES];
        [_label setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:48]];

        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Lace 2"];

        [_label setAttributedText:attributedString];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [_label setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:_label];
        [self setBackgroundColor:[UIColor clearColor]];

        // Setup constraints
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        [self addConstraints:[NSArray arrayWithObjects:leftConstraint, rightConstraint, bottomConstraint, topConstraint, nil]];
    }
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {
    // Return a custom cell height.
    return 140.f;
}

@end
