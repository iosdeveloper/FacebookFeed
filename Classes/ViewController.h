//
//  ViewController.h
//  Created by http://github.com/iosdeveloper
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@interface ViewController : UITableViewController <FBRequestDelegate, FBDialogDelegate, FBSessionDelegate> {
	Facebook *_facebook;
	NSArray *_permissions;
	NSDictionary *_result;
}

@property (readonly) Facebook *facebook;

@end