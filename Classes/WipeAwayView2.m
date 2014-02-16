//
//  WipeAwayView2.m
//  WipeAwayDemo
//
//  Created by James D. Terry on 2/15/14.
//
//

#import "WipeAwayView2.h"
#import "UndoObject.h"

@interface WipeAwayView2 () {
  CGContextRef _cacheContext;
  CGImageRef _startCopy;
  CGRect _undoRect;
  int _width;
  int _height;
  NSMutableArray *_undoArray;
  CGFloat _imageScale;
}

@end

@implementation WipeAwayView2

- (id)initWithFrame:(CGRect)frame {
  
  self = [super initWithFrame:frame];
  if (self) {
		wipingInProgress = NO;
    _undoArray = [[NSMutableArray array] retain];
		eraser = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eraser" ofType:@"png"]];
		[self setBackgroundColor:[UIColor clearColor]];

    _imageScale = [[UIScreen mainScreen] scale];

    frame.origin.x *= _imageScale;
    frame.origin.y *= _imageScale;
    frame.size.width *= _imageScale;
    frame.size.height *= _imageScale;
    
    _width = frame.size.width;
    _height = frame.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    _cacheContext = CGBitmapContextCreate(NULL, CGRectGetWidth(frame), CGRectGetHeight(frame), 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(_cacheContext, 0, frame.size.height);
    CGContextScaleCTM(_cacheContext, 1.0, -1.0);
    
    UIImage *frontImage = [UIImage imageNamed:@"crazydude.jpg"];
    CGContextDrawImage(_cacheContext, frame, frontImage.CGImage);
    
    CGContextTranslateCTM(_cacheContext, 0, frame.size.height);
    CGContextScaleCTM(_cacheContext, 1.0, -1.0);
    
    CGColorSpaceRelease(colorSpace);
  }
  return self;
}

- (void)undo
{
  if ([_undoArray count] == 0) return;
  
  UndoObject *undo = [_undoArray objectAtIndex:[_undoArray count]-1];

  CGContextSetBlendMode(_cacheContext, kCGBlendModeCopy);
  CGContextDrawImage(_cacheContext, undo.r, undo.image);
  CGRect r = undo.r;
  [_undoArray removeLastObject];
  
  r.origin.x /= _imageScale;
  r.origin.y /= _imageScale;
  r.size.width /= _imageScale;
  r.size.height /= _imageScale;
  
  [self setNeedsDisplayInRect:r];
}


- (void)newMaskWithColor:(UIColor *)color eraseSpeed:(CGFloat)speed {
	
	wipingInProgress = NO;
	
	eraseSpeed = speed;
	
	[color retain];
	[maskColor release];
	maskColor = color;
	
	[self setNeedsDisplay];
	
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  
  _startCopy = CGBitmapContextCreateImage(_cacheContext);
  
	wipingInProgress = YES;
  _undoRect = CGRectNull;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
  UITouch *touch = [touches anyObject];
  location = [touch locationInView:self];
  
  CGFloat imageScale = [[UIScreen mainScreen] scale];
  
  location.x *= imageScale;
  location.y *= imageScale;
  
  location.x -= [eraser size].width/2;
  location.y -= [eraser size].width/2;
  
  CGRect r = CGRectMake(location.x, location.y, eraser.size.width, eraser.size.height);
  
  CGContextSetBlendMode(_cacheContext, kCGBlendModeDestinationOut);
  CGContextDrawImage(_cacheContext, r, eraser.CGImage);
  
  _undoRect = CGRectUnion(_undoRect, r);
  
  r.origin.x /= imageScale;
  r.origin.y /= imageScale;
  r.size.width /= imageScale;
  r.size.height /= imageScale;
  
  [self setNeedsDisplayInRect:r];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (!CGRectIsNull(_undoRect)) {
    
    CGRect ur = _undoRect;
    ur = CGRectApplyAffineTransform(ur, CGAffineTransformMakeTranslation(0, -_height));
    ur = CGRectApplyAffineTransform(ur, CGAffineTransformMakeScale(1.0, -1.0));    
    CGImageRef undoClip = CGImageCreateWithImageInRect(_startCopy, ur);
    
    UndoObject *undo = [[[UndoObject alloc] init] autorelease];
    undo.image = undoClip;
    undo.r = _undoRect;
    [_undoArray addObject:undo];
        
    _undoRect = CGRectNull;
  }
  
  CFRelease(_startCopy);
}

/*
- (void)drawRect:(CGRect)rect {
  
	CGContextRef context = UIGraphicsGetCurrentContext();
  
	if (wipingInProgress) {
		if (imageRef) {
			// Restore the screen that was previously saved
			CGContextTranslateCTM(context, 0, rect.size.height);
			CGContextScaleCTM(context, 1.0, -1.0);
			
			CGContextDrawImage(context, rect, imageRef);
			CGImageRelease(imageRef);
      
			CGContextTranslateCTM(context, 0, rect.size.height);
			CGContextScaleCTM(context, 1.0, -1.0);
		}
    
		// Erase the background -- raise the alpha to clear more away with eash swipe
		[eraser drawAtPoint:location blendMode:kCGBlendModeDestinationOut alpha:eraseSpeed];
	} else {
		// First time in, we start with a solid color
		CGContextSetFillColorWithColor( context, maskColor.CGColor );
		CGContextFillRect( context, rect );
	}
  
	// Save the screen to restore next time around
	imageRef = CGBitmapContextCreateImage(context);
	
}
*/

- (void) drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGImageRef cacheImage = CGBitmapContextCreateImage(_cacheContext);
  CGContextDrawImage(context, self.bounds, cacheImage);
  CGImageRelease(cacheImage);
}


- (void)dealloc {
	[maskColor release];
	[eraser release];
  [super dealloc];
}


@end
