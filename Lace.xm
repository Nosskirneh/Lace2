#define prefPath [NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(), @"se.nosskirneh.lace2.plist"]

#define kEnabled @"enabled"
#define kDefaultSectionEnabled @"DefaultSectionEnabled"
#define kDefaultSection @"DefaultSection"
#define kChangeWhileDragging @"ChangeWhileDragging"
#define kAutomode @"Automode"

static NSDictionary *prefs;


void updateSettings(CFNotificationCenterRef center,
                    void *observer,
                    CFStringRef name,
                    const void *object,
                    CFDictionaryRef userInfo) {
    prefs = [[NSDictionary alloc] initWithContentsOfFile:prefPath];
}


@interface SBDashBoardCombinedListViewController
@property(readonly, nonatomic) BOOL hasContent;
@end

@interface SBDashBoardMainPageContentViewController : UIViewController
@property (nonatomic, readonly) SBDashBoardCombinedListViewController *combinedListViewController;
@end

@interface SBDashBoardPageViewBase : UIView
@property (nonatomic, assign) SBDashBoardMainPageContentViewController *pageViewController;
@end

@interface SBDashBoardView : UIView
@property (nonatomic, readwrite, assign) SBDashBoardPageViewBase *mainPageView;
@property (nonatomic, assign) NSInteger currentPage;
- (BOOL)scrollToPageAtIndex:(unsigned long long)arg1 animated:(BOOL)arg2 withCompletion:(id)arg3;
- (void)updateForLocation:(CGPoint)point;
@end

// When turning on the screen on the lockscreen
%hook SBDashBoardView

%property (nonatomic, assign) NSInteger currentPage;

- (BOOL)resetScrollViewToMainPageAnimated:(BOOL)arg1 withCompletion:(id)arg2 {
    if (prefs[kEnabled] && ![prefs[kEnabled] boolValue])
        return %orig;

    int page = 1;

    if ([prefs[kDefaultSectionEnabled] boolValue]) {
        page = [prefs[kDefaultSection] integerValue];
    } else if ([prefs[kAutomode] boolValue]) {
        // Are notifications present?
        BOOL hasContent = self.mainPageView.pageViewController.combinedListViewController.hasContent;
        if (!hasContent)
            page = 0;
    }
    [self scrollToPageAtIndex:page animated:NO withCompletion:nil];
    return YES;
}

%new
- (void)updateForLocation:(CGPoint)point {
    if (prefs[kEnabled] && ![prefs[kEnabled] boolValue])
        return;

    // Scroll to page
    int page = -1;
    BOOL animated = NO;

    if ([prefs[kDefaultSectionEnabled] boolValue]) {
        page = [prefs[kDefaultSection] integerValue];
    } else if ([prefs[kAutomode] boolValue]) {
        // Are notifications present?
        BOOL hasContent = self.mainPageView.pageViewController.combinedListViewController.hasContent;
        if (!hasContent)
            page = 0;
    } else if (!prefs[kChangeWhileDragging] ||
               [prefs[kChangeWhileDragging] boolValue]) {
        animated = YES;
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        page = point.x / width * 2;
    }

    if (page != -1 && self.currentPage != page) {
        [self scrollToPageAtIndex:page animated:animated withCompletion:nil];
        self.currentPage = page;
    }
}

%end

@interface SBCoverSheetPrimarySlidingViewController : UIViewController
@property (nonatomic, retain) UIView *positionView;  
- (SBDashBoardView *)getDashBoardView;
@end

// When bringing down the lockscreen from the homescreen
%hook SBCoverSheetPrimarySlidingViewController

- (void)_updateForLocation:(CGPoint)point interactive:(BOOL)interactive {
    if (interactive)
        [[self getDashBoardView] updateForLocation:point];

    %orig;
}

%new
- (SBDashBoardView *)getDashBoardView {
    if (self.positionView.subviews.count > 0 && self.positionView.subviews[0].subviews.count > 0)
        return (SBDashBoardView *)self.positionView.subviews[0].subviews[0];
    return nil;
}

%end

%ctor {
    // Init settings file
    prefs = [[NSDictionary alloc] initWithContentsOfFile:prefPath];
    if (!prefs) prefs = [[NSMutableDictionary alloc] init];

    // Add observer to update settings    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &updateSettings, CFStringRef(@"se.nosskirneh.lace2/preferencesChanged"), NULL, 0);
}
