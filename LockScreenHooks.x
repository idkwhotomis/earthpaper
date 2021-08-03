#import "Tweak.h"

// CSScrollview - 6
// UIView - 5



@interface SBWallpaperViewController : UIViewController 

-(void)refreshWall;
@end

BOOL isDNDActive;

%hook CSCoverSheetViewController

- (void)viewDidLoad {

    %orig;

    /* dim and blur superview for when dim on dnd is enabled. 
       Because the CSCoverSheetViewController isn't affected by the system blur, this is a cheap way to simulate it
     */
    dimBlurViewLS = [[UIView alloc] initWithFrame:[[self view] bounds]];
    [dimBlurViewLS setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    if (![dimBlurViewLS isDescendantOfView:[self view]]) [[self view] insertSubview:dimBlurViewLS atIndex:1];
    // blur
    blurLS = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    blurViewLS = [[UIVisualEffectView alloc] initWithEffect:blurLS];
    [blurViewLS setFrame:[dimBlurViewLS bounds]];
    [blurViewLS setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [blurViewLS setClipsToBounds:YES];
    [blurViewLS setAlpha:0.9];
    if (![blurViewLS isDescendantOfView:dimBlurViewLS]) [dimBlurViewLS addSubview:blurViewLS];
    // dim
    dimViewLS = [[UIView alloc] initWithFrame:[[self view] bounds]];
    [dimViewLS setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [dimViewLS setBackgroundColor:[UIColor blackColor]];
    [dimViewLS setAlpha:0.7];
    if (![dimViewLS isDescendantOfView:dimBlurViewLS]) [dimBlurViewLS addSubview:dimViewLS];
    //gonna be honest everything above I ctrl c ctrl v directly from Litten's github because I'm too lazy to do it myself lol
    //but essentially it's dim and blur subviews put into one big view, or at least i think so

    //set image view to the dimensions of the entire phone screen
    wallpaperImageViewLS = [[UIImageView alloc] initWithFrame:[[self view] bounds]];

    //set properties so that the image isn't distorted when filling the entire view
    [wallpaperImageViewLS setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [wallpaperImageViewLS setContentMode:UIViewContentModeScaleAspectFill];
    [wallpaperImageViewLS setClipsToBounds:YES];

    //add the view to the actual screen
    [[self view] insertSubview:wallpaperImageViewLS atIndex:0];
    [self refreshWall];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshWall) 
                                                 name:@"com.idkwhotomis.earthpaperobjc.setwallpaper"
                                               object:nil];



}

//this method handles when the notification center is invoked on the homescreen, 
//because this view CSCoverSheetViewController is shown for both the lockscreen and notification center 
- (void)viewWillAppear:(BOOL)animated {

    %orig;
    if (currentwallpaper) {	//if the cache image has an image linked to it
        [wallpaperImageViewLS setImage:currentwallpaper];
    } else { //if it doesn't, set image view to nothing
        [wallpaperImageViewLS setImage:nil];
    }
}

%new
-(void)refreshWall{
    if (currentwallpaper) {	//if the cache image has an image linked to it 
        [wallpaperImageViewLS setImage:currentwallpaper];
    } else { //if it doesn't, set image view to nothing
        [wallpaperImageViewLS setImage:nil];
    }
}
%end

//detect when Do Not Disturb is active
//thank you Arya_06 for pointing this small setting out, never knew that this dimming option existed natively for normal homescreen
%hook DNDState

- (id)initWithCoder:(id)arg1 {

    /*as how Litten put it: removeObserver removes all observers, also the ones from other tweaks, so be careful when to use it*/
    [[NSNotificationCenter defaultCenter] removeObserver:self]; 

    //catch the notification titled "getDNDState" and run the isActive method
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isActive) name:@"getDNDState" object:nil];

    return %orig;

}

//because this method isn't run immediately after respring, the state of DND isn't refreshed and sometimes the dnd blur view  will still exist
//the notification observer explanation above is essential to prevent this issue from occurring.
- (BOOL) isActive {

    isDNDActive = %orig;

    if (isDNDActive && dimEnabled) {
        dispatch_async(dispatch_get_main_queue(), ^{

                //show dim blur view if dnd is active
                [dimBlurViewLS setHidden:NO];
                });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{

                //hide dim blur view if dnd is active 
                [dimBlurViewLS setHidden:YES];
                });
    }

    return isDNDActive;
} 

%end
