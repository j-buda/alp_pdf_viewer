#import "AlpPdfViewerPlugin.h"
#import "AlpPdfView.h"

@implementation AlpPdfViewerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    AlpPdfViewFactory* pdfViewFactory = [[AlpPdfViewFactory alloc] initWithMessenger:registrar.messenger];
    [registrar registerViewFactory:pdfViewFactory withId:@"plugins.alpian.com/pdfview"];
}

@end
