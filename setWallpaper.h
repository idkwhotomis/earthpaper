#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    SBFWallpaperLocationLockScreen,
    SBFWallpaperLocationHomeScreen,
    SBFWallpaperLocationBoth,
} SBFWallpaperLocation;

void setWallpaper(NSString *lightModeImagePath, NSString *darkModeImagePath, SBFWallpaperLocation location, BOOL usePerspectiveZoom);
