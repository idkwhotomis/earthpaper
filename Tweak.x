
#import <stdio.h>
#import <string.h>
#import <dlfcn.h>
#import <objc/runtime.h>
#import "fetcher.h"
#import "setWallpaper.h"
#import "Tweak.h"

BOOL enabled;
int width = 550;
int height = 550;
int scale;
int offset; //5000 normal
int delta; 
UIImage* currentwallpaper = nil;


@interface SBFWallpaperView : UIView
@property (nonatomic,readonly) UIImage * wallpaperImage;
@property (nonatomic,retain) UIImage * untreatedWallpaperImage;   
@property (nonatomic,retain) UIView * contentView;//@synthesize untreatedWallpaperImage=_untreatedWallpaperImage - In the implementation block
@end

CGRect getFrameSize(){ 
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    if (screenHeight<screenWidth){
        // swap values
        NSLog(@"swapping height, width");
        screenWidth = screenWidth + screenHeight; // 1+2 =3
        screenHeight = screenWidth - screenHeight; // 3 -2 = 1
        screenWidth = screenWidth - screenHeight; // 3-1 = 2;
    }
    return CGRectMake(0, 0, screenWidth, screenHeight);
}


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
    %orig;
    if (!enabled) return;
    NSData *currentwallpaperdata = [[NSUserDefaults standardUserDefaults]  objectForKey:@"com.idkwhotomis.earthpaperobjc.wallpapercurrent"];
    if (currentwallpaperdata){
        currentwallpaper = [[UIImage alloc] initWithData:currentwallpaperdata];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.idkwhotomis.earthpaperobjc.setwallpaper" object:nil];
    }
    //[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"com.idkwhotomis.earthpaperobjc.timeatlastupdate"];
    [[NSUserDefaults standardUserDefaults] synchronize];   
    if ((![[NSUserDefaults standardUserDefaults] objectForKey:@"com.idkwhotomis.earthpaperobjc.timeatlastupdate"]) || 
            ((CFAbsoluteTimeGetCurrent()-((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"com.idkwhotomis.earthpaperobjc.timeatlastupdate"]).intValue) >= delta) || !(currentwallpaper)){
        [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(timerFired) userInfo:nil repeats:NO];
    }else{
        float time = (delta - (CFAbsoluteTimeGetCurrent()-((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"com.idkwhotomis.earthpaperobjc.timeatlastupdate"]).intValue));
        NSLog(@"updating in %f seconds", time);
        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timerFired) userInfo:nil repeats:NO];
    }
    
}


%end



%hook SBFWallpaperView
- (void)insertSubview:(UIImageView *)arg1 atIndex:(NSInteger)index{
    if ([arg1 isKindOfClass:[UIImageView class]] && enabled){
        [[NSNotificationCenter defaultCenter] addObserver:arg1 selector:@selector(updateimage) name:@"com.idkwhotomis.earthpaperobjc.setwallpaper" object:nil]; 
        if (currentwallpaper){
            arg1.frame = getFrameSize();
            arg1.image = currentwallpaper;
        }
        %orig;
    }
    else %orig;
}

-(void)addSubview:(UIImageView *)arg1{
    if ([arg1 isKindOfClass:[UIImageView class]] && enabled){
        [[NSNotificationCenter defaultCenter] addObserver:arg1 selector:@selector(updateimage) name:@"com.idkwhotomis.earthpaperobjc.setwallpaper" object:nil]; 
        if (currentwallpaper) {
            arg1.frame = getFrameSize();
            arg1.image = currentwallpaper;
        }
        %orig;
    }
    else %orig;
}
%end

%hook UIImageView
%new
-(void) updateimage{
    if (currentwallpaper && enabled){
        self.frame = getFrameSize();
        self.image = currentwallpaper;
    }
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
