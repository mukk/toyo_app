// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "MenuViewController.h"
#import "AREL/ExampleARELViewController.h"

@interface MenuViewController ()
{
    NSString *tutorialId;
    NSString *arelConfigFile;
}
@end

@implementation MenuViewController
@synthesize tutorialsView;

- (void)viewWillAppear:(BOOL)animated
{
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"tutorialContent_crossplatform/Menu"];
    NSURL *url = [NSURL fileURLWithPath:htmlPath];
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    [tutorialsView loadRequest:requestObj];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL* theURL = [request mainDocumentURL];
    NSString* absoluteString = [theURL absoluteString];
    tutorialId = [[absoluteString componentsSeparatedByString:@"="] lastObject];

    if ([[absoluteString lowercaseString] hasPrefix:@"metaiosdkexample://"])
    {
        if (tutorialId)
        {
			UIViewController* vc = [[UIStoryboard storyboardWithName:tutorialId bundle:nil] instantiateInitialViewController];
			vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
			[self presentViewController:vc animated:YES completion:nil];
		}
        return NO;
    }
    else if([[absoluteString lowercaseString] hasPrefix:@"metaiosdkexamplearel://"])
    {
        if (tutorialId)
        {
			arelConfigFile = @"index";
			NSString *tutorialDir = [NSString stringWithFormat:@"tutorialContent_crossplatform/Tutorial%@", tutorialId];
			NSString *arelConfigFilePath = [[NSBundle mainBundle] pathForResource:arelConfigFile ofType:@"xml" inDirectory:tutorialDir];
			NSLog(@"Will be loading AREL from %@",arelConfigFilePath);
			ExampleARELViewController* tutorialViewController = [[UIStoryboard storyboardWithName:@"AREL" bundle:nil] instantiateInitialViewController];
			tutorialViewController.arelFilePath = arelConfigFilePath;
			tutorialViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
			[self presentViewController:tutorialViewController animated:YES completion:nil];
        }
        return NO;
    }
    else if ([[absoluteString lowercaseString] rangeOfString:@"metaio.com"].location != NSNotFound)
    {
		// Open in external browser
		[[UIApplication sharedApplication] openURL:theURL];
        return NO;
    }

    return YES;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    tutorialsView.delegate = self;
}


- (void)viewDidUnload
{
    [self setTutorialsView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


// Force fullscreen without status bar on iOS 7
- (BOOL)prefersStatusBarHidden
{
	return YES;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
