#import "AppDelegate.h"
#import "TouchBar.h"

static const NSTouchBarItemIdentifier kSiteIdentifier = @"mn.ian.Site";
static const NSTouchBarItemIdentifier kGlobeIdentifier = @"mn.ian.Globe";
static const NSTouchBarItemIdentifier kTextIdentifier = @"mn.ian.Text";
static const NSTouchBarItemIdentifier kGroupIdentifier = @"mn.ian.Group";

@interface AppDelegate () <NSTouchBarDelegate>

@property (weak) IBOutlet NSWindow *window;
@property (nonatomic) NSTouchBar *groupTouchBar;

@end

@implementation AppDelegate

- (NSTouchBar *)groupTouchBar
{
    if (!_groupTouchBar) {
        NSTouchBar *groupTouchBar = [[NSTouchBar alloc] init];
        groupTouchBar.defaultItemIdentifiers = @[ kSiteIdentifier, kTextIdentifier ];
        groupTouchBar.delegate = self;
        _groupTouchBar = groupTouchBar;
    }

    return _groupTouchBar;
}

- (void)nothing:(id)sender
{
}

- (void)present:(id)sender
{
    [NSTouchBar presentSystemModalFunctionBar:self.groupTouchBar
                     systemTrayItemIdentifier:kGlobeIdentifier];
}

- (NSString *)getStdIn {
    @autoreleasepool {
        return [[[NSString alloc] initWithData:[[NSFileHandle fileHandleWithStandardInput] availableData] encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    }
}

- (NSTouchBarItem *)touchBar:(NSTouchBar *)touchBar
       makeItemForIdentifier:(NSTouchBarItemIdentifier)identifier
{
    if ([identifier isEqualToString:kSiteIdentifier]) {
        NSCustomTouchBarItem *buttonitem = [[NSCustomTouchBarItem alloc] initWithIdentifier:kSiteIdentifier];
        NSButton *buttonview = [NSButton buttonWithTitle:@"►" target:self action:@selector(nothing:)];
        [buttonview setBezelColor:[NSColor redColor]];
        buttonitem.view = buttonview;
        return buttonitem;
    } else if ([identifier isEqualToString:kGlobeIdentifier]) {
        NSCustomTouchBarItem *globe = [[NSCustomTouchBarItem alloc] initWithIdentifier:kGlobeIdentifier];
        globe.view = [NSButton buttonWithTitle:@"\U0001F310" target:self action:@selector(nothing:)];
        return globe;
    } else if ([identifier isEqualToString:kTextIdentifier]) {
        NSCustomTouchBarItem *textitem = [[NSCustomTouchBarItem alloc] initWithIdentifier:kTextIdentifier];
        NSTextField *textfield = [NSTextField labelWithString:@""];
        [textfield setTextColor:[NSColor lightGrayColor]];
        textitem.view = textfield;
        return textitem;
    } else {
        return nil;
    }
}

- (void)processCommand:(NSString *)command {
    for (id itemid in self.groupTouchBar.itemIdentifiers) {
        NSString* identifier = [self.groupTouchBar itemForIdentifier:itemid].identifier;
        if ([identifier isEqualToString:kTextIdentifier]) {
            NSTextField* textfield = [self.groupTouchBar itemForIdentifier:itemid].view;
            [textfield setStringValue:command];
        }
    }
}

- (void)waitForCommands {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSString *input = [self getStdIn];
        NSRange needleRange = NSMakeRange(13, input.length - 15);
        NSString *text = [input substringWithRange:needleRange];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self processCommand:text];
            [self waitForCommands];
        });
    });
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    DFRSystemModalShowsCloseBoxWhenFrontMost(YES);

    NSCustomTouchBarItem *globe =
        [[NSCustomTouchBarItem alloc] initWithIdentifier:kGlobeIdentifier];
    globe.view = [NSButton buttonWithTitle:@"\U0001F310" target:self action:@selector(present:)];
    [NSTouchBarItem addSystemTrayItem:globe];
    DFRElementSetControlStripPresenceForIdentifier(kGlobeIdentifier, YES);
    
    [self waitForCommands];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
}

@end
