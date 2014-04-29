//
//  CvVideoCameraMod.m
//  DrawLineDemo
//
//  Created by Norman Rzepka on 29.04.14.
//  Copyright (c) 2014 scalable minds. All rights reserved.
//

#import "CvVideoCameraMod.h"

@implementation CvVideoCameraMod

@synthesize customPreviewLayer = _customPreviewLayer;

- (void)updateOrientation;
{
  // nop
}

- (void)layoutPreviewLayer;
{
  if (self.parentView != nil) {
    CALayer* layer = self.customPreviewLayer;
    CGRect bounds = self.customPreviewLayer.bounds;
    layer.position = CGPointMake(self.parentView.frame.size.width/2., self.parentView.frame.size.height/2.);
    layer.bounds = bounds;
  }
}

@end
