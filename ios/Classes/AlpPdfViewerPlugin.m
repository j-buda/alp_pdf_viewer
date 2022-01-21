#import "AlpPdfViewerPlugin.h"
#import "AlpPdfView.h"



@implementation AlpPdfViewerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    AlpPdfViewFactory* pdfViewFactory = [[AlpPdfViewFactory alloc] initWithMessenger:registrar.messenger];
    [registrar registerViewFactory:pdfViewFactory withId:@"plugins.alpian.com/pdfview"];
    
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"plugins.alpian.com/pdfdocument" binaryMessenger:[registrar messenger]];
    AlpPdfDocument* document = [[AlpPdfDocument alloc] init];
    [registrar addMethodCallDelegate:document channel:channel];
}
@end



@implementation AlpPdfDocument
-(void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([[call method] isEqualToString:@"pageCount"]) {
            [self getPageCount:call result:result];
        } else {
            result(FlutterMethodNotImplemented);
        }
    });
}

- (void)getPageCount:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString* filePath = call.arguments[@"filePath"];
    NSURL* sourcePdfUrl = [NSURL fileURLWithPath:filePath];
    CGPDFDocumentRef document = CGPDFDocumentCreateWithURL((CFURLRef)sourcePdfUrl);
    size_t pageCount = CGPDFDocumentGetNumberOfPages(document);
    NSString* count = [NSString stringWithFormat:@"%zu", pageCount];
    result(count);
}
@end






