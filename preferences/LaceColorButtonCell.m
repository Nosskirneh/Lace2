#import "LaceColorButtonCell.h"
#import "Common.h"

@implementation LaceColorButtonCell

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.textLabel setTextColor:LaceColor];
}

@end
