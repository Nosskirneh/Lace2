#import "Headers.h"

#define prefPath @"/var/mobile/Library/Preferences/se.nosskirneh.lace2.plist"

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
    prefs = [NSDictionary dictionaryWithContentsOfFile:prefPath];
}

// When turning on the screen on the lockscreen

%hook CoverSheetView

%property (nonatomic, assign) NSInteger currentPage;

- (BOOL)resetScrollViewToMainPageAnimated:(BOOL)animated withCompletion:(id)completion {
    if (prefs[kEnabled] && ![prefs[kEnabled] boolValue])
        return %orig;

    UIView<CoverSheetView> *_self = (UIView<CoverSheetView> *)self;
    int page = 1;

    if ([prefs[kDefaultSectionEnabled] boolValue]) {
        page = [prefs[kDefaultSection] integerValue];
    } else if ([prefs[kAutomode] boolValue]) {
        // Are notifications present?
        BOOL hasContent = _self.mainPageView.pageViewController.combinedListViewController.hasContent;
        if (!hasContent)
            page = 0;
    }
    [_self scrollToPageAtIndex:page animated:NO withCompletion:nil];
    return YES;
}

%new
- (void)updateForLocation:(CGPoint)point {
    if (prefs[kEnabled] && ![prefs[kEnabled] boolValue])
        return;

    // Scroll to page
    UIView<CoverSheetView> *_self = (UIView<CoverSheetView> *)self;
    int page = -1;
    BOOL animated = NO;

    if ([prefs[kDefaultSectionEnabled] boolValue]) {
        page = [prefs[kDefaultSection] integerValue];
    } else if ([prefs[kAutomode] boolValue]) {
        // Are notifications present?
        BOOL hasContent = _self.mainPageView.pageViewController.combinedListViewController.hasContent;
        if (!hasContent)
            page = 0;
    } else if (!prefs[kChangeWhileDragging] ||
               [prefs[kChangeWhileDragging] boolValue]) {
        animated = YES;
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        page = point.x / width * 2;
    }

    if (page != -1 && _self.currentPage != page) {
        [_self scrollToPageAtIndex:page animated:animated withCompletion:nil];
        _self.currentPage = page;
    }
}

%end


// When bringing down the lockscreen from the homescreen
%hook SBCoverSheetPrimarySlidingViewController

- (void)_updateForLocation:(CGPoint)point interactive:(BOOL)interactive {
    if (interactive)
        [((UIView<CoverSheetView> *)self.contentViewController.view) updateForLocation:point];

    %orig;
}

%end

%ctor {
    // Init settings file
    prefs = [NSDictionary dictionaryWithContentsOfFile:prefPath];
    if (!prefs) prefs = [NSMutableDictionary new];

    Class coverSheetViewClass = %c(CSCoverSheetView);
    if (!coverSheetViewClass)
        coverSheetViewClass = %c(SBDashBoardView);

    %init(CoverSheetView = coverSheetViewClass);

    // Add observer to update settings    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &updateSettings, CFStringRef(@"se.nosskirneh.lace2/preferencesChanged"), NULL, 0);
}
