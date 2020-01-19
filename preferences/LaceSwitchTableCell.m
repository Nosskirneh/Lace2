#import "LaceSwitchTableCell.h"
#import "Common.h"

// Colorful UISwitches
@implementation LaceSwitchTableCell

- (id)initWithStyle:(int)style reuseIdentifier:(id)identifier specifier:(id)specifier {
    self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];
    if (self)
        [((UISwitch *)[self control]) setOnTintColor:LaceColor];
    return self;
}

@end
