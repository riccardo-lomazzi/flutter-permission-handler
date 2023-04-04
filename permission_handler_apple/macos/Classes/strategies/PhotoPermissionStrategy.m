//
// Created by Razvan Lung(long1eu) on 2019-02-15.
// Copyright (c) 2019 The Chromium Authors. All rights reserved.
//

#import "PhotoPermissionStrategy.h"

#if PERMISSION_PHOTOS

@implementation PhotoPermissionStrategy{
    bool addOnlyAccessLevel;
}

- (instancetype)initWithAccessAddOnly:(BOOL)addOnly {
    self = [super init];
    if(self) {
        addOnlyAccessLevel = addOnly;
    }
    
    return self;
}

- (PermissionStatus)checkPermissionStatus:(PermissionGroup)permission {
    return [PhotoPermissionStrategy permissionStatus:addOnlyAccessLevel];
}

- (ServiceStatus)checkServiceStatus:(PermissionGroup)permission {
    return ServiceStatusNotApplicable;
}

- (void)requestPermission:(PermissionGroup)permission completionHandler:(PermissionStatusHandler)completionHandler {
    PermissionStatus status = [self checkPermissionStatus:permission];

    if (status != PermissionStatusDenied) {
        completionHandler(status);
        return;
    }

    if(@available(macOS 11.0, *)) {
        [PHPhotoLibrary requestAuthorizationForAccessLevel:(addOnlyAccessLevel)?PHAccessLevelAddOnly:PHAccessLevelReadWrite handler:^(PHAuthorizationStatus authorizationStatus) {
            completionHandler([PhotoPermissionStrategy determinePermissionStatus:authorizationStatus]);
        }];
    }else {
        completionHandler(PermissionStatusPermanentlyDenied);
    }
}

+ (PermissionStatus)permissionStatus:(BOOL) addOnlyAccessLevel {
    
    if(@available(macOS 11.0, *)){
        PHAuthorizationStatus status;
        status = [PHPhotoLibrary authorizationStatusForAccessLevel:(addOnlyAccessLevel)?PHAccessLevelAddOnly:PHAccessLevelReadWrite];
        return [PhotoPermissionStrategy determinePermissionStatus:status];
    } else {
        return PermissionStatusDenied;
    }

}

+ (PermissionStatus)determinePermissionStatus:(PHAuthorizationStatus)authorizationStatus  API_AVAILABLE(macos(10.13)){
    switch (authorizationStatus) {
        case PHAuthorizationStatusNotDetermined:
            return PermissionStatusDenied;
        case PHAuthorizationStatusRestricted:
            return PermissionStatusRestricted;
        case PHAuthorizationStatusDenied:
            return PermissionStatusPermanentlyDenied;
        case PHAuthorizationStatusAuthorized:
            return PermissionStatusGranted;
        case PHAuthorizationStatusLimited:
            return PermissionStatusLimited;
    }

    return PermissionStatusDenied;
}

@end

#else

@implementation PhotoPermissionStrategy
@end

#endif