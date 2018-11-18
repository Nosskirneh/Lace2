#import "LaceColorButtonCell.h"

#define LaceColor [UIColor colorWithRed:0.73 green:0.06 blue:0.58 alpha:1.0]

@implementation LaceColorButtonCell

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.textLabel setTextColor:LaceColor];
}

@end
