// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "NonARELTutorialViewController.h"

#include <metaioSDK/IMetaioSDK.h>

@interface DynamicLightingViewController : NonARELTutorialViewController
{
@public
	metaio::ILight*		m_pPointLight;
	metaio::ILight*		m_pSpotLight;
	metaio::ILight*		m_pDirectionalLight;

	metaio::IGeometry*	m_pPointLightGeo;
	metaio::IGeometry*	m_pSpotLightGeo;
	metaio::IGeometry*	m_pDirectionalLightGeo;
}

@end
