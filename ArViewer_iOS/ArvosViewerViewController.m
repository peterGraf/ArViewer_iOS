/*
 * ArvosViewerViewController.m - ArViewer_iOS
 *
 * Copyright (C) 2013, Peter Graf
 *
 * This file is part of Arvos - AR Viewer Open Source for iOS.
 * Arvos is free software.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * For more information on the AR Viewer Open Source or Peter Graf,
 * please see: http://www.mission-base.com/.
 */

#import "ArvosViewerViewController.h"
#import "Arvos.h"
#import "ArvosCameraController.h"
#import "ArvosAugment.h"
#import "ArvosGlView.h"
#import "ArvosRadarView.h"

// CONSTANTS
#define kAccelerometerFrequency		100.0 // Hz
#define kFilteringFactor			0.1

@interface ArvosViewerViewController () {
    Arvos*                  mInstance;
	ArvosGlView*            mGlView;
    UIAccelerationValue     accel[3];
	ArvosRadarView*			mRadarView;
	CLLocationManager*		mLocationManager;
}

@end

@implementation ArvosViewerViewController

- (void)dealloc {
	mGlView = nil;
	[self.cameraController.captureSession stopRunning];
	[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
}

- (id)initWithAugment:(ArvosAugment*)augment {
	self = [super initWithNibName:nil bundle:nil];
	if (self) {
        mInstance = [Arvos sharedInstance];
		self.augment = augment;
	}
	return self;
}

- (void)viewDidAppear:(BOOL)paramAnimated {
	[super viewDidAppear:paramAnimated];
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.view.backgroundColor = [UIColor blueColor];
	self.title = self.augment.name;
	self.cameraController = [[ArvosCameraController alloc] init];
	[self.cameraController addVideoInput];
	[self.cameraController addVideoPreviewLayer];
	[self.cameraController setPortrait];
	[[self.view layer] addSublayer:[self.cameraController previewLayer]];
	[[self.cameraController captureSession] startRunning];

	mGlView = [[ArvosGlView alloc] initWithFrame:self.view.bounds andAugment:self.augment];
	[self.view.layer addSublayer:mGlView.layer];
    
    [mGlView startAnimation];
	
	//Configure and start accelerometer
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];


	// radar view
	mLocationManager = [CLLocationManager new];
	mLocationManager.delegate = self;
	[mLocationManager startUpdatingHeading];
	
	mRadarView = [[ArvosRadarView alloc] initWithFrame:CGRectMake(10., 30., 80., 80.)];
	[self.view.layer addSublayer:mRadarView.layer];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
	return YES;
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	//Use a basic low-pass filter to only keep the gravity in the accelerometer values
	accel[0] = acceleration.x * kFilteringFactor + accel[0] * (1.0 - kFilteringFactor);
	accel[1] = acceleration.y * kFilteringFactor + accel[1] * (1.0 - kFilteringFactor);
	accel[2] = acceleration.z * kFilteringFactor + accel[2] * (1.0 - kFilteringFactor);
	
	//Update the accelerometer values
	[mInstance setAccel:accel];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
	mRadarView.rotation = newHeading.trueHeading;
}

@end