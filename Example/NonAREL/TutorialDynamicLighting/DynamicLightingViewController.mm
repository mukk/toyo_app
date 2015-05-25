// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "DynamicLightingViewController.h"


@interface DynamicLightingViewController ()

@end

@implementation DynamicLightingViewController

- (metaio::IGeometry*)createLightGeometry
{
	NSString* filename = [[NSBundle mainBundle] pathForResource:@"sphere_10mm"
														 ofType:@"obj"
													inDirectory:@"tutorialContent_crossplatform/TutorialDynamicLighting/Assets"];

    if (filename) {
        const char* utf8Path = [filename UTF8String];
        return m_pMetaioSDK->createGeometry(metaio::Path::fromUTF8(utf8Path));
    } else {
		NSLog(@"Could not find 3D model to use as light indicator");
		return 0;
	}
}


- (void)drawFrame
{
	[super drawFrame];

	// If content not loaded yet, do nothing
	if (!m_pDirectionalLight)
		return;

	// Lights circle around
	const float time = (float)CACurrentMediaTime();
	const metaio::Vector3d lightPos(200*cosf(time), 120*sinf(0.25f*time), 200*sinf(time));

	const float FREQ2MUL = 0.4f;
	const metaio::Vector3d lightPos2(150*cosf(FREQ2MUL*2.2f*time) * (1 + 2+2*sinf(FREQ2MUL*0.6f*time)), 30*sinf(FREQ2MUL*0.35f*time), 150*sinf(FREQ2MUL*2.2f*time));

	const metaio::Vector3d directionalLightDir(cosf(1.2f*time), sinf(0.25f*time), sinf(0.8f*time));


	// This will only apply in the upcoming frame:

	// Directional light
	m_pDirectionalLight->setDirection(directionalLightDir);
	[self updateLightIndicator:m_pDirectionalLightGeo light:m_pDirectionalLight];

	// Point light
	m_pPointLight->setTranslation(lightPos);
	[self updateLightIndicator:m_pPointLightGeo light:m_pPointLight];

	// Spot light
	m_pSpotLight->setTranslation(lightPos2);
	m_pSpotLight->setDirection(-lightPos2); // spot towards origin of COS
	[self updateLightIndicator:m_pSpotLightGeo light:m_pSpotLight];
}


- (void)updateLightIndicator:(metaio::IGeometry*)indicatorGeo light:(metaio::ILight*)light
{
	indicatorGeo->setVisible(light->isEnabled());

	if (!light->isEnabled())
		return;

	if (light->getType() == metaio::ELIGHT_TYPE_DIRECTIONAL)
	{
		metaio::Vector3d dir = light->getDirection();
		dir /= dir.norm();

		// Indicate "source" of directional light (not really the source because it's infinite)
		indicatorGeo->setTranslation(metaio::Vector3d(-200.0f * dir.x, -200.0f * dir.y, -200.0f * dir.z));
	}
	else
		indicatorGeo->setTranslation(light->getTranslation());
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString* trackingDataFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_MarkerlessFast"
																 ofType:@"xml"
															inDirectory:@"tutorialContent_crossplatform/TutorialDynamicLighting/Assets"];

	if (trackingDataFile)
	{
        const char *utf8Path = [trackingDataFile UTF8String];
        if (!m_pMetaioSDK->setTrackingConfiguration(metaio::Path::fromUTF8(utf8Path)))
			NSLog(@"Failed to load the tracking configuration");
	}
	else
		NSLog(@"Tracking config file not found");

    NSString* modelFilename = [[NSBundle mainBundle] pathForResource:@"cube_50mm"
															  ofType:@"obj"
														 inDirectory:@"tutorialContent_crossplatform/TutorialDynamicLighting/Assets"];
	metaio::IGeometry* model = 0;

	if (modelFilename)
	{
        const char* utf8Path = [modelFilename UTF8String];
        model = m_pMetaioSDK->createGeometry(metaio::Path::fromUTF8(utf8Path));
        if (model)
			NSLog(@"Loaded model %@", modelFilename);
		else
            NSLog(@"Failed to load model %@", modelFilename);
    }
	else
		NSLog(@"Model file not found");


	m_pMetaioSDK->setAmbientLight(metaio::Vector3d(0.05f));

	m_pDirectionalLight = m_pMetaioSDK->createLight();
	m_pDirectionalLight->setType(metaio::ELIGHT_TYPE_DIRECTIONAL);
	m_pDirectionalLight->setAmbientColor(metaio::Vector3d(0.0f, 0.15f, 0.0f)); // slightly green
	m_pDirectionalLight->setDiffuseColor(metaio::Vector3d(0.6f, 0.2f, 0.0f)); // orange
	m_pDirectionalLight->setCoordinateSystemID(1);
	m_pDirectionalLightGeo = [self createLightGeometry];
	m_pDirectionalLightGeo->setCoordinateSystemID(m_pDirectionalLight->getCoordinateSystemID());
	m_pDirectionalLightGeo->setDynamicLightingEnabled(false);

	m_pPointLight = m_pMetaioSDK->createLight();
	m_pPointLight->setType(metaio::ELIGHT_TYPE_POINT);
	m_pPointLight->setAmbientColor(metaio::Vector3d(0.0f, 0.0f, 0.15f)); // slightly blue ambient
	m_pPointLight->setAttenuation(metaio::Vector3d(0.0f, 0.0f, 40.0f));
	m_pPointLight->setDiffuseColor(metaio::Vector3d(0.0f, 0.8f, 0.05f)); // green-ish
	m_pPointLight->setCoordinateSystemID(1);
	m_pPointLightGeo = [self createLightGeometry];
	m_pPointLightGeo->setCoordinateSystemID(m_pPointLight->getCoordinateSystemID());
	m_pPointLightGeo->setDynamicLightingEnabled(false);

	m_pSpotLight = m_pMetaioSDK->createLight();
	m_pSpotLight->setAmbientColor(metaio::Vector3d(0.17f, 0.0f, 0.0f)); // slightly red ambient
	m_pSpotLight->setType(metaio::ELIGHT_TYPE_SPOT);
	m_pSpotLight->setRadiusDegrees(10);
	m_pSpotLight->setDiffuseColor(metaio::Vector3d(1, 1, 0)); // yellow
	m_pSpotLight->setCoordinateSystemID(1);
	m_pSpotLightGeo = [self createLightGeometry];
	m_pSpotLightGeo->setCoordinateSystemID(m_pSpotLight->getCoordinateSystemID());
	m_pSpotLightGeo->setDynamicLightingEnabled(false);
}

@end
