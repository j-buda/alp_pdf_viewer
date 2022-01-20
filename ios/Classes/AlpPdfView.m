#import "AlpPdfView.h"

@implementation AlpPdfViewFactory {
    NSObject<FlutterBinaryMessenger>* _messenger;
}

-(instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    self = [super init];
    if (self) {
        _messenger = messenger;
    }
    return self;
}

-(NSObject<FlutterMessageCodec>*)createArgsCodec {
    return [FlutterStandardMessageCodec sharedInstance];
}

-(NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id _Nullable)args {
    AlpPdfViewController* pdfViewController = [[AlpPdfViewController alloc] initWithFrame:frame viewIdentifier:viewId arguments:args binaryMessenger:_messenger];
    return pdfViewController;
}
@end

@implementation AlpPdfViewController {
    FlutterMethodChannel* _channel;
    int64_t _viewId;
    PDFView* _pdfView;
    UIScrollView *_scrollView;

    PDFDocument *_pdf;
    NSString* _filePath;
    int _endOfDocumentSpacing;
}

-(instancetype)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id _Nullable)args binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    
    if ([super init]) {
        _viewId = viewId;
        
        NSString* channelName = [NSString stringWithFormat:@"plugins.alpian.com/pdfview_%lld", viewId];
        _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];

        _filePath = args[@"filePath"];
        _endOfDocumentSpacing = [args[@"endOfDocumentSpacing"] integerValue];

        [self openFileFromPath];

        if (_pdf == nil) {
            [_channel invokeMethod:@"onError" arguments:@{@"error" : @"Cannot open PDF document"}];
        } else {
            [self setupPdfView];
            [self setupScrollView];
        }
    }
    
    return self;
}

-(void)openFileFromPath {
    NSURL* sourcePdfUrl = [NSURL fileURLWithPath:_filePath];
    _pdf = [[PDFDocument alloc] initWithURL:sourcePdfUrl];
}

-(void)setupPdfView {
    _pdfView = [[PDFView alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    _pdfView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    _pdfView.displayMode = kPDFDisplaySinglePageContinuous;
    _pdfView.autoScales = true;
    _pdfView.document = _pdf;
    _pdfView.autoresizesSubviews = YES;
    _pdfView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _pdfView.minScaleFactor = _pdfView.scaleFactorForSizeToFit;
    _pdfView.maxScaleFactor = 4.0;

    _pdfView.delegate = self;
}

-(void)setupScrollView {
    for (id subview in _pdfView.subviews) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            _scrollView = subview;
        }
    }

    if (_scrollView != (id)[NSNull null]) {
        _scrollView.contentInset = UIEdgeInsetsMake(0, 0, _endOfDocumentSpacing, 0);
        _scrollView.delegate = self;
    }
}

-(UIView*)view {
    return _pdfView;
}

//MARK: - UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    double bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        [_channel invokeMethod:@"onEndOfDocumentReached" arguments: @{}];
    }
}

//MARK: - PDFViewDelegate
- (void)PDFViewWillClickOnLink:(PDFView *)sender withURL:(NSURL *)url {
    [_channel invokeMethod:@"onLinkHandler" arguments:url.absoluteString];
}

@end
