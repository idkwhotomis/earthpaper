#import <stdio.h>
#import <string.h>
#import <dlfcn.h>
#import <objc/runtime.h>
#import "fetcher.h"


extern int width;
extern int height;
extern int scale;
extern int offset;
extern BOOL enabled;
@interface CSCoverSheetViewController : UIViewController 
-(void)refreshWall;
@end

@interface SBDashBoardViewController : UIViewController 

@end

@interface SBIconController : UIViewController
-(void)refreshWall;
@end

@interface DNDState : UIViewController

@end

@interface SBLockScreenManager

@end


extern UIImage *currentwallpaper;                         //image that changes depending on the situation that is later used by the lockscreen and homescreen image views

extern BOOL lockscreenEnabled;                 //if lockscreen wallpaper is enabled
extern BOOL homescreenEnabled;                 //if homescreen wallpaper is enabled
extern BOOL dimEnabled;                        //if dim wallpapers on dnd is enabled

 
extern UIImageView *wallpaperImageViewLS;      //image view used for the lockscreen
extern UIImageView *wallpaperImageViewHS;      //image view used for the homescreen

extern UIView* dimBlurViewLS;                  //dimBlurViewLS is a combination of both the the dimViewLS and blurViewLS
extern UIView* dimViewLS;                      //dim blur
extern UIVisualEffectView* blurViewLS;         //blur view
extern UIBlurEffect* blurLS;                   //blur effect to be used on blurViewLS
