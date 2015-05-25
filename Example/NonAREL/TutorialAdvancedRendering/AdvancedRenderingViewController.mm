// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "AdvancedRenderingViewController.h"

@interface AdvancedRenderingViewController ()

@end

@implementation AdvancedRenderingViewController

- (void) viewDidLoad
{
	[super viewDidLoad];


	// load our tracking configuration
	NSString* trackingDataFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_MarkerlessFast"
																 ofType:@"xml"
															inDirectory:@"tutorialContent_crossplatform/TutorialAdvancedRendering/Assets"];

	if(trackingDataFile)
	{
        const char *utf8Path = [trackingDataFile UTF8String];
        bool success = m_pMetaioSDK->setTrackingConfiguration(metaio::Path::fromUTF8(utf8Path));
		if( !success)
			NSLog(@"No success loading the tracking configuration");
	}


	// load content
	NSString* metaioManModel = [[NSBundle mainBundle] pathForResource:@"metaioman"
															   ofType:@"md2"
														  inDirectory:@"tutorialContent_crossplatform/TutorialAdvancedRendering/Assets"];

	if (metaioManModel)
	{
		// if this call was successful, theLoadedModel will contain a pointer to the 3D model
        const char *utf8Path = [metaioManModel UTF8String];
        metaio::IGeometry* theLoadedModel =  m_pMetaioSDK->createGeometry(metaio::Path::fromUTF8(utf8Path));
		if( theLoadedModel )
		{
			// scale it a bit up
			theLoadedModel->setScale(metaio::Vector3d(4.0f,4.0f,4.0f));
		}
		else
		{
			NSLog(@"error, could not load %@", metaioManModel);
		}
	}
	else
	{
		NSLog(@"Model file not found");
	}


	// Enable advanced rendering
    if(!m_pMetaioSDK->autoEnableAdvancedRenderingFeatures()) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Advanced Rendering Features Disabled"
                                                        message:@"This device does not support the advanced rendering features of the metaio SDK."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
	// Adjust effects
	m_pMetaioSDK->setDepthOfFieldParameters(0.1f, 0.6f, 0.2f);
	// Slightly reduce amount of motion blur
	m_pMetaioSDK->setMotionBlurIntensity(0.8f);

}

@end
