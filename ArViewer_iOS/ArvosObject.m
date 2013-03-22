/*
 * ArvosObject.m - ArViewer_iOS
 *
 * Copyright (C) 2013, Peter Graf, Ulrich Zurucker
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
 * For more information on the AR Viewer Open Source
 * please see: http://www.arvos-app.com/.
 */

#import "ArvosObject.h"
#import "Arvos.h"

@interface ArvosObject () {    
    GLfloat mPosition[3];
	GLfloat mScale[3];
	GLfloat mRotation[4];
}
@end

@implementation ArvosObject

- (id)init {
    NSAssert(NO, @"ArvosObject must not be initialzed without id");
    return nil;
}

-(id)initWithId:(int)idParameter {
    self = [super init];
	if (self) {
        self.id = idParameter;
	}
	return self;
}

- (GLfloat*)getPosition{ return mPosition; }
- (GLfloat*)getScale{ return mScale; }
- (GLfloat*)getRotation{ return mRotation; }

- (void)draw {
    if (!self.textureLoaded) {
        [self loadGlTexture:self.image];
    }

    glTranslatef(0.0, 0, -5.0);
    
    [super draw];
}

@end
