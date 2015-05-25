// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "FaceTrackingViewController.h"

@interface FaceTrackingViewController ()

@end

@implementation FaceTrackingViewController

-(IBAction)switchCamera:(id)sender;
{
    if( m_pMetaioSDK )
    {
		metaio::stlcompat::Vector<metaio::Camera> cameras = m_pMetaioSDK->getCameraList();
		if (!cameras.empty())
		{
            metaio::Camera currentCamera = m_pMetaioSDK->getCamera();
            int cameraFacing = metaio::Camera::FACE_BACK;
            if(currentCamera.facing == metaio::Camera::FACE_BACK) {
                cameraFacing = metaio::Camera::FACE_FRONT;
            }
            metaio::Camera camera = cameras[0];
            // search for front facing camera
            for (int i=0; i<cameras.size(); i++)
            {
                if (cameras[i].facing == cameraFacing)
                {
                    camera = cameras[i];
                    break;
                }
            }
            m_pMetaioSDK->startCamera(camera);
		} else {
			NSLog(@"No Camera Found");
		}
    }
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	// Start with front camera
	if (m_pMetaioSDK)
	{
		m_pMetaioSDK->startCamera(metaio::Camera::FACE_FRONT);
	}
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // load tracking configuration

    bool success = m_pMetaioSDK->setTrackingConfiguration("FACE");
	if( !success)
    {
        NSLog(@"No success loading the face tracking configuration");
	}
    
    
    // load content
    NSString* filepath = [[NSBundle mainBundle] pathForResource:@"Thought1"
                                                ofType:@"png"
												inDirectory:@"tutorialContent_crossplatform/TutorialFaceTracking/Assets"];
    
	if(filepath)
	{
        metaio::IGeometry* geometry =  m_pMetaioSDK->createGeometryFromImage([filepath UTF8String]);
        if (geometry)
        {
            geometry->setScale(0.5f);
            geometry->setTranslation(metaio::Vector3d(60.f, 80.f, 0.f));
        }
        else
        {
            NSLog(@"error, could not load %@", filepath);
        }
    }
    
    filepath = [[NSBundle mainBundle] pathForResource:@"Thought2"
                                      ofType:@"png"
                                      inDirectory:@"tutorialContent_crossplatform/TutorialFaceTracking/Assets"];
    
	if(filepath)
	{
        metaio::IGeometry* geometry =  m_pMetaioSDK->createGeometryFromImage([filepath UTF8String]);
        if (geometry)
        {
            geometry->setScale(0.5f);
            geometry->setTranslation(metaio::Vector3d(-60.f, -60.f, 0.f));
        }
        else
        {
            NSLog(@"error, could not load %@", filepath);
        }
    }
}

@end
