// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "NonARELTutorialViewController.h"

@interface ContentTypesViewController : NonARELTutorialViewController
{
	metaio::IGeometry*	m_imagePlane;
    metaio::IGeometry*	m_metaioMan;
    metaio::IGeometry*	m_moviePlane;
    metaio::IGeometry*	m_truck;
	int					m_selectedModel;

	__weak IBOutlet UIButton* m_modelButton;
	__weak IBOutlet UIButton* m_imageButton;
	__weak IBOutlet UIButton* m_truckButton;
	__weak IBOutlet UIButton* m_movieButton;
}

@end

