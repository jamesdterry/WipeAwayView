//
//  UndoObject.m
//  WipeAwayDemo
//
//  Created by James D. Terry on 2/15/14.
//
//

#import "UndoObject.h"

@implementation UndoObject

- (void)dealloc
{
  [super dealloc];
  
  CFRelease(self.image);
}

@end
