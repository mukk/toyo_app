// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "VisualSearchViewController.h"

@interface VisualSearchViewController ()
- (UIImage*) getBillboardImage: (NSString*) title andPath: (NSString*) imagePath;
@end

@implementation VisualSearchViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)drawFrame
{
    // get the tracking values of current tracking state
    m_trackingValues = m_pMetaioSDK->getTrackingValues(1);
    
    // if visual search is requested or tracking is lost, then request a new visual search
    // visual search shold be requested before render()
    if ((m_vsRequested || !m_trackingValues.isTrackingState()))
    {
        m_pMetaioSDK->requestVisualSearch("sdktest", true );
        
        m_vsRequested = false;
    }
    
    [super drawFrame];
}

- (void) onSDKReady
{
    // generate an alert to notify the user of to point the camera to an image
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"ATTENTION"
                                                      message:@"Please hold the camera to an image you want to perform visual search on."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
    
}
// the visual search result is provided in this callback, including the error message (0 signifies success) and the tracking data and other related information
- (void)onVisualSearchResult:(const metaio::stlcompat::Vector<metaio::VisualSearchResponse>&)response errorCode:(int)errorCode
{
	// Don't set another tracking configuration while there's an active one
	if (m_trackingValues.isTrackingState())
	{
		return;
	}

    if (!errorCode && response.size()>0)
    {
        // set the searched image as a tracking target
        m_pMetaioSDK->setTrackingConfiguration(response[0].trackingConfiguration, false);
        
        // load geometry
        NSString* texturePath = [[NSBundle mainBundle] pathForResource:@"poi"
																ofType:@"png"
														   inDirectory:@"tutorialContent_crossplatform/TutorialVisualSearch/Assets"];
        
        if (texturePath)
        {
            NSString* fullName = [NSString stringWithUTF8String:response[0].trackingConfigurationName.c_str()];
            
            // remove the file extension and index at the end
            NSError *error = nil;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[.][^.]+$" options:NSRegularExpressionCaseInsensitive error:&error];
            NSString *name = [regex stringByReplacingMatchesInString:fullName options:0 range:NSMakeRange(0, [fullName length]) withTemplate:@""];
            
            // unload the geometry if previously loaded
            if (m_model)
            {
                m_pMetaioSDK->unloadGeometry(m_model);
            }
            
            // create a billboard texture that highlights the file name of the detected image
            m_model = m_pMetaioSDK->createGeometryFromCGImage([name UTF8String], [[self getBillboardImage:name andPath:texturePath] CGImage]);
            m_model->setCoordinateSystemID(1);
            m_model->setScale(1.5f);
            NSLog(@"The image billboard has been loaded successfully");
        }
		else
			NSLog(@"Failed to load image billboard");
    }
    else
    {
        // if visual search didn't succeed, request another round
        m_vsRequested = true;
    }
}

// this callback provides the status information of visual search
- (void) onVisualSearchStatusChanged:(metaio::EVISUAL_SEARCH_STATE)state
{
    NSLog(@"The current visual search state is: ");
    
    switch (state)
    {
        case metaio::EVSS_IDLE:
            NSLog(@"EVSS_IDLE");
            break;
        case metaio::EVSS_DEVICE_MOVING:
            NSLog(@"EVSS_DEVICE_MOVING");
            break;
        case metaio::EVSS_SERVER_COMMUNICATION:
            NSLog(@"EVSS_SERVER_COMMUNICATION");
            break;
		case metaio::EVSS_NONE:
			break;
    }
}

#pragma mark - Helper methods

- (UIImage*) getBillboardImage: (NSString*) title andPath: (NSString*) imagePath
{
	// first lets find out if we're drawing retina resolution or not
    float scaleFactor = [UIScreen mainScreen].scale;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        scaleFactor = 2;        // draw in high-res for iPad
    
    // then lets draw
    UIImage* bgImage = nil;
    
    bgImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
    
    UIGraphicsBeginImageContext( bgImage.size );			// create a new image context
    CGContextRef currContext = UIGraphicsGetCurrentContext();
    
    // mirror the context transformation to draw the images correctly
    CGContextTranslateCTM( currContext, 0, bgImage.size.height );
    CGContextScaleCTM(currContext, 1.0, -1.0);
    CGContextDrawImage(currContext,  CGRectMake(0, 0, bgImage.size.width, bgImage.size.height), [bgImage CGImage]);
    
    // now bring the context transformation back to what it was before
    CGContextScaleCTM(currContext, 1.0, -1.0);
    CGContextTranslateCTM( currContext, 0, -bgImage.size.height );
    
    // and add some text...
    CGContextSetRGBFillColor(currContext, 1.0f, 1.0f, 1.0f, 1.0f);
    CGContextSetTextDrawingMode(currContext, kCGTextFill);
    CGContextSetShouldAntialias(currContext, true);
    
    // draw the heading
    float border = 7*scaleFactor;
    [title drawInRect:CGRectMake(border,
								 4 * border,
								 bgImage.size.width - 2 * border,
								 bgImage.size.height - 2 * border)
			 withFont:[UIFont systemFontOfSize:30*scaleFactor]
		lineBreakMode:NSLineBreakByClipping
			alignment:NSTextAlignmentCenter];
    
    // retrieve the screenshot from the current context
    UIImage* blendetImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return blendetImage;
}

@end
