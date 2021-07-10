
#import <stdio.h>
#import <string.h>
#import <dlfcn.h>
#import <objc/runtime.h>
#import "fetcher.h"
#import "setWallpaper.h"



@interface SBFStaticWallpaperImageView : UIImageView
@end


BOOL screenon = YES;
int delta = 600; 
UIImage* currentwallpaper = nil;


%hook SpringBoard
%new
-(void)timerFired{
    dispatch_queue_t queue =dispatch_queue_create("com.idkwhotomis.earthpaperobjc.updatewall", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        UIImage* image = getCurrentImage();
        if (image){// && screenon){

            //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            //NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Imageearthpaper.png"];
            //NSLog(@"%@",filePath);
            // Save image.
            //[UIImageJPEGRepresentation(image, 1.0) writeToFile:filePath atomically:YES];
            //for (int x = 0; x < 99; ++x){
            //setWallpaper(filePath, filePath, 3, false);
            //NSLog(@"here at %i",x);
            //}
            currentwallpaper = image;
            // TEMPORARILY COMMENTED OUT
            //if (currentwallpaper){
            //    [[NSUserDefaults standardUserDefaults] setObject:currentwallpaper forKey:@"com.idkwhotomis.earthpaperobjc.wallpapercurrent"];
            //}
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.idkwhotomis.earthpaperobjc.setwallpaper" object:nil];
        }
        //else if (image){
        //    NSLog(@"setting");
        //    currentwallpaper=image;
        //}
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:CFAbsoluteTimeGetCurrent()] forKey:@"com.idkwhotomis.earthpaperobjc.timeatlastupdate"];
        [[NSUserDefaults standardUserDefaults] synchronize];   
        });

    [NSTimer scheduledTimerWithTimeInterval:(float)delta target:self selector:@selector(timerFired) userInfo:nil repeats:NO];
}


-(void)applicationDidFinishLaunching:(id)arg1 {
    %orig;
    // TEMPORARY
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"com.idkwhotomis.earthpaperobjc.timeatlastupdate"];
    [[NSUserDefaults standardUserDefaults] synchronize];   
    if ((![[NSUserDefaults standardUserDefaults] objectForKey:@"com.idkwhotomis.earthpaperobjc.timeatlastupdate"]) || 
            (CFAbsoluteTimeGetCurrent()-((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"com.idkwhotomis.earthpaperobjc.timeatlastupdate"]).intValue) >= delta){
        [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(timerFired) userInfo:nil repeats:NO];
    }else{ 
        [NSTimer scheduledTimerWithTimeInterval:(float)delta target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
    }
}


%end

%hook SBFStaticWallpaperImageView
%new 
-(void) notificationFired{
    [self setImage:[UIImage imageNamed:@"1.png"]];
    NSLog(@"setit");
}

-(id)initWithImage:(id)arg1{
    id cachedimg = [[NSUserDefaults standardUserDefaults] objectForKey:@"com.idkwhotomis.earthpaperobjc.wallpapercurrent"];
    id x = nil;
    if (cachedimg) {x = %orig(cachedimg);}
    else {x = %orig;}
    [[NSNotificationCenter defaultCenter] addObserver:x selector:@selector(notificationFired) name:@"com.idkwhotomis.earthpaperobjc.setwallpaper" object:nil];
    return x;
}

-(void) setImage:(UIImage*)arg1{
    if (currentwallpaper) return %orig(currentwallpaper);
    else return %orig;
}

-(UIImage*)image{
    if (currentwallpaper){
        return currentwallpaper;
    }else return %orig;
}
%end

//%hook SBBacklightController
//-(void)setBacklightFactorPending:(float)arg1 {
//    %orig;
//    NSString *checkForLockString = [NSString stringWithFormat: @"%f", arg1];
//    
//    if (![checkForLockString containsString:@"1"]) { // screen has turned off 
//        screenon = NO;
//        NSLog(@"off");
//    } else {
//        NSLog(@"on");
//        screenon = YES;
//        if (currentwallpaper){
//            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//            NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Imageearthpaper.png"];
//            NSLog(@"%@",filePath);
//            // Save image.
//            [UIImageJPEGRepresentation(currentwallpaper, 1.0) writeToFile:filePath atomically:YES];
//            NSLog(@"here");
//
//            dispatch_queue_t queue =dispatch_queue_create("com.idkwhotomis.earthpaperobjc.updatewallwaking", DISPATCH_QUEUE_SERIAL);
//            dispatch_async(queue, ^{
//            setWallpaper(filePath, filePath, 3, false);
//            NSLog(@"here2");
//            currentwallpaper = nil;});
//        }
//    }
//}
//%end
