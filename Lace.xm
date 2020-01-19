#import <notify.h>
#import "Headers.h"
#import "preferences/Common.h"

// When turning on the screen on the lockscreen
%hook CoverSheetView

%property (nonatomic, assign) NSInteger currentPage;
%property (nonatomic, retain) NSDictionary *lacePrefs;

- (id)initWithFrame:(CGRect)frame {
    UIView<CoverSheetView> *_self = (UIView<CoverSheetView> *)%orig;
    _self.lacePrefs = [NSDictionary dictionaryWithContentsOfFile:kPrefPath];

    int _token;
    notify_register_dispatch("se.nosskirneh.lace2/preferencesChanged",
        &_token,
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0l),
        ^(int _) {
            _self.lacePrefs = [NSDictionary dictionaryWithContentsOfFile:kPrefPath];
        }
    );
    return _self;
}

- (BOOL)resetScrollViewToMainPageAnimated:(BOOL)animated withCompletion:(id)completion {
    UIView<CoverSheetView> *_self = (UIView<CoverSheetView> *)self;
    NSDictionary *prefs = _self.lacePrefs;
    if (prefs[kEnabled] && ![prefs[kEnabled] boolValue])
        return %orig;

    int page = 1;
    if ([prefs[kDefaultSectionEnabled] boolValue]) {
        page = [prefs[kDefaultSection] integerValue];
    } else if ([prefs[kAutomode] boolValue]) {
        // Are notifications present?
        if (![_self hasLockscreenMainPageContent])
            page = 0;
    }
    [_self scrollToPageAtIndex:page animated:NO withCompletion:nil];
    return YES;
}

%new
- (void)updateForLocation:(CGPoint)point {
    UIView<CoverSheetView> *_self = (UIView<CoverSheetView> *)self;
    NSDictionary *prefs = _self.lacePrefs;
    if (prefs[kEnabled] && ![prefs[kEnabled] boolValue])
        return;

    // Scroll to page
    int page = -1;
    BOOL animated = NO;

    if ([prefs[kDefaultSectionEnabled] boolValue]) {
        page = [prefs[kDefaultSection] integerValue];
    } else if ([prefs[kAutomode] boolValue]) {
        // Are notifications present?
        if (![_self hasLockscreenMainPageContent])
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

%new
- (BOOL)hasLockscreenMainPageContent {
    UIView<CoverSheetView> *_self = (UIView<CoverSheetView> *)self;
    return _self.mainPageView.pageViewController.combinedListViewController.hasContent;
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
    Class coverSheetViewClass = %c(CSCoverSheetView);
    if (!coverSheetViewClass)
        coverSheetViewClass = %c(SBDashBoardView);
    %init(CoverSheetView = coverSheetViewClass);
}
