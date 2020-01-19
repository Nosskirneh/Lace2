#import <Preferences/PSListController.h>
#import <Preferences/PSControlTableCell.h>
#import <Preferences/PSSpecifier.h>
#import <notify.h>
#import "Common.h"
#import "../../TwitterStuff/Prompt.h"

#define kCell @"cell"
#define kKey @"key"
#define kDefault @"default"
#define kPostNotification @"PostNotification"

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

- (void)loadView {
    [super loadView];
    presentFollowAlert(kPrefPath, self);
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

- (void)setEnabled:(BOOL)enabled forSpecifierID:(NSString *)ID {
    PSSpecifier *specifier = [self specifierForID:ID];
    if (!specifier || [[specifier propertyForKey:kCell] isEqualToString:@"PSGroupCell"])
        return;

    NSIndexPath *indexPath = [self indexPathForSpecifier:specifier];
    PSTableCell *cell = [self tableView:self.table cellForRowAtIndexPath:indexPath];
    if (cell) {
        cell.userInteractionEnabled = enabled;
        cell.textLabel.enabled = enabled;
        cell.detailTextLabel.enabled = enabled;
        
        if ([cell isKindOfClass:[PSControlTableCell class]]) {
            PSControlTableCell *controlCell = (PSControlTableCell *)cell;
            if (controlCell.control)
                controlCell.control.enabled = enabled;
        } else {
            [cell setCellEnabled:enabled];
        }
    }
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:kPrefPath];

    NSString *key = [specifier propertyForKey:kKey];
    BOOL enableCell = [preferences[key] boolValue];

    if ([key isEqualToString:kEnabled]) {
        enableCell = preferences[key] ? enableCell : YES;
        // Change While Dragging
        [self setEnabled:enableCell forSpecifierID:kChangeWhileDragging];

        // Automode
        [self setEnabled:enableCell forSpecifierID:kAutomode];

        // Default Section
        [self setEnabled:enableCell forSpecifierID:kDefaultSectionEnabled];

        // Only reenable the DefaultSection cell if DefaultSectionEnabled is enabled
        if (![preferences[kDefaultSection] boolValue])
            [self setEnabled:NO forSpecifierID:kDefaultSection];
        else
            [self setEnabled:enableCell forSpecifierID:kDefaultSection];
    } else if (!preferences[kEnabled] || [preferences[kEnabled] boolValue]) {
        if ([key isEqualToString:kAutomode]) {
            if ([preferences[kDefaultSectionEnabled] boolValue])
                [self setEnabled:NO forSpecifierID:kChangeWhileDragging];
            else
                [self setEnabled:!enableCell forSpecifierID:kChangeWhileDragging];
        } else if ([key isEqualToString:kDefaultSectionEnabled]) {
            // Disable Change While Dragging
            [self setEnabled:!enableCell forSpecifierID:kChangeWhileDragging];
            // Disable Automode
            [self setEnabled:!enableCell forSpecifierID:kAutomode];
            // Enable DefaultSection cell
            [self setEnabled:enableCell forSpecifierID:kDefaultSection];
        }
    }

    if (!preferences[key])
        return specifier.properties[kDefault];
    return preferences[key];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSMutableDictionary *preferences = [NSMutableDictionary dictionaryWithContentsOfFile:kPrefPath];
    if (!preferences)
        preferences = [NSMutableDictionary new];
    NSString *key = [specifier propertyForKey:kKey];

    [preferences setObject:value forKey:key];
    [preferences writeToFile:kPrefPath atomically:YES];

    if ([key isEqualToString:kEnabled]) {
        // Change While Dragging
        [self setEnabled:[value boolValue] forSpecifierID:kChangeWhileDragging];

        // Automode
        [self setEnabled:[value boolValue] forSpecifierID:kAutomode];

        // Default Section enable
        [self setEnabled:[value boolValue] forSpecifierID:kDefaultSectionEnabled];

        // Only reenable the Section cell if DefaultSectionEnabled is enabled
        if (![preferences[kDefaultSection] boolValue])
            [self setEnabled:NO forSpecifierID:kDefaultSection];
        else
            [self setEnabled:[value boolValue] forSpecifierID:kDefaultSection];
    } else if ([key isEqualToString:kAutomode]) {
        // Disable Change While Dragging
        [self setEnabled:![value boolValue] forSpecifierID:kChangeWhileDragging];
    } else if ([key isEqualToString:kDefaultSectionEnabled]) {
        // Disable Change While Dragging
        [self setEnabled:![value boolValue] forSpecifierID:kChangeWhileDragging];
        // Disable Automode
        [self setEnabled:![value boolValue] forSpecifierID:kAutomode];
        // Enable DefaultSection cell
        [self setEnabled:[value boolValue] forSpecifierID:kDefaultSection];
    }

    [preferences writeToFile:kPrefPath atomically:YES];
    notify_post([specifier.properties[kPostNotification] UTF8String]);
}

- (void)donate {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/aNosskirneh"]];
}

- (void)sourceCode {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/Nosskirneh/Lace2"]];
}

- (void)followTwitter {
    openTwitter();
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
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:_label
                                                                          attribute:NSLayoutAttributeLeft
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self
                                                                          attribute:NSLayoutAttributeLeft
                                                                         multiplier:1.0
                                                                           constant:0.0];
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:_label
                                                                         attribute:NSLayoutAttributeRight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                             toItem:self
                                                                          attribute:NSLayoutAttributeRight
                                                                         multiplier:1.0
                                                                           constant:0.0];
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_label
                                                                             attribute:NSLayoutAttributeBottom
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self
                                                                              attribute:NSLayoutAttributeBottom
                                                                             multiplier:1.0
                                                                               constant:0.0];
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_label
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                             toItem:self
                                                                          attribute:NSLayoutAttributeTop
                                                                         multiplier:1.0
                                                                           constant:0.0];
        [self addConstraints:@[leftConstraint, rightConstraint,
                               bottomConstraint, topConstraint]];
    }
    return self;
}

// Custom cell height
- (CGFloat)preferredHeightForWidth:(CGFloat)width {
    return 140.f;
}

@end
