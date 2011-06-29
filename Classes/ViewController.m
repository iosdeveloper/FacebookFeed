//
//  ViewController.m
//  Created by http://github.com/iosdeveloper
//

#import "ViewController.h"
#import "Browser.h"

// Your Facebook APP Id must be set before running
// See http://www.facebook.com/developers/createapp.php
static NSString *kAppId = @"228183803878511";

@implementation ViewController

@synthesize facebook = _facebook;

- (void)awakeFromNib {
	[super awakeFromNib];
	
	if (kAppId == nil) {
		NSLog(@"missing app id!");
		
		exit(1);
	}
	
	_permissions = [[NSArray arrayWithObjects:@"read_stream", @"publish_stream", @"offline_access", nil] retain];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	_facebook = [[Facebook alloc] initWithAppId:kAppId];
	[_facebook authorize:_permissions delegate:self];
}

- (void)logout {
	[_facebook logout:self];
}

- (void)publishStream {
	[_facebook dialog:@"feed" andDelegate:self];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (_result)
		return 1;
	
	return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (_result)
		return [[_result objectForKey:@"data"] count];
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
	
	[[cell textLabel] setText:[[[_result objectForKey:@"data"] objectAtIndex:[indexPath row]] objectForKey:@"name"]];
	
	return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Browser *browser = [[Browser alloc] init];
	
	[[self navigationController] pushViewController:browser animated:YES];
	
	[[browser webView] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.facebook.com/profile.php?id=%@", [[[_result objectForKey:@"data"] objectAtIndex:[indexPath row]] objectForKey:@"id"]]]]];
	
	[browser release];
}

- (void)fbDidLogin {
	[[self navigationItem] setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleDone target:self action:@selector(logout)] autorelease]];
	[[self navigationItem] setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(publishStream)] autorelease]];
	
	[_facebook requestWithGraphPath:@"me" andDelegate:self];
	[_facebook requestWithGraphPath:@"me/friends" andDelegate:self];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
	[_facebook authorize:_permissions delegate:self];
}

- (void)fbDidLogout {
	[_result release];
	_result = nil;
	
	[self setTitle:nil];
	
	[[self navigationItem] setLeftBarButtonItem:nil];
	[[self navigationItem] setRightBarButtonItem:nil];
	
	[[self tableView] reloadData];
	
	[_facebook authorize:_permissions delegate:self];
}

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"received response");
}

- (void)request:(FBRequest *)request didLoad:(id)result {
	if ([result isKindOfClass:[NSArray class]])
		result = [result objectAtIndex:0];
	
	if ([result objectForKey:@"name"])
		[self setTitle:[result objectForKey:@"name"]];
	else if ([result objectForKey:@"data"]) {
		_result = [result retain];
		
		[[self tableView] reloadData];
	}
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"%@", [error localizedDescription]);
}

- (void)dialogDidComplete:(FBDialog *)dialog {
	NSLog(@"publish successfully");
}

- (void)dealloc {
	[_facebook release];
	[_permissions release];
	[_result release];
	
    [super dealloc];
}

@end