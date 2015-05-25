// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import <QuartzCore/QuartzCore.h>
#import "LocationBasedARViewController.h"
#include <metaioSDK/Common/SensorsComponentIOS.h>
#include <metaioSDK/IMetaioSDKIOS.h>

class AnnotatedGeometriesGroupCallback : public metaio::IAnnotatedGeometriesGroupCallback
{
public:
	AnnotatedGeometriesGroupCallback(LocationBasedARViewController* _vc) : vc(_vc) {}

	virtual metaio::IGeometry* loadUpdatedAnnotation(metaio::IGeometry* geometry, void* userData, metaio::IGeometry* existingAnnotation) override
	{
		return [vc loadUpdatedAnnotation:geometry userData:userData existingAnnotation:existingAnnotation];
	}

	LocationBasedARViewController* vc;
};

@interface LocationBasedARViewController ()

@property (nonatomic, assign) AnnotatedGeometriesGroupCallback *annotatedGeometriesGroupCallback;

- (UIImage*)getAnnotationImageForTitle:(NSString*)title;
@end


@implementation LocationBasedARViewController

#pragma mark - UIViewController lifecycle

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	if (!m_pMetaioSDK->setTrackingConfiguration("GPS"))
	{
		NSLog(@"Failed to set the tracking configuration");
	}

	annotatedGeometriesGroup = m_pMetaioSDK->createAnnotatedGeometriesGroup();
	self.annotatedGeometriesGroupCallback = new AnnotatedGeometriesGroupCallback(self);
	annotatedGeometriesGroup->registerCallback(self.annotatedGeometriesGroupCallback);

	// Clamp geometries' Z position to range [5000;200000] no matter how close or far they are away.
	// This influences minimum and maximum scaling of the geometries (easier for development).
	m_pMetaioSDK->setLLAObjectRenderingLimits(5, 200);

	// Set render frustum accordingly
	m_pMetaioSDK->setRendererClippingPlaneLimits(10, 220000);

	// let's create LLA objects for known cities
	metaio::LLACoordinate munich = metaio::LLACoordinate(48.142573, 11.550321, 0, 0);
	metaio::LLACoordinate london = metaio::LLACoordinate(51.50661, -0.130463, 0, 0);
	metaio::LLACoordinate rome = metaio::LLACoordinate(41.90177, 12.45987, 0, 0);
	metaio::LLACoordinate paris = metaio::LLACoordinate(48.85658, 2.348671, 0, 0);
	metaio::LLACoordinate tokyo = metaio::LLACoordinate(35.657464, 139.773865, 0, 0);
	
	// Load some POIs. Each of them has the same shape at its geoposition. We pass a string
	// (const char*) to IAnnotatedGeometriesGroup::addGeometry so that we can use it as POI title
	// in the callback, in order to create an annotation image with the title on it.
	londonGeo = [self createPOIGeometry:london];
	annotatedGeometriesGroup->addGeometry(londonGeo, (void*)"London");

	parisGeo = [self createPOIGeometry:paris];
	annotatedGeometriesGroup->addGeometry(parisGeo, (void*)"Paris");
	
	romeGeo = [self createPOIGeometry:rome];
	annotatedGeometriesGroup->addGeometry(romeGeo, (void*)"Rome");
	
	tokyoGeo = [self createPOIGeometry:tokyo];
	annotatedGeometriesGroup->addGeometry(tokyoGeo, (void*)"Tokyo");

	
	// load a 3D model and put it in Munich
	NSString* metaioManModel = [[NSBundle mainBundle] pathForResource:@"metaioman"
															   ofType:@"md2"
														  inDirectory:@"tutorialContent_crossplatform/TutorialLocationBasedAR/Assets"];
	if (metaioManModel)
	{
        const char *utf8Path = [metaioManModel fileSystemRepresentation];
		metaioMan = m_pMetaioSDK->createGeometry(metaio::Path::fromUTF8(utf8Path));
		metaioMan->setTranslationLLA(munich);
		metaioMan->setLLALimitsEnabled(true);
		metaioMan->setScale(500.f);
	}
	else
	{
		NSLog(@"Model not found");
	}

	// Create radar object
	m_radar = m_pMetaioSDK->createRadar();
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *assetFolder = @"tutorialContent_crossplatform/TutorialLocationBasedAR/Assets";
    NSString *radarPath = [mainBundle pathForResource:@"radar"
                                               ofType:@"png"
                                          inDirectory:assetFolder];
    const char *radarUtf8Path = [radarPath UTF8String];
    
    m_radar->setBackgroundTexture(metaio::Path::fromUTF8(radarUtf8Path));
    
    NSString *yellowPath = [mainBundle pathForResource:@"yellow"
                                                ofType:@"png"
                                           inDirectory:assetFolder];
    const char *yellowUtf8Path = [yellowPath UTF8String];
    m_radar->setObjectsDefaultTexture(metaio::Path::fromUTF8(yellowUtf8Path));
    m_radar->setRelativeToScreen(metaio::IGeometry::ANCHOR_TL);
    
	// Add geometries to the radar
	m_radar->add(londonGeo);
	m_radar->add(parisGeo);
	m_radar->add(romeGeo);
	m_radar->add(tokyoGeo);
	m_radar->add(metaioMan);
}

- (void)viewWillDisappear:(BOOL)animated
{
	// as soon as the view disappears, we stop rendering and stop the camera
	m_pMetaioSDK->stopCamera();
	[super viewWillDisappear:animated];
	
	annotatedGeometriesGroup->registerCallback(NULL);
	if (self.annotatedGeometriesGroupCallback) {
		delete self.annotatedGeometriesGroupCallback;
		self.annotatedGeometriesGroupCallback = NULL;
	}
}


- (void)drawFrame
{
    // make pins appear upright
	if (m_pMetaioSDK && m_pSensorsComponent)
	{
		const metaio::SensorValues sensorValues = m_pSensorsComponent->getSensorValues();

		float heading = 0.0f;
		if (sensorValues.hasAttitude())
		{
			float m[9];
			sensorValues.attitude.getRotationMatrix(m);

			metaio::Vector3d v(m[6], m[7], m[8]);
			v = v.getNormalized();

			heading = -atan2(v.y, v.x) - (float)M_PI_2;
		}

		metaio::IGeometry* geos[] = {londonGeo, parisGeo, romeGeo, tokyoGeo};
		const metaio::Rotation rot((float)M_PI_2, 0.0f, -heading);
		for (int i = 0; i < 4; ++i)
		{
			geos[i]->setRotation(rot);
		}
	}

	[super drawFrame];
}


#pragma mark - Handling Touches

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// Here's how to pick a geometry
	UITouch *touch = [touches anyObject];
	CGPoint loc = [touch locationInView:self.glkView];
	
	// get the scale factor (will be 2 for retina screens)
	float scale = self.glkView.contentScaleFactor;
	
	// ask sdk if the user picked an object
	// the 'true' flag tells sdk to actually use the vertices for a hit-test, instead of just the bounding box
	 metaio::IGeometry* model = m_pMetaioSDK->getGeometryFromViewportCoordinates(loc.x * scale, loc.y * scale, true);
	
	if ( model )
	{
		metaio::LLACoordinate modelCoordinate = model->getTranslationLLA();
		NSLog(@"You picked a model at location %f, %f!", modelCoordinate.latitude, modelCoordinate.longitude);
		m_radar->setObjectsDefaultTexture([[[NSBundle mainBundle] pathForResource:@"yellow"
																		   ofType:@"png"
																	  inDirectory:@"tutorialContent_crossplatform/TutorialLocationBasedAR/Assets"] UTF8String]);
		m_radar->setObjectTexture(model, [[[NSBundle mainBundle] pathForResource:@"red"
																		  ofType:@"png"
																	 inDirectory:@"tutorialContent_crossplatform/TutorialLocationBasedAR/Assets"] UTF8String]);
	}
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	// Implement if you need to handle touches
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	// Implement if you need to handle touches
}


#pragma mark - Helper methods

- (metaio::IGeometry*)createPOIGeometry:(const metaio::LLACoordinate&)lla
{
	NSString* poiModelPath = [[NSBundle mainBundle] pathForResource:@"ExamplePOI"
															 ofType:@"obj"
														inDirectory:@"tutorialContent_crossplatform/TutorialLocationBasedAR/Assets"];
	assert(poiModelPath);
    
    const char *utf8Path = [poiModelPath fileSystemRepresentation];
    metaio::IGeometry* geo = m_pMetaioSDK->createGeometry(metaio::Path::fromUTF8(utf8Path));
	geo->setTranslationLLA(lla);
	geo->setLLALimitsEnabled(true);
	geo->setScale(100);
	return geo;
}

- (metaio::IGeometry*)loadUpdatedAnnotation:(metaio::IGeometry*)geometry userData:(void*)userData existingAnnotation:(metaio::IGeometry*)existingAnnotation
{
	if (existingAnnotation)
	{
		// We don't update the annotation if e.g. distance has changed
		return existingAnnotation;
	}

	if (!userData)
	{
		return 0;
	}

    // use this method to create custom annotations
	//UIImage* img = [self getAnnotationImageForTitle:[NSString stringWithUTF8String:(const char*)userData]];

    UIImage* thumbnail = [UIImage imageNamed:@"AppIcon72x72~ipad"];
    UIImage* img = metaio::createAnnotationImage(
                                         [NSString stringWithFormat:@"annotation-%s", (const char*)userData],
                                         geometry->getTranslationLLA(),
                                         m_currentLocation,
                                         thumbnail,
                                         nil,
                                         5
                                         );

	return m_pMetaioSDK->createGeometryFromCGImage([[NSString stringWithFormat:@"annotation-%s", (const char*)userData] UTF8String], img.CGImage, true, false);
}




/** This is an example for how you can create custom annotations for your objects */
- (UIImage*)getAnnotationImageForTitle:(NSString*)title
{
	UIImage* bgImage = [UIImage imageNamed:@"tutorialContent_crossplatform/TutorialLocationBasedAR/Assets/POI_bg.png"];
	assert(bgImage);

	// Make bgImage.size the real resolution
	bgImage = [UIImage imageWithCGImage:bgImage.CGImage scale:1 orientation:UIImageOrientationUp];

	UIGraphicsBeginImageContext(bgImage.size);
	CGContextRef currContext = UIGraphicsGetCurrentContext();

	// Mirror the context transformation to draw the images correctly (CG has different coordinates)
	CGContextSaveGState(currContext);
	CGContextScaleCTM(currContext, 1.0, -1.0);

	CGContextDrawImage(currContext, CGRectMake(0, 0, bgImage.size.width, -bgImage.size.height), bgImage.CGImage);

	CGContextRestoreGState(currContext);

	// Add title
	CGContextSetRGBFillColor(currContext, 1.0f, 1.0f, 1.0f, 1.0f);
	CGContextSetTextDrawingMode(currContext, kCGTextFill);
	CGContextSetShouldAntialias(currContext, true);

	const CGFloat fontSize = floor(bgImage.size.height * 0.5);
	const CGFloat border = floor(bgImage.size.height * 0.1);
	CGRect titleRect = CGRectMake(border, border, bgImage.size.width - 2*border, bgImage.size.height - 2*border);
	const CGSize titleActualSize = [title sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:titleRect.size lineBreakMode:NSLineBreakByTruncatingTail];

	// Vertically center text
	titleRect.origin.y += (titleRect.size.height - titleActualSize.height) / 2.0f;

	[title drawInRect:titleRect
			 withFont:[UIFont systemFontOfSize:fontSize]
		lineBreakMode:NSLineBreakByTruncatingTail
			alignment:NSTextAlignmentCenter];

	// Create composed UIImage from the context
	UIImage* finalImage = UIGraphicsGetImageFromCurrentImageContext();

	UIGraphicsEndImageContext();

	return finalImage;
}



@end
