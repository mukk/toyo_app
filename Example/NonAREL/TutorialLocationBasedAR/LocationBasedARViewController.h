// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "NonARELTutorialViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import <metaioSDK/IMetaioSDK.h>

namespace metaio
{
    class IGeometry;   // forward declaration
}

@interface LocationBasedARViewController : NonARELTutorialViewController
{	
    metaio::IAnnotatedGeometriesGroup* annotatedGeometriesGroup;
    metaio::IGeometry* londonGeo;
    metaio::IGeometry* romeGeo;
    metaio::IGeometry* parisGeo;
    metaio::IGeometry* tokyoGeo;
    metaio::IGeometry* metaioMan;
    metaio::IRadar* m_radar;
    
    metaio::LLACoordinate   m_currentLocation;
}

- (metaio::IGeometry*)loadUpdatedAnnotation:(metaio::IGeometry*)geometry userData:(void*)userData existingAnnotation:(metaio::IGeometry*)existingAnnotation;

@end
