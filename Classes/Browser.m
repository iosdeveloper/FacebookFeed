//
//  Browser.m
//  Created by http://github.com/iosdeveloper
//

#import "Browser.h"

@implementation Browser

@synthesize webView;

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	webView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	[webView setScalesPageToFit:YES];
	
	[self setView:webView];
}

- (void)dealloc {
	[webView release];
	
    [super dealloc];
}

@end