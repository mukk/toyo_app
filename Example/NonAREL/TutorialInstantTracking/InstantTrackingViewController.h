// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "NonARELTutorialViewController.h"

@interface InstantTrackingViewController : NonARELTutorialViewController
{
	metaio::IGeometry*	m_tigerModel;					// pointer to the tiger model
	bool				m_isCloseToModel;				// to keep track if we are close to the model
	bool				m_previewMode;					// the flag indicating a mode of instant tracking
	bool				m_mustUseInstantTrackingEvent;	// whether to set tracking configuration on onInstantTrackingEvent

	__weak IBOutlet UIButton* m_2DButton;
	__weak IBOutlet UIButton* m_2DRectifiedButton;
	__weak IBOutlet UIButton* m_3DButton;
	__weak IBOutlet UIButton* m_2DSLAMButton;
	__weak IBOutlet UIButton* m_2DSLAMExtrapolationButton;
}

- (void) checkDistanceToTarget;

@end
