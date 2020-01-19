

@protocol CombinedListViewController
@property (readonly, nonatomic) BOOL hasContent;
@end

@interface CSCombinedListViewController : UIViewController<CombinedListViewController>
@end

@interface SBDashBoardCombinedListViewController : UIViewController<CombinedListViewController>
@end

@protocol MainPageContentViewController
@property (nonatomic, readonly) UIViewController<CombinedListViewController> *combinedListViewController;
@end

@interface CSMainPageContentViewController : UIViewController<MainPageContentViewController>
@end

@interface SBDashBoardMainPageContentViewController : UIViewController<MainPageContentViewController>
@end

@protocol MainPageView
@property (nonatomic, assign) UIViewController<MainPageContentViewController> *pageViewController;
@end

@interface CSMainPageView : UIView<MainPageView>
@end

@interface SBDashBoardPageViewBase : UIView<MainPageView>
@end

@protocol CoverSheetView
@property (nonatomic, readwrite, assign) UIView<MainPageView> *mainPageView;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, retain) NSDictionary *lacePrefs;
- (BOOL)scrollToPageAtIndex:(unsigned long long)index
                   animated:(BOOL)animated
             withCompletion:(id)completion;
- (void)updateForLocation:(CGPoint)point;
- (BOOL)hasLockscreenMainPageContent;
@end

@interface CSCoverSheetView : UIView<CoverSheetView>
@end

@interface SBDashBoardView : UIView<CoverSheetView>
@end



@protocol CoverSheetViewController
@property (nonatomic, retain) UIView<CoverSheetView> *view;
@end

@interface SBCoverSheetPrimarySlidingViewController : UIViewController
@property (nonatomic, readonly) UIViewController<CoverSheetViewController> *contentViewController;
@end
