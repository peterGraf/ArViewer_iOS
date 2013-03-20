/*
 ArvosAugment.m - ArViewer_iOS
 
 Copyright (C) 2013, Peter Graf
 
 This file is part of Arvos - AR Viewer Open Source for iOS.
 Arvos is free software.
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 For more information on the AR Viewer Open Source or Peter Graf,
 please see: http://www.mission-base.com/.
 */

#import "Arvos.h"
#import "ArvosAugment.h"
#import "ArvosPoi.h"
#import "ArvosPoiObject.h"

@interface ArvosAugment () {
	Arvos*			mInstance;
	NSMutableArray* mPois;
}

- (UIImage*)downloadTextureFromUrl:(NSString*)baseUrl ;

@end

@implementation ArvosAugment

- (id)initWithDictionary:(NSDictionary*)inDictionary {
	self = [self init];
	if (self) {
		self.name	= inDictionary[ArvosKeyName];
		self.url	= inDictionary[ArvosKeyUrl];
		self.author	= inDictionary[ArvosKeyAuthor];
		self.description = inDictionary[ArvosKeyDescription];
		self.developerKey = inDictionary[ArvosKeyDeveloperKey];

        if ([inDictionary objectForKey:ArvosKeyLat] && [inDictionary objectForKey:ArvosKeyLon])
        {
            CLLocationCoordinate2D c = {
                .longitude = [inDictionary[ArvosKeyLon] doubleValue],
                .latitude = [inDictionary[ArvosKeyLat] doubleValue]
            };
            self.coordinate = c;
        }
	}
	return self;
}

- (id)init {
	self = [super init];
	if (self) {
        mInstance = [Arvos sharedInstance];
		mPois = [NSMutableArray array];
	}
	return self;
}

- (NSString*)parseFromData:(NSData*)data {
    
    NSError* error = nil;
    NSDictionary* jsonAugment = [NSJSONSerialization JSONObjectWithData:data
                                                                options:0
                                                                  error:&error];
    if (error != nil) {
        return [NSString stringWithFormat:@"Failed to parse JSON augment. %@", error.localizedDescription];
    }
       
    self.name	= jsonAugment[ArvosKeyName];
    self.author	= jsonAugment[ArvosKeyAuthor];
    self.description = jsonAugment[ArvosKeyDescription];
    
    NSArray* jsonPois = jsonAugment[ArvosKeyPois];
    
    if (jsonPois == nil || [jsonPois count] == 0)
    {
        return [@"No pois found in augment " stringByAppendingString:self.name];
    }
    
    for (NSDictionary* dictionary in jsonPois) {
        ArvosPoi* newPoi = [[ArvosPoi alloc] initWithAugment:self];
        NSString* result = [newPoi parseFromDictionary:dictionary];
        if (nil != result) {
            return result;
        }
        [mPois addObject:newPoi];
    }
    return nil;
}

- (NSString*)downloadTexturesSynchronously {

    for (ArvosPoi* poi in mPois) {
        for (ArvosPoiObject* poiObject in poi.poiObjects) {
            if (poiObject.image == nil && poiObject.textureUrl != nil) {
                poiObject.image = [self downloadTextureFromUrl:poiObject.textureUrl];
                if (poiObject.image == nil)
                {
                    return @"Failed to download texture.";
                }
                for (ArvosPoi* otherPoi in mPois) {
                    for (ArvosPoiObject* otherPoiObject in otherPoi.poiObjects) {
                        if (otherPoiObject.image == nil && [poiObject.textureUrl isEqualToString:otherPoiObject.textureUrl]) {
                            otherPoiObject.image = poiObject.image;
                        }
                    }
                }
            }
        }
    }
    return nil;
}

- (UIImage*)downloadTextureFromUrl:(NSString*)baseUrl {
           
	NSURL* url = [NSURL URLWithString:baseUrl];
    if (url != nil) {
        NSData *data = [NSData dataWithContentsOfURL:url];
        if (data != nil) {
            NBLog(@"Downloaded = %@", baseUrl);
            return [[UIImage alloc] initWithData:data];
        }
    }
	return nil;
}

- (CLLocationDegrees)longitude {
	return self.coordinate.longitude;
}

- (void)setLongitude:(CLLocationDegrees)longitude {
	CLLocationCoordinate2D c = self.coordinate;
	c.longitude = longitude;
	self.coordinate = c;
}

- (CLLocationDegrees)latitude {
	return self.coordinate.latitude;
}

- (void)setLatitude:(CLLocationDegrees)latitude {
	CLLocationCoordinate2D c = self.coordinate;
	c.latitude = latitude;
	self.coordinate = c;
}

- (void)getObjectsAtCurrentTime:(long)time
                    arrayToFill:(NSMutableArray*)resultObjects
                existingObjects:(NSMutableArray*)arvosObjects {
    for (ArvosPoi* poi in mPois) {
        
        [poi getObjectsAtCurrentTime:time arrayToFill:resultObjects existingObjects:arvosObjects];
    }
}

@end
