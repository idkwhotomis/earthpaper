#import "setWallpaper.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

typedef enum : NSInteger {
    SBFWallpaperOptionsModeLight,
    SBFWallpaperOptionsModeDark,
} SBFWallpaperOptionsMode;

@interface SBFWallpaperOptions : NSObject
@property (assign, nonatomic) NSInteger wallpaperMode;
@property (assign, nonatomic) double parallaxFactor;
@end

int SBSUIWallpaperSetImages(NSDictionary *imagesDict, NSDictionary *optionsDict, SBFWallpaperLocation location, UIUserInterfaceStyle interfaceStyle);

void setWallpaper(NSString *lightModeImagePath, NSString *darkModeImagePath, SBFWallpaperLocation location, BOOL usePerspectiveZoom) {
    UIImage *lightModeImage = [UIImage imageWithContentsOfFile:lightModeImagePath];
    UIImage *darkModeImage = [UIImage imageWithContentsOfFile:darkModeImagePath];

    SBFWallpaperOptions *lightModeOptions = [[objc_getClass("SBFWallpaperOptions") alloc] init];
    SBFWallpaperOptions *darkModeOptions = [[objc_getClass("SBFWallpaperOptions") alloc] init];

    lightModeOptions.wallpaperMode = SBFWallpaperOptionsModeLight;
    darkModeOptions.wallpaperMode = SBFWallpaperOptionsModeDark;
    if (!usePerspectiveZoom) {
        lightModeOptions.parallaxFactor = 0;
        darkModeOptions.parallaxFactor = 0;
    }

    NSDictionary *imagesDict = @{
        @"light":lightModeImage,
            @"dark":darkModeImage,
    };
    NSDictionary *optionsDict = @{
        @"light":lightModeOptions,
            @"dark":darkModeOptions,
    };

    SBSUIWallpaperSetImages(imagesDict, optionsDict, location, UIUserInterfaceStyleDark);
}
