#import "Tweak.h"

BOOL enabled;
int width = 550;
int height = 550;
int scale;
int offset; //5000 normal
int delta; 
UIImage* currentwallpaper = nil;
BOOL lockscreenEnabled = YES;
BOOL homescreenEnabled = YES;
BOOL dimEnabled = YES;


UIImageView *wallpaperImageViewLS = nil;      //image view used for the lockscreen
UIImageView *wallpaperImageViewHS = nil;      //image view used for the homescreen

UIView* dimBlurViewLS = nil;                  //dimBlurViewLS is a combination of both the the dimViewLS and blurViewLS
UIView* dimViewLS = nil;                      //dim blur
UIVisualEffectView* blurViewLS = nil;         //blur view
UIBlurEffect* blurLS = nil;                   //blur effect to be used on blurViewLS


%hook SpringBoard
%new
-(void)timerFired{
    NSLog(@"updating wallpaper now");
    dispatch_queue_t queue =dispatch_queue_create("com.idkwhotomis.earthpaperobjc.updatewall", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        UIImage* image = getCurrentImage();
        if (image){// && screenon){
            currentwallpaper = image;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"com.idkwhotomis.earthpaperobjc.setwallpaper" object:nil];
                });
            [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(currentwallpaper) forKey:@"com.idkwhotomis.earthpaperobjc.wallpapercurrent"];
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:CFAbsoluteTimeGetCurrent()] forKey:@"com.idkwhotomis.earthpaperobjc.timeatlastupdate"];
        [[NSUserDefaults standardUserDefaults] synchronize];   
        });
    [NSTimer scheduledTimerWithTimeInterval:(float)delta target:self selector:@selector(timerFired) userInfo:nil repeats:NO];
}


-(void)applicationDidFinishLaunching:(id)arg1 {
    if (!enabled) return %orig;
    NSData *currentwallpaperdata = [[NSUserDefaults standardUserDefaults]  objectForKey:@"com.idkwhotomis.earthpaperobjc.wallpapercurrent"];
    if (currentwallpaperdata){
        currentwallpaper = [[UIImage alloc] initWithData:currentwallpaperdata];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.idkwhotomis.earthpaperobjc.setwallpaper" object:nil];
    }

    %orig;
    //[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"com.idkwhotomis.earthpaperobjc.timeatlastupdate"];
    [[NSUserDefaults standardUserDefaults] synchronize];   
    if ((![[NSUserDefaults standardUserDefaults] objectForKey:@"com.idkwhotomis.earthpaperobjc.timeatlastupdate"]) || 
            ((CFAbsoluteTimeGetCurrent()-((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"com.idkwhotomis.earthpaperobjc.timeatlastupdate"]).intValue) >= delta) || !(currentwallpaper)){
        [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(timerFired) userInfo:nil repeats:NO];
    }else{
        float time = (delta - (CFAbsoluteTimeGetCurrent()-((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"com.idkwhotomis.earthpaperobjc.timeatlastupdate"]).intValue));
        NSLog(@"updating in %f seconds", time);
        [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(timerFired) userInfo:nil repeats:NO];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"getDNDState" object:nil];
    
}
%end





static void loadPrefs() {
    NSMutableDictionary *preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.tmded.earthpaper.plist"];

    // TODO: Setup lockscreen/homescreen detection, maybe in the init args?

    enabled = [preferences objectForKey:@"enabled"] ? [[preferences objectForKey:@"enabled"] boolValue] : YES;
    scale = [preferences objectForKey:@"scale"] ? [[preferences objectForKey:@"scale"] intValue] : 4;
    offset = [preferences objectForKey:@"offset"] ? [[preferences objectForKey:@"scrollColorFromIcon"] intValue] : 16000;
    delta = [preferences objectForKey:@"delta"] ? [[preferences objectForKey:@"delta"] intValue] : 600;
}

%ctor{
    loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.tmded.earthpaper/saved"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}
