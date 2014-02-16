//
//  WipeAwayDemoViewController.m
//  WipeAwayDemo
//
//  Created by Craig on 12/9/10.
//

#import "WipeAwayDemoViewController.h"
#import "WipeAwayView.h"
#import "WipeAwayView2.h"

@interface WipeAwayDemoViewController () {
  WipeAwayView2 *_mask;
}

@end



@implementation WipeAwayDemoViewController

- (BOOL)canBecomeFirstResponder {
  return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
  if (motion == UIEventSubtypeMotionShake) {
    // User was shaking the device. Post a notification named "shake."
    [_mask undo];
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern"]];
	
	_mask = [[WipeAwayView2 alloc] initWithFrame:CGRectMake(0,0,320,480)];
	[_mask newMaskWithColor:[UIColor redColor] eraseSpeed:0.25];
	[self.view addSubview:_mask];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [self becomeFirstResponder];
}



@end
