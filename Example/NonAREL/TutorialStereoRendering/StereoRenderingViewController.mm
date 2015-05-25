// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "StereoRenderingViewController.h"

@interface StereoRenderingViewController ()

@end

@implementation StereoRenderingViewController

- (void) viewDidLoad
{
	[super viewDidLoad];


	// load our tracking configuration
	NSString* trackingDataFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_MarkerlessFast"
																 ofType:@"xml"
															inDirectory:@"tutorialContent_crossplatform/TutorialStereoRendering/Assets"];
	assert(trackingDataFile);
	if(trackingDataFile)
	{
        const char *utf8Path = [trackingDataFile fileSystemRepresentation];
        bool success = m_pMetaioSDK->setTrackingConfiguration(metaio::Path::fromUTF8(utf8Path));
		if( !success)
			NSLog(@"No success loading the tracking configuration");
	}


	// load content
	NSString* metaioManModel = [[NSBundle mainBundle] pathForResource:@"metaioman"
															   ofType:@"md2"
														  inDirectory:@"tutorialContent_crossplatform/TutorialStereoRendering/Assets"];
	assert(metaioManModel);
	if(metaioManModel)
	{
        // if this call was successful, theLoadedModel will contain a pointer to the 3D model
        const char *utf8Path = [metaioManModel fileSystemRepresentation];
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

	// Adjust stereo calibration (i.e. difference in view of camera vs. left/right eye).
	// These are contrived example values. Real values should be gathered by an exact
	// calibration. Note that for typical scenarios, e.g. AR/VR glasses where the camera has
	// a translation to left/right eye, the camera image is still rendered as for the mono
	// case (it is not transformed by the hand-eye calibration to look correct). Therefore
	// on glasses, see-through mode should be enabled (see below).
	// This is just a contrived example. The values are overwritten below, using the recommended
	// approach.
	m_pMetaioSDK->setHandEyeCalibration(
		metaio::Vector3d(70, 0, 0),
		metaio::Rotation(0, -18.0f * (float)M_PI/180.0f, 0),
		metaio::ECT_RENDERING_STEREO_LEFT);
	m_pMetaioSDK->setHandEyeCalibration(
		metaio::Vector3d(10, 0, 0),
		metaio::Rotation(0, 7.0f * (float)M_PI/180.0f, 0),
		metaio::ECT_RENDERING_STEREO_RIGHT);

	// Recommended way to load stereo calibration (in this order):
	// 1) Load your own, exact calibration (calibration XML file created with Toolbox 6.0.1 or newer),
	//    i.e. *you* as developer provide a calibration file. Note that the path to "hec.xml"
	//    doesn't actually exist in this example; it's only there to show how to apply a custom
	//    calibration file.
	// 2) Load calibration XML file from default path, i.e. in case the user has used Toolbox to
	//    calibrate (result file always stored at same path).
	// 3) Load calibration built into Metaio SDK for known devices (may not give perfect result
	//    because stereo glasses can vary).
	// Items 2) and 3) only do something on Android for the moment, as there are no supported,
	// non-Android stereo devices yet.
	NSString* calibrationFilePath = [[NSBundle mainBundle] pathForResource:@"hec"
																	ofType:@"xml"
															   inDirectory:@"tutorialContent_crossplatform/TutorialStereoRendering/Assets"];

	if ((calibrationFilePath == nil ||
		 !m_pMetaioSDK->setHandEyeCalibrationFromFile(metaio::Path::fromUTF8(calibrationFilePath.UTF8String))) &&
		!m_pMetaioSDK->setHandEyeCalibrationFromFile())
	{
		m_pMetaioSDK->setHandEyeCalibrationByDevice();
	}

	// Enable stereo rendering
	m_pMetaioSDK->setStereoRendering(true);

	// Enable see through mode (e.g. on glasses)
	m_pMetaioSDK->setSeeThrough(true);
	m_pMetaioSDK->setSeeThroughColor(0, 0, 0, 255);
}

@end
