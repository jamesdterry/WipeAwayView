//
//  WipeAwayView2.h
//  WipeAwayDemo
//
//  Created by James D. Terry on 2/15/14.
//
//

#import <UIKit/UIKit.h>

@interface WipeAwayView2 : UIView {
  CGPoint		location;
  CGImageRef	imageRef;
  UIImage		*eraser;
  BOOL		wipingInProgress;
  UIColor		*maskColor;
  CGFloat		eraseSpeed;
}

- (void)newMaskWithColor:(UIColor *)color eraseSpeed:(CGFloat)speed;

- (void)undo;

@end
