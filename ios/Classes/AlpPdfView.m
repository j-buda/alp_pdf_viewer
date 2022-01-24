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

    NSString* _filePath;
    PDFDocument *_pdf;
    PDFView *_pdfView;
    UIScrollView *_scrollView;
    NSInteger _endOfDocumentSpacing;
    dispatch_source_t _timer;
    NSInteger _pageCount;
    PDFPage *_emptyPage;
}

-(instancetype)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id _Nullable)args binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    
    if ([super init]) {
        _viewId = viewId;
        
        NSString* channelName = [NSString stringWithFormat:@"plugins.alpian.com/pdfview_%lld", viewId];
        _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];

        _filePath = args[@"filePath"];
        _endOfDocumentSpacing = [args[@"endOfDocumentSpacing"] integerValue];

        _pdf = [self openFileFromPath];

        if (_pdf == nil) {
            [_channel invokeMethod:@"onError" arguments:@{@"error" : @"Cannot open PDF document"}];
        } else {
            [self setupPdfView];
            [self setupScrollView];
            
            if (_pageCount > 1) {
                [self setupEndOfDocumentTimer];
            }
        }
    }
    
    return self;
}

-(void)removeShadowFromView:(UIView*)view {
    view.clipsToBounds = YES;

    if ([view subviews].count == 0) {
        return;
    }

    for (UIView *subview in view.subviews) {
        view.clipsToBounds = YES;
        [self removeShadowFromView:subview];
    }
}

-(PDFDocument *)openFileFromPath {
    NSURL *sourcePdfUrl = [NSURL URLWithString:[@"file:///" stringByAppendingString:_filePath]];
    PDFDocument *_pdf = [[PDFDocument alloc] initWithURL:sourcePdfUrl];
    
    // Create empty page to act as the trigger for end of document
    CGSize size = CGSizeMake(1, _endOfDocumentSpacing);
    UIGraphicsBeginImageContextWithOptions(size, false, 0);
    [[UIColor colorWithWhite:0.95 alpha:1.0] setFill];
    UIRectFill(CGRectMake(0, 0, 1, _endOfDocumentSpacing));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    _emptyPage = [[PDFPage alloc] initWithImage:image];
    _pageCount = _pdf.pageCount;

    [_pdf insertPage:_emptyPage atIndex:_pdf.pageCount];

    return _pdf;
}

-(void)setupPdfView {
    _pdfView = [[PDFView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    _pdfView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    _pdfView.displayMode = kPDFDisplaySinglePageContinuous;
    _pdfView.autoScales = true;
    _pdfView.document = _pdf;
    _pdfView.delegate = self;
    
    if (@available(iOS 12, *)) {
        _pdfView.pageShadowsEnabled = false;
    } else {
        [self removeShadowFromView:_pdfView];
    }
}

-(void)setupEndOfDocumentTimer {
    dispatch_queue_t queue = dispatch_queue_create("com.plugins.alp_pdf_viewer", 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 20ull * NSEC_PER_MSEC, 1ull * NSEC_PER_SEC);

    dispatch_source_set_event_handler(_timer, ^{
        [self checkVisiblePages];
    });

    dispatch_resume(_timer);
}

-(void)setupScrollView {
    for (id subview in _pdfView.subviews) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            _scrollView = subview;
        }
    }

    _scrollView.minimumZoomScale = _pdfView.scaleFactorForSizeToFit;
    _scrollView.maximumZoomScale = 3.0;
}

-(UIView*)view {
    return _pdfView;
}

-(void)checkVisiblePages {
    if ([_pdfView.visiblePages containsObject:_emptyPage]) {
        dispatch_source_cancel(_timer);
        [_channel invokeMethod:@"onEndOfDocumentReached" arguments:NULL];
    }
}

//MARK: - PDFViewDelegate
- (void)PDFViewWillClickOnLink:(PDFView *)sender withURL:(NSURL *)url {
    [_channel invokeMethod:@"onLinkHandler" arguments:url.absoluteString];
}

@end
