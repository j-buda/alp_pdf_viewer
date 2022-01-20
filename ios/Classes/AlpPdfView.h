#import <Flutter/Flutter.h>
#import <PDFKit/PDFKit.h>

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(ios(11.0))
@interface AlpPdfViewController: NSObject<FlutterPlatformView, UIScrollViewDelegate, PDFViewDelegate>
-(instancetype)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id _Nullable)args binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;
-(UIView*)view;
@end

@interface AlpPdfViewFactory: NSObject<FlutterPlatformViewFactory>
-(instancetype)initWithMessenger: (NSObject<FlutterBinaryMessenger>*)messenger;
@end

NS_ASSUME_NONNULL_END