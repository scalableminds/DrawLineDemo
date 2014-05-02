//
//  ViewController.mm
//  DrawLineDemo
//
//  Created by Norman Rzepka on 29.04.14.
//  Copyright (c) 2014 scalable minds. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end


@implementation ViewController

@synthesize videoCamera;

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  
  
  self.videoCamera = [[CvVideoCameraMod alloc] initWithParentView:self.imageView];
  self.videoCamera.delegate = self;
  self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
  self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
  self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
  self.videoCamera.defaultFPS = 30;
  
  //  double newWidth = _imageView.frame.size.height * (480.0/640.0);
  //  _imageView.frame = CGRectMake(_imageView.frame.origin.x - (newWidth - _imageView.frame.size.width) / 2, _imageView.frame.origin.y,
  //                                newWidth, _imageView.frame.size.height);
  
  [videoCamera createVideoPreviewLayer];
  [self.imageView.layer addSublayer:self.videoCamera.customPreviewLayer];
  
}

- (NSUInteger)supportedInterfaceOrientations
{
  // Only portrait orientation
  return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#ifdef __cplusplus


- (void)processImage:(Mat&)image
{
  Mat image_small, image_out;
  
  
  // Downsample
  pyrDown(image, image_small);
  
  // Convert to grayscale
  cvtColor(image_small, image_small, CV_BGR2GRAY);
  
  // Erode (make thin lines thicker)
  int erosion_size = 1; // OPTION
  Mat element = getStructuringElement( MORPH_ELLIPSE,
                                      cv::Size( 2*erosion_size + 1, 2*erosion_size+1 ),
                                      cv::Point( erosion_size, erosion_size ) );
  erode( image_small, image_small, element );

  
  // Thresholding
  int kernelSize = 33; // OPTION
  int c = 6; // OPTION
  
  adaptiveThreshold(image_small, image_small, 255, ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY_INV, kernelSize, c);
  
  // Create output buffer
  image_out = Mat(image_small.size(), CV_8UC4);
  bitwise_not(image_out, image_out);
  
  // Find contours
  vector<vector<cv::Point>> contours;
  findContours( image_small, contours, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE );
  
//  // Simplify path
//  for( int k = 0; k < contours.size(); k++ )
//    approxPolyDP(contours[k], contours[k], 2, false);
  
  
  // Find contour with largest bbox
  int max_size = 0;
  int max_i = -1;
  
  for ( int i = 0; i < contours.size(); i++ ){
    cv::Rect bbox = boundingRect(contours[i]);
    int contourSize = bbox.width * bbox.height;
    if (max_size < contourSize) {
      max_size = contourSize;
      max_i = i;
    }
  }
  
  if (max_i >= 0) {
    vector<cv::Point> maxContour = contours[max_i];
    
    drawContours( image_out, contours, max_i, Scalar( 0, 0, 0, 255 ), 2, CV_AA );
    
    
    // Find point that's closest to bbox' middle
    cv::Rect bbox = boundingRect(maxContour);
    cv::Point mid = cv::Point(bbox.x + bbox.width / 2, bbox.y + bbox.height / 2);
    
    int min_dist = 10000;
    int min_j = -1;
    
    for ( int j = 0; j < maxContour.size(); j++) {
      int dist = norm(mid - maxContour[j]);
      if (min_dist > dist) {
        min_dist = dist;
        min_j = j;
      }
    }
    
    if (min_j >= 0) {
      cv::Point2d midPoint = maxContour[min_j];
      
      
      // Calculate the direction, based on neighbor points
      int prevOffset = 5;
      cv::Point2d prevPoint = maxContour[(min_j - prevOffset < 0) ?
                                       maxContour.size() + (min_j - prevOffset) :
                                       min_j - prevOffset ];
      
      int nextOffset = 5;
      cv::Point2d nextPoint = maxContour[(min_j + nextOffset >= maxContour.size()) ?
                                      (min_j + nextOffset) % maxContour.size() :
                                       min_j + nextOffset ];
      
      // Draw mocked car rectangle
      cv::Point2d direction = nextPoint - prevPoint;
      direction = direction * (1 / norm(direction));
      
      cv::Point2d directionOrthogonal = cv::Point2d(-direction.y, direction.x);
      directionOrthogonal = directionOrthogonal * (1 / norm(directionOrthogonal));
      
      double coeff[4][2] = { { 40, 20 }, { 40, -20 }, { -40, -20 }, { -40, 20 } };
      
      for ( int k = 0; k < 4; k++ ) {
        line(image_out,
             midPoint + coeff[k][0] * direction + coeff[k][1] * directionOrthogonal,
             midPoint + coeff[(k + 1) % 4][0] * direction + coeff[(k + 1) % 4][1] * directionOrthogonal,
             Scalar(2, 61, 124, 255), 8, CV_AA);
      }

//      // Draw mid-point
//      circle(image_out, midPoint, 5, CV_RGB( 100, 100, 100), 2, CV_AA);
      
    }
    
  }
  
  // Upsample for display
  pyrUp(image_out, image);

  
  // The iOS OpenCV wrapper requires BGRA format. Otherwise it will leak.
  cvtColor(image, image, CV_RGBA2BGRA);
  
}
#endif

-(void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [videoCamera start];
  
  [self toggleTorch:true];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  [videoCamera stop];
  
  [self toggleTorch:false];
}

- (void)toggleTorch:(BOOL)mode
{
  AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  [device lockForConfiguration:nil];
  if (mode)
    [device setTorchModeOnWithLevel:0.2 error:nil];
  else
    [device setTorchMode:AVCaptureTorchModeOff];
  [device unlockForConfiguration];
}

- (void)dealloc
{
  videoCamera.delegate = nil;
}

@end
