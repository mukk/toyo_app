// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "InteractiveFurnitureViewController.h"

@interface InteractiveFurnitureViewController ()

@end

@implementation InteractiveFurnitureViewController

// gesture masks to specify which gesture(s) is enabled
//int GESTURE_DRAG = 1<<0;
//int GESTURE_ROTATE = 2<<0;
//int GESTURE_PINCH = 4<<0;
//int GESTURE_ALL = 0xFF;

#pragma - UIViewController lifecycle


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    m_gestures = 0xFF; //enables all gestures
    m_gestureHandler = [[GestureHandlerIOS alloc] initWithSDK:m_pMetaioSDK withView:self.glkView withGestures:m_gestures];
    
    m_imageTaken = nil;
    
    m_buttonEnabled = false;
    
    // load our tracking configuration
    bool success = m_pMetaioSDK->setTrackingConfiguration("ORIENTATION_FLOOR");
    NSLog(@"ORIENTATION tracking has been loaded: %d", (int)success);
    
    
    // load content
    // load metaio man
    NSString* manPath = [[NSBundle mainBundle] pathForResource:@"metaioman"
														ofType:@"md2"
												   inDirectory:@"tutorialContent_crossplatform/TutorialInteractiveFurniture/Assets"];
    
	if(manPath)
	{
		// if this call was successful, m_metaioMan will contain a pointer to the 3D model
        const char* utf8Path = [manPath UTF8String];
        m_metaioMan =  m_pMetaioSDK->createGeometry(metaio::Path::fromUTF8(utf8Path));
        if(m_metaioMan)
        {
            // scale it a bit up
            m_metaioMan->setScale(metaio::Vector3d(5.0f,5.0f,5.0f));
            // add it to the gesture handler.
            [m_gestureHandler addObject:m_metaioMan andGroup:1];
        }
        else
        {
            NSLog(@"Error loading the metaio man model: %@", manPath);
        }
    }
    // hide the metaio man at the beginning
    [self setVisibleMan:false];
    
    // load chair
    NSString* chairPath = [[NSBundle mainBundle] pathForResource:@"stuhl"
														  ofType:@"obj"
													 inDirectory:@"tutorialContent_crossplatform/TutorialInteractiveFurniture/Assets"];
    if (chairPath)
    {
        const char* utf8Path = [chairPath UTF8String];
        m_chair = m_pMetaioSDK->createGeometry(metaio::Path::fromUTF8(utf8Path));
        if (m_chair)
        {
            m_chair->setScale(metaio::Vector3d(50.0f, 50.0f, 50.0f));
            //rotate the chair to be upright
            m_chair->setRotation(metaio::Rotation(M_PI_2, 0.0f, 0.0f));
            m_chair->setTranslation(metaio::Vector3d(0.0f, 0.0f, 0.0f));
            [m_gestureHandler addObject:m_chair andGroup:2];
        }
        else
        {
            NSLog(@"Error loading the chair: %@", chairPath);
        }
    }
    [self setVisibleChair:false];
    
    // load tv
    NSString* tvPath = [[NSBundle mainBundle] pathForResource:@"tv"
													   ofType:@"obj"
												  inDirectory:@"tutorialContent_crossplatform/TutorialInteractiveFurniture/Assets"];
    if (tvPath)
    {
        const char* utf8Path = [tvPath UTF8String];
        m_tv = m_pMetaioSDK->createGeometry(metaio::Path::fromUTF8(utf8Path));
        if (m_tv)
        {
            m_tv->setScale(metaio::Vector3d(50.0f, 50.0f, 50.0f));
            m_tv->setRotation(metaio::Rotation(M_PI_2, 0.0f, -M_PI_2));
            m_tv->setTranslation(metaio::Vector3d(0.0f, 10.0f, 0.0f));
            [m_gestureHandler addObject:m_tv andGroup:3];
        }
        else
        {
            NSLog(@"Error loading the TV: %@", tvPath);
        }
    }
    
    // load screen
    NSString* screenPath = [[NSBundle mainBundle] pathForResource:@"screen"
														   ofType:@"obj"
													  inDirectory:@"tutorialContent_crossplatform/TutorialInteractiveFurniture/Assets"];
    if (screenPath)
    {
        const char* utf8Path = [screenPath UTF8String];
        m_screen = m_pMetaioSDK->createGeometry(metaio::Path::fromUTF8(utf8Path));
        if (m_screen)
        {
            m_screen->setScale(metaio::Vector3d(50.0f, 50.0f, 50.0f));
            m_screen->setRotation(metaio::Rotation(M_PI_2, 0.0f, -M_PI_2));
            m_screen->setTranslation(metaio::Vector3d(0.0f, 10.0f, 0.0f));
			
			// set the screen to the same group as the TV since it should be scaled/moved/rotated the same way as the TV is
            [m_gestureHandler addObject:m_screen andGroup:3];
            
            // start the movie
            NSString* moviePath = [[NSBundle mainBundle] pathForResource:@"sintel"
																  ofType:@"3g2"
															 inDirectory:@"tutorialContent_crossplatform/TutorialInteractiveFurniture/Assets"];
            const char* utf8Path = [moviePath UTF8String];
            m_screen->setMovieTexture(metaio::Path::fromUTF8(utf8Path));
        }
        else
        {
            NSLog(@"Error loading the screen: %@", screenPath);
        }
    }
    [self setVisibleTV:false];
}

#pragma mark - Rotation handling

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)InterfaceOrientation
{
    // allow rotation in all directions
    return YES;
}

- (void)drawFrame
{
    [super drawFrame];
    
    // Load the dummy tracking config file once a camera image has been taken and move the
	// geometries to a certain location on the screen
    if (m_imageTaken)
    {
        bool result = m_pMetaioSDK->setTrackingConfiguration("DUMMY");
        NSLog(@"Tracking data dummy loaded: %d", (int)result);

		// set the previously loaded pose
		m_pMetaioSDK->setCosOffset(1, m_pose);

		// Set the camera image as the tracking target
		m_pMetaioSDK->setImage([m_imageTaken fileSystemRepresentation]);

        m_imageTaken = nil;
    }
}


#pragma mark - @protocol MobileDelegate


- (void) onAnimationEnd: (metaio::IGeometry*) geometry  andName:(const NSString*) animationName
{
    // handle the metaio man animations
    if( geometry == m_metaioMan )
    {
        // check the previous animation name and act accordingly
        if( [animationName compare:@"shock_down"] == NSOrderedSame )
        {
            geometry->startAnimation( "shock_idle" , false);
        }
        else if( [animationName compare:@"shock_idle"] == NSOrderedSame  )
        {
            geometry->startAnimation( "shock_up" , false);
        }
        else if( [animationName compare:@"close_down"] == NSOrderedSame )
        {
            geometry->startAnimation( "close_idle", true);
        }
    }
    
}


#pragma mark - Handling Touches


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // record the initial states of the geometries with the gesture handler
    [m_gestureHandler touchesBegan:touches withEvent:event withView:self.glkView];
    
    // Here's how to pick a geometry
	UITouch *touch = [touches anyObject];
	CGPoint loc = [touch locationInView:self.glkView];
	
    // get the scale factor (will be 2 for retina screens)
    float scale = self.glkView.contentScaleFactor;
    
	// ask sdk if the user picked an object
	// the 'true' flag tells sdk to actually use the vertices for a hit-test, instead of just the bounding box
    metaio::IGeometry* model = m_pMetaioSDK->getGeometryFromViewportCoordinates(loc.x * scale, loc.y * scale, false);
	
    if (model == m_metaioMan)
	{
		// we have touched the metaio man
		// let's start an animation
		model->startAnimation( "shock_down" , false);
	}
}


- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // handles the drag touch
    [m_gestureHandler touchesMoved:touches withEvent:event withView:self.glkView];
}


- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [m_gestureHandler touchesEnded:touches withEvent:event withView:self.glkView];
}


// handles the reactions from touching the geometry buttons. it not only show/hide the geometries, it also resets the location and the scale
- (IBAction)onTVButtonClick:(id)sender
{
    if (m_buttonEnabled)
    {
        UIButton* button = (UIButton*)sender;
        // if the button is already selected, change its state to unselected, and hide the geometry
        if ([button isSelected])
        {
            button.selected = false;
            [self setVisibleTV:false];
        }
        else
        {
            button.selected = true;
            [self setVisibleTV:true];
            
            // reset the location of the geometry
            CGRect screen = self.view.bounds;
            CGFloat width = screen.size.width * [UIScreen mainScreen].scale;
            CGFloat height = screen.size.height * [UIScreen mainScreen].scale;
            metaio::Vector3d translation = m_pMetaioSDK->get3DPositionFromViewportCoordinates(1, metaio::Vector2d(width/2, height/2));
            m_tv->setTranslation(translation);
            m_screen->setTranslation(translation);
            
            m_screen->startMovieTexture();
            
            // reset the scale of the geometry
            m_tv->setScale(metaio::Vector3d(50.0f, 50.0f, 50.0f));
            m_screen->setScale(metaio::Vector3d(50.0f, 50.0f, 50.0f));
        }
    }
    else
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"ATTENTION"
                                                          message:@"Please take a picture first."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }
}


- (IBAction)onChairButtonClick:(id)sender
{
    if (m_buttonEnabled)
    {
        UIButton* button = (UIButton*)sender;
        if ([button isSelected])
        {
            button.selected = false;
            [self setVisibleChair:false];
        }
        else
        {
            button.selected = true;
            [self setVisibleChair:true];
            
            CGRect screen = self.view.bounds;
            CGFloat width = screen.size.width * [UIScreen mainScreen].scale;
            CGFloat height = screen.size.height * [UIScreen mainScreen].scale;
            metaio::Vector3d translation = m_pMetaioSDK->get3DPositionFromViewportCoordinates(1, metaio::Vector2d(width/2, height/2));
            
            
            m_chair->setTranslation(translation);
            m_chair->setScale(metaio::Vector3d(50.0f, 50.0f, 50.0f));
        }
    }
    else
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"ATTENTION"
                                                          message:@"Please take a picture first."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }
}


- (IBAction)onManButtonClick:(id)sender
{

    if (m_buttonEnabled)
    {
        UIButton* button = (UIButton*)sender;
        if ([button isSelected])
        {
            button.selected = false;
            [self setVisibleMan:false];
        }
        else
        {
            button.selected = true;
            [self setVisibleMan:true];
            
            CGRect screen = self.view.bounds;
            CGFloat width = screen.size.width * [UIScreen mainScreen].scale;
            CGFloat height = screen.size.height * [UIScreen mainScreen].scale;
            metaio::Vector3d translation = m_pMetaioSDK->get3DPositionFromViewportCoordinates(1, metaio::Vector2d(width/2, height/2));
            
            m_metaioMan->setTranslation(translation);
            m_metaioMan->setScale(metaio::Vector3d(5.0f, 5.0f, 5.0f));
        }
    }
    else
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"ATTENTION"
                                                          message:@"Please take a picture first."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }
}


// take picture button pressed.
- (IBAction)onTakePicture:(id)sender
{
    NSString* dir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString* filePath = [NSString stringWithFormat:@"%@/targetImage.jpg", dir];
    const char *utf8Path = [filePath UTF8String];
    m_pMetaioSDK->requestCameraImage(metaio::Path::fromUTF8(utf8Path));
//    m_pMetaioSDK->requestCameraImage();
}


// save screenshot button pressed
- (IBAction)onSaveScreen:(id)sender
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* publicDocumentsDir = paths[0];
    
    NSError* docerror;
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:publicDocumentsDir error:&docerror];
    if (files == nil)
    {
        NSLog(@"Error reading contents of documents directory: %@", [docerror localizedDescription]);
    }
    
    
    NSString* timeStamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    NSString* fileName = [NSString stringWithFormat:@"%@.jpg", timeStamp];
    NSString* fullPath = [publicDocumentsDir stringByAppendingPathComponent:fileName];
    
    const char* utf8Path = [fullPath UTF8String];
	m_pMetaioSDK->requestScreenshot(metaio::Path::fromUTF8(utf8Path));

    // generate an alert to notify the user of screenshot saving
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"ATTENTION"
                                                      message:@"The screenshot has been saved to the document folder."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
}


// reset the app -- reactivate the camera, hide the geometries and change the button state (selected) from true to false
- (IBAction)onClearScreen:(id)sender
{
    m_buttonEnabled = false;
    
    // reactivate the camera
	m_pMetaioSDK->startCamera();
	
    // reload the orientation tracking config file
    bool success = m_pMetaioSDK->setTrackingConfiguration("ORIENTATION_FLOOR");
    NSLog(@"ORIENTATION tracking has been loaded: %d", (int)success);
    
    [self setVisibleTV:false];
    [self setVisibleChair:false];
    [self setVisibleMan:false];
    
    // reset the button images to "unselected"
    for (UIView* subView in self.view.subviews)
    {
        if ([subView isKindOfClass:[UIButton class]])
        {
            UIButton* button = (UIButton*)subView;
            NSString* title = button.currentTitle;
            if ([title isEqual:@"TV"])
            {
                button.selected = false;
            }
            else if ([title isEqual:@"Chair"])
            {
                button.selected = false;
            }
            else if ([title isEqual: @"metaioMan"])
            {
                button.selected = false;
            }
        }
    }
}


- (void)onSDKReady
{
	[super onSDKReady];

	m_tvButton.hidden = NO;
	m_chairButton.hidden = NO;
	m_manButton.hidden = NO;

	m_takePictureButton.hidden = NO;
	m_saveScreenButton.hidden = NO;
	m_resetButton.hidden = NO;
}


// hide/show the geometries
- (void)setVisibleTV:(bool)visible
{
    if (m_tv != NULL && m_screen != NULL)
    {
        m_tv->setVisible(visible);
        m_screen->setVisible(visible);
    }
    
    // remember to consider the movie
    if (visible)
    {
        m_screen->startMovieTexture();
    }
    else
    {
        m_screen->stopMovieTexture();
    }
}


- (void)setVisibleChair:(bool)visible
{
    if (m_chair != NULL)
    {
        m_chair->setVisible(visible);
    }
}


- (void)setVisibleMan:(bool)visible
{
    if (m_metaioMan != NULL)
    {
        m_metaioMan->setVisible(visible);
    }
}


- (void)onCameraImageSaved:(const NSString*) filepath
{
	if (filepath.length == 0)
	{
		NSLog(@"Camera image could not be saved");
		return;
	}

	m_imageTaken = (NSString*)filepath;
	m_buttonEnabled = true;

	//remember the current pose
	m_pose = m_pMetaioSDK->getTrackingValues(1);
}


- (void) onNewCameraFrame:(metaio::ImageStruct *)cameraFrame
{
    UIImage* image = m_pMetaioSDK->ImageStruct2UIImage(cameraFrame, true);
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}


-(void) onScreenshotSaved:(const NSString*) filepath
{
	NSLog(@"Image saved: %@", filepath);
}


- (void) onScreenshotImageIOS:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

@end
