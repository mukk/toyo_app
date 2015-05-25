// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "CustomShadingViewController.h"


class Callback : public metaio::IShaderMaterialOnSetConstantsCallback
{
public:
	Callback(CustomShadingViewController* vc) :
		m_vc(vc)
	{
	}

private:
	virtual void onSetShaderMaterialConstants(const metaio::stlcompat::String& shaderMaterialName, void* extra,
		metaio::IShaderMaterialSetConstantsService* constantsService) override
	{
		// This will be identical to m_pModel since we only assigned this callback to that single geometry:
		// metaio::IGeometry* geometry = static_cast<metaio::IGeometry*>(extra);

		// We just pass the positive sinus (range [0;1]) of absolute time in seconds so that we can
		// use it to fade our effect in and out.
		const float time[1] = { 0.5f * (1.0f + (float)sin(CACurrentMediaTime())) };
		constantsService->setShaderUniformF("myValue", time, 1);
	}

	// This is here in case you need access to the view controller's methods (not used in this example)
	// the __weak is important here to aviod retain cycles when using ARC
	__weak CustomShadingViewController* m_vc;
};


@interface CustomShadingViewController ()

@end

@implementation CustomShadingViewController
{
	Callback*		m_pCallback;
	metaio::IGeometry* m_model;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString* trackingDataFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_MarkerlessFast"
																 ofType:@"xml"
															inDirectory:@"tutorialContent_crossplatform/TutorialCustomShading/Assets"];

	if (trackingDataFile)
	{
        const char *utf8Path = [trackingDataFile UTF8String];
        if (!m_pMetaioSDK->setTrackingConfiguration(metaio::Path::fromUTF8(utf8Path)))
			NSLog(@"Failed to load the tracking configuration");
	}
	else
		NSLog(@"Tracking config file not found");

    NSString* modelFilename = [[NSBundle mainBundle] pathForResource:@"metaioman"
															  ofType:@"md2"
														 inDirectory:@"tutorialContent_crossplatform/TutorialCustomShading/Assets"];
	m_model = 0;

	if (modelFilename)
	{
        const char *utf8Path = [modelFilename UTF8String];
        m_model = m_pMetaioSDK->createGeometry(metaio::Path::fromUTF8(utf8Path));
        if (m_model)
		{
			NSLog(@"Loaded model %@", modelFilename);

			m_model->startAnimation("idle", true);

			// Make him look away from the pattern
			m_model->setScale(2);
			m_model->setRotation(metaio::Rotation(-(float)M_PI/2.0f, 0, 0));
			m_model->setTranslation(metaio::Vector3d(0, -100, 50));
		}
		else
            NSLog(@"Failed to load model %@", modelFilename);
    }
	else
		NSLog(@"Model file not found");


	NSString* shaderMaterialsFilename = [[NSBundle mainBundle] pathForResource:@"shader_materials"
																		ofType:@"xml"
																   inDirectory:@"tutorialContent_crossplatform/TutorialCustomShading/Assets"];

	if (shaderMaterialsFilename)
	{
        const char* utf8Path = [shaderMaterialsFilename UTF8String];
        if (!m_pMetaioSDK->loadShaderMaterials(metaio::Path::fromUTF8(utf8Path)))
		{
			NSLog(@"Failed to load shader materials from %@", shaderMaterialsFilename);
		}
		else
		{
			// Successfully loaded shader materials
			if (m_model)
			{
				m_model->setShaderMaterial("tutorial_customshading");

				m_pCallback = new Callback(self);

				m_model->setShaderMaterialOnSetConstantsCallback(m_pCallback);
			}
		}
    }
	else
		NSLog(@"Shader materials XML file not found");
}

- (void)dealloc
{
	//remove shader material callback
	m_model->setShaderMaterialOnSetConstantsCallback(0);
	delete m_pCallback;
	m_pCallback = 0;
}

@end
