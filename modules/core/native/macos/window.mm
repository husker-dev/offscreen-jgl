#import "grapl-macos.h"


static JNIEnv* env;


/* ====================
      App delegate
   ==================== */
@interface GraplAppDelegate : NSObject <NSApplicationDelegate>{
    id themeObserver;
@public
    int theme;
}
-(BOOL) applicationSupportsSecureRestorableState:(NSApplication*)app;
-(void) updateTheme;
@end

GraplAppDelegate* appDelegate;

@implementation GraplAppDelegate : NSObject
- (instancetype)init {
    self = [super init];

    self->theme = 1;
    id notificationCenter = NSDistributedNotificationCenter.defaultCenter;
    themeObserver = [notificationCenter addObserverForName:@"AppleInterfaceThemeChangedNotification"
                                                    object:nil
                                                     queue:nil
                                                usingBlock:^(NSNotification *) {
                                                    [self updateTheme];
                                                }];
    [self updateTheme];
    return self;
}
-(void) dealloc {
    [super dealloc];
    [NSDistributedNotificationCenter.defaultCenter removeObserver:themeObserver];
}


-(BOOL) applicationSupportsSecureRestorableState:(NSApplication*)app{
    return YES;
}

-(void) updateTheme {
    NSAppearance *appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];

    if(self->theme == 0){
        NSString* style = [[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"];
        if(style != 0)
            appearance = [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
    } else if(self->theme == 2)
        appearance = [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];

    [NSApp setAppearance:appearance];
}
@end

/* ====================
    Callback container
   ==================== */
class MacWindowCallbackContainer: public WindowCallbackContainer {
public:
    MacWindowCallbackContainer(JNIEnv* env, jobject callbackObject): WindowCallbackContainer(env, callbackObject) {

    }
};


/* ====================
           View
   ==================== */
@interface View : NSView <NSWindowDelegate> {
    MacWindowCallbackContainer* callbacks;

    float sumScale;
    float sumRotation;

    @public
    NSCursor* cursor;
    NSTrackingArea* trackingArea;
    BOOL disabled;
}
- (instancetype)initWithRect:(NSRect)rect;
@end

@implementation View
- (instancetype)initWithRect:(NSRect)rect {
    self = [super initWithFrame:rect];

    self->cursor = [NSCursor arrowCursor];
    [self updateTrackingAreas];
    return self;
}

-(void) bindCallback:(jobject)_callbackObject {
    callbacks = new MacWindowCallbackContainer(env, _callbackObject);
}
-(void) dealloc {
    [super dealloc];
    delete callbacks;
}

-(jint) getModifierKeys {
    jint result = 0;
    NSEventModifierFlags flags = NSEvent.modifierFlags;
    if(NSEventModifierFlagOption & flags)  result |= 1;
    if(NSEventModifierFlagControl & flags) result |= 2;
    if(NSEventModifierFlagShift & flags)   result |= 4;
    if(NSEventModifierFlagCommand & flags) result |= 8;
    return result;
}
-(NSUInteger) translateKeyToModifierFlag:(int)key {
    switch (key) {
        case kVK_Shift:
        case kVK_RightShift:
            return NSEventModifierFlagShift;
        case kVK_Control:
        case kVK_RightControl:
            return NSEventModifierFlagControl;
        case kVK_Option:
        case kVK_RightOption:
            return NSEventModifierFlagOption;
        case kVK_Command:
        case kVK_RightCommand:
            return NSEventModifierFlagCommand;
        case kVK_CapsLock:
            return NSEventModifierFlagCapsLock;
    }
    return 0;
}

-(jint) translateKey:(int)key {
    switch(key){
        case kVK_Space:             return GRAPL_VK_SPACE;
        case kVK_ANSI_Quote:        return GRAPL_VK_APOSTROPHE;
        case kVK_ANSI_Comma:        return GRAPL_VK_COMMA;
        case kVK_ANSI_Minus:        return GRAPL_VK_MINUS;
        case kVK_ANSI_Period:       return GRAPL_VK_PERIOD;
        case kVK_ANSI_Slash:        return GRAPL_VK_SLASH;

        case kVK_ANSI_0:            return GRAPL_VK_0;
        case kVK_ANSI_1:            return GRAPL_VK_1;
        case kVK_ANSI_2:            return GRAPL_VK_2;
        case kVK_ANSI_3:            return GRAPL_VK_3;
        case kVK_ANSI_4:            return GRAPL_VK_4;
        case kVK_ANSI_5:            return GRAPL_VK_5;
        case kVK_ANSI_6:            return GRAPL_VK_6;
        case kVK_ANSI_7:            return GRAPL_VK_7;
        case kVK_ANSI_8:            return GRAPL_VK_8;
        case kVK_ANSI_9:            return GRAPL_VK_9;

        case kVK_ANSI_Semicolon:    return GRAPL_VK_SEMICOLON;
        case kVK_ANSI_Equal:        return GRAPL_VK_EQUAL;

        case kVK_ANSI_A:            return GRAPL_VK_A;
        case kVK_ANSI_B:            return GRAPL_VK_B;
        case kVK_ANSI_C:            return GRAPL_VK_C;
        case kVK_ANSI_D:            return GRAPL_VK_D;
        case kVK_ANSI_E:            return GRAPL_VK_E;
        case kVK_ANSI_F:            return GRAPL_VK_F;
        case kVK_ANSI_G:            return GRAPL_VK_G;
        case kVK_ANSI_H:            return GRAPL_VK_H;
        case kVK_ANSI_I:            return GRAPL_VK_I;
        case kVK_ANSI_J:            return GRAPL_VK_J;
        case kVK_ANSI_K:            return GRAPL_VK_K;
        case kVK_ANSI_L:            return GRAPL_VK_L;
        case kVK_ANSI_M:            return GRAPL_VK_M;
        case kVK_ANSI_N:            return GRAPL_VK_N;
        case kVK_ANSI_O:            return GRAPL_VK_O;
        case kVK_ANSI_P:            return GRAPL_VK_P;
        case kVK_ANSI_Q:            return GRAPL_VK_Q;
        case kVK_ANSI_R:            return GRAPL_VK_R;
        case kVK_ANSI_S:            return GRAPL_VK_S;
        case kVK_ANSI_T:            return GRAPL_VK_T;
        case kVK_ANSI_U:            return GRAPL_VK_U;
        case kVK_ANSI_V:            return GRAPL_VK_V;
        case kVK_ANSI_W:            return GRAPL_VK_W;
        case kVK_ANSI_X:            return GRAPL_VK_X;
        case kVK_ANSI_Y:            return GRAPL_VK_Y;
        case kVK_ANSI_Z:            return GRAPL_VK_Z;

        case kVK_ANSI_LeftBracket:  return GRAPL_VK_LEFT_BRACKET;
        case kVK_ANSI_Backslash:    return GRAPL_VK_BACKSLASH;
        case kVK_ANSI_RightBracket: return GRAPL_VK_RIGHT_BRACKET;
        case kVK_ANSI_Grave:        return GRAPL_VK_GRAVE_ACCENT;
        case kVK_Escape:            return GRAPL_VK_ESCAPE;
        case kVK_Return:            return GRAPL_VK_ENTER;
        case kVK_Tab:               return GRAPL_VK_TAB;
        case kVK_Delete:            return GRAPL_VK_BACKSPACE;
        case kVK_ForwardDelete:     return GRAPL_VK_DELETE;

        case kVK_RightArrow:        return GRAPL_VK_RIGHT;
        case kVK_LeftArrow:         return GRAPL_VK_LEFT;
        case kVK_DownArrow:         return GRAPL_VK_DOWN;
        case kVK_UpArrow:           return GRAPL_VK_UP;

        case kVK_PageUp:            return GRAPL_VK_PAGE_UP;
        case kVK_PageDown:          return GRAPL_VK_PAGE_DOWN;
        case kVK_Home:              return GRAPL_VK_HOME;
        case kVK_End:               return GRAPL_VK_END;
        case kVK_CapsLock:          return GRAPL_VK_CAPS_LOCK;

        case kVK_F1:                return GRAPL_VK_F1;
        case kVK_F2:                return GRAPL_VK_F2;
        case kVK_F3:                return GRAPL_VK_F3;
        case kVK_F4:                return GRAPL_VK_F4;
        case kVK_F5:                return GRAPL_VK_F5;
        case kVK_F6:                return GRAPL_VK_F6;
        case kVK_F7:                return GRAPL_VK_F7;
        case kVK_F8:                return GRAPL_VK_F8;
        case kVK_F9:                return GRAPL_VK_F9;
        case kVK_F10:               return GRAPL_VK_F10;
        case kVK_F11:               return GRAPL_VK_F11;
        case kVK_F12:               return GRAPL_VK_F12;
        case kVK_F13:               return GRAPL_VK_F13;
        case kVK_F14:               return GRAPL_VK_F14;
        case kVK_F15:               return GRAPL_VK_F15;
        case kVK_F16:               return GRAPL_VK_F16;
        case kVK_F17:               return GRAPL_VK_F17;
        case kVK_F18:               return GRAPL_VK_F18;
        case kVK_F19:               return GRAPL_VK_F19;
        case kVK_F20:               return GRAPL_VK_F20;

        case kVK_ANSI_Keypad0:      return GRAPL_VK_KP_0;
        case kVK_ANSI_Keypad1:      return GRAPL_VK_KP_1;
        case kVK_ANSI_Keypad2:      return GRAPL_VK_KP_2;
        case kVK_ANSI_Keypad3:      return GRAPL_VK_KP_3;
        case kVK_ANSI_Keypad4:      return GRAPL_VK_KP_4;
        case kVK_ANSI_Keypad5:      return GRAPL_VK_KP_5;
        case kVK_ANSI_Keypad6:      return GRAPL_VK_KP_6;
        case kVK_ANSI_Keypad7:      return GRAPL_VK_KP_7;
        case kVK_ANSI_Keypad8:      return GRAPL_VK_KP_8;
        case kVK_ANSI_Keypad9:      return GRAPL_VK_KP_9;
        case kVK_ANSI_KeypadDecimal:  return GRAPL_VK_KP_DECIMAL;
        case kVK_ANSI_KeypadDivide:   return GRAPL_VK_KP_DIVIDE;
        case kVK_ANSI_KeypadMultiply: return GRAPL_VK_KP_MULTIPLY;
        case kVK_ANSI_KeypadMinus:    return GRAPL_VK_KP_SUBTRACT;
        case kVK_ANSI_KeypadPlus:     return GRAPL_VK_KP_ADD;
        case kVK_ANSI_KeypadEnter:    return GRAPL_VK_KP_ENTER;
        case kVK_ANSI_KeypadEquals:   return GRAPL_VK_KP_EQUAL;

        case kVK_Shift:             return GRAPL_VK_LEFT_SHIFT;
        case kVK_Control:           return GRAPL_VK_LEFT_CONTROL;
        case kVK_Option:            return GRAPL_VK_LEFT_ALT;
        case kVK_RightShift:        return GRAPL_VK_RIGHT_SHIFT;
        case kVK_RightControl:      return GRAPL_VK_RIGHT_CONTROL;
        case kVK_RightOption:       return GRAPL_VK_RIGHT_ALT;

        case kVK_Command:           return GRAPL_VK_LEFT_COMMAND;
        case kVK_RightCommand:      return GRAPL_VK_RIGHT_COMMAND;
    }
    return GRAPL_VK_UNKNOWN;
}

/* ====================
      Window events
   ==================== */

-(void) windowWillClose:(NSNotification*)notification {
    callbacks->onCloseCallback->call();
}

-(void) windowDidResize:(NSNotification*)notification {
    NSSize size = [self convertSizeToBacking:[self window].contentView.frame.size];
	callbacks->onResizeCallback->call((jint)size.width, (jint)size.height);
}

-(void) windowDidMove:(NSNotification*)notification {
    NSPoint origin = [self convertPointToBacking:[self window].frame.origin];
	callbacks->onMoveCallback->call((jint)origin.x, (jint)origin.y);
}

-(void) windowDidChangeBackingProperties:(NSNotification*)notification {
	callbacks->onDpiChanged->call();
}


/* ====================
       Mouse events
   ==================== */

-(void) sendMouseEvent:(NSEvent*)event callback:(Callback*)callback {
    if(disabled) return;
    const NSPoint pos = [self convertPointToBacking:[event locationInWindow]];
    const NSSize size = [self convertSizeToBacking:[self window].contentView.frame.size];
    callback->call(0, (jint)pos.x, (jint)(size.height - pos.y), [self getModifierKeys]);
}

-(void) sendMouseButtonEvent:(NSEvent*)event callback:(Callback*)callback button:(int)button {
    if(disabled) return;
    const NSPoint pos = [self convertPointToBacking:[event locationInWindow]];
    const NSSize size = [self convertSizeToBacking:[self window].contentView.frame.size];
    callback->call(event.pointingDeviceID, (jint)pos.x, (jint)(size.height - pos.y), button, [self getModifierKeys]);
}

-(void) mouseEntered:(NSEvent*)event {
    [self sendMouseEvent:event callback:callbacks->onPointerEnterCallback];
    [self->cursor set];
}

-(void) mouseMoved:(NSEvent*)event {
    [self sendMouseEvent:event callback:callbacks->onPointerMoveCallback];
    [self->cursor set];
}

-(void) mouseExited:(NSEvent*)event {
    if(disabled) return;
    callbacks->onPointerLeaveCallback->call(0, 0, 0, [self getModifierKeys]);
    [[NSCursor arrowCursor] set];
}

// Left button
-(void) mouseDown:(NSEvent*)event{
    [self sendMouseButtonEvent:event callback:callbacks->onPointerDownCallback button:1];
    [self->cursor set];
}

-(void) mouseDragged:(NSEvent*)event{
    [self sendMouseEvent:event callback:callbacks->onPointerMoveCallback];
    [self->cursor set];
}

-(void) mouseUp:(NSEvent*)event{
    [self sendMouseButtonEvent:event callback:callbacks->onPointerUpCallback button:1];
    [self->cursor set];
}

// Right button
-(void) rightMouseDown:(NSEvent*)event{
    [self sendMouseButtonEvent:event callback:callbacks->onPointerDownCallback button:3];
    [self->cursor set];
}

-(void) rightMouseDragged:(NSEvent*)event{
    [self sendMouseEvent:event callback:callbacks->onPointerMoveCallback];
    [self->cursor set];
}

-(void) rightMouseUp:(NSEvent*)event{
    [self sendMouseButtonEvent:event callback:callbacks->onPointerUpCallback button:3];
    [self->cursor set];
}

// Other button
-(void) otherMouseDown:(NSEvent*)event{
    [self sendMouseButtonEvent:event callback:callbacks->onPointerDownCallback button:(int)[event buttonNumber]+1];
    [self->cursor set];
}

-(void) otherMouseDragged:(NSEvent*)event{
    [self sendMouseEvent:event callback:callbacks->onPointerMoveCallback];
    [self->cursor set];
}

-(void) otherMouseUp:(NSEvent*)event{
    [self sendMouseButtonEvent:event callback:callbacks->onPointerUpCallback button:(int)[event buttonNumber]+1];
    [self->cursor set];
}

// Gestures
- (void) magnifyWithEvent:(NSEvent *)event {
    const NSPoint pos = [self convertPointToBacking:[event locationInWindow]];
    const NSSize size = [self convertSizeToBacking:[self window].contentView.frame.size];
    if ([event phase] == NSEventPhaseBegan){
        sumScale = 1;
        [self sendMouseEvent:event callback:callbacks->onPointerZoomBeginCallback];
    }
    sumScale += [event magnification];
    callbacks->onPointerZoomCallback->call(
            0,
            (jint)pos.x,
            (jint)(size.height - pos.y),
            (jdouble)sumScale,
            [self getModifierKeys]);
    if ([event phase] == NSEventPhaseEnded)
        [self sendMouseEvent:event callback:callbacks->onPointerZoomEndCallback];
}

- (void) rotateWithEvent:(NSEvent *)event {
    const NSPoint pos = [self convertPointToBacking:[event locationInWindow]];
    const NSSize size = [self convertSizeToBacking:[self window].contentView.frame.size];
    if ([event phase] == NSEventPhaseBegan){
        sumRotation = 0;
        [self sendMouseEvent:event callback:callbacks->onPointerRotationBeginCallback];
    }
    sumRotation += [event rotation];
    callbacks->onPointerRotationCallback->call(
            0,
            (jint)pos.x,
            (jint)(size.height - pos.y),
            (jdouble)sumRotation,
            [self getModifierKeys]);
    if ([event phase] == NSEventPhaseEnded)
        [self sendMouseEvent:event callback:callbacks->onPointerRotationEndCallback];
}

- (void) scrollWheel:(NSEvent *)event {
    if(disabled) return;
    const NSPoint pos = [self convertPointToBacking:[event locationInWindow]];
    const NSSize size = [self convertSizeToBacking:[self window].contentView.frame.size];
    callbacks->onPointerScrollCallback->call(
            0,
            (jint)pos.x,
            (jint)(size.height - pos.y),
            (jdouble)[event deltaX] * 6,
            (jdouble)[event deltaY] * 6,
            [self getModifierKeys]);
}

/* ====================
          Cursor
   ==================== */

-(BOOL) acceptsFirstResponder{
    return YES;
}

-(BOOL) wantsUpdateLayer{
    return YES;
}

-(BOOL) acceptsFirstMouse:(NSEvent*)event{
    return YES;
}

-(void) cursorUpdate:(NSEvent*)event{
    if(self->cursor != nil)
        [self->cursor set];
    else
        [[NSCursor arrowCursor] set];
}

-(void) updateTrackingAreas{
    if (trackingArea != nil) {
        [self removeTrackingArea:trackingArea];
        [trackingArea release];
    }

    const NSTrackingAreaOptions options = NSTrackingMouseEnteredAndExited |
                                          NSTrackingActiveInKeyWindow |
                                          NSTrackingEnabledDuringMouseDrag |
                                          NSTrackingCursorUpdate |
                                          NSTrackingInVisibleRect |
                                          NSTrackingAssumeInside;

    trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                options:options
                                                  owner:self
                                               userInfo:nil];

    [self addTrackingArea:trackingArea];
    [super updateTrackingAreas];
}

/* ====================
          Keyboard
   ==================== */

-(void) keyDown:(NSEvent*)event{
    if(disabled) return;
    callbacks->onKeyDownCallback->call(
        [self translateKey:event.keyCode],
        event.keyCode,
        toJString(env, event.characters),
        [self getModifierKeys]
    );
}

- (void)flagsChanged:(NSEvent*)event{
    if(disabled) return;
    const NSUInteger key = [self translateKeyToModifierFlag:event.keyCode];
    const unsigned int modifierFlags = [event modifierFlags] & NSEventModifierFlagDeviceIndependentFlagsMask;

    if(key & modifierFlags)
        callbacks->onKeyDownCallback->call(
            [self translateKey:event.keyCode],
            event.keyCode,
            0,
            [self getModifierKeys]
        );
    else
        callbacks->onKeyUpCallback->call(
            [self translateKey:event.keyCode],
            event.keyCode,
            0,
            [self getModifierKeys]
        );
}

-(void) keyUp:(NSEvent*)event{
    if(disabled) return;
    callbacks->onKeyUpCallback->call(
        [self translateKey:event.keyCode],
        event.keyCode,
        toJString(env, event.characters),
        [self getModifierKeys]
    );
}
@end

jni_macos_window(void, nInitApplication)(JNIEnv* _env, jobject) {
    JavaVM* jvm;
    _env->GetJavaVM(&jvm);

    ON_MAIN_THREAD(
        jvm->AttachCurrentThreadAsDaemon((void**)&env, NULL);

        [NSApplication sharedApplication];
        [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];

        appDelegate = [[GraplAppDelegate alloc] init];
        if (![NSApp delegate])
            [(NSApplication *)NSApp setDelegate:appDelegate];
    );
}

jni_macos_platform(void, nSetTheme)(JNIEnv* _env, jobject, jint theme) {
    appDelegate->theme = theme;
    [appDelegate updateTheme];
}

jni_macos_window(jlong, nCreateWindow)(JNIEnv* env, jobject, jobject callbackObject) {
    __block NSWindow* window = nil;

    ON_MAIN_THREAD(
        NSRect windowRect = NSMakeRect(0, 0, 100, 100);

        window = [[NSWindow alloc] initWithContentRect:windowRect
                                                       styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable | NSWindowStyleMaskMiniaturizable
                                                         backing:NSBackingStoreBuffered
                                                           defer:NO];

        NSWindowController* windowController = [[NSWindowController alloc] initWithWindow:window];
        [windowController autorelease];

        [window setCollectionBehavior: NSWindowCollectionBehaviorFullScreenPrimary | NSWindowCollectionBehaviorManaged];

        [window setAcceptsMouseMovedEvents:YES];
        [window setRestorable:NO];
        [window setReleasedWhenClosed: NO];

        View* view = [[[View alloc] initWithRect:windowRect] autorelease];
        [view bindCallback:callbackObject];
        [window setContentView:view];
        [window setDelegate:view];
        [window makeFirstResponder:view];
    );
    return (jlong)window;
}


jni_macos_window(void, nCloseWindow)(JNIEnv* env, jobject, jlong _windowPtr) {
    ON_MAIN_THREAD(
        NSWindow* window = (NSWindow*)_windowPtr;
        [window close];
    );
}

jni_macos_window(void, nSetVisible)(JNIEnv* env, jobject, jlong _windowPtr, jboolean visible) {
    ON_MAIN_THREAD(
        NSWindow* window = (NSWindow*)_windowPtr;
        if(visible)
            [window orderFrontRegardless];
        else
            [window orderOut:nil];
    );
}

jni_macos_window(void, nSetTitle)(JNIEnv* env, jobject, jlong _windowPtr, jobject _title) {
    char* title = (char*)env->GetDirectBufferAddress(_title);
    ON_MAIN_THREAD(
        NSWindow* window = (NSWindow*)_windowPtr;
        NSString* string = @(title);
        [window setTitle:string];
        [window setMiniwindowTitle:string];
    );
}

jni_macos_window(void, nSetPosition)(JNIEnv* env, jobject, jlong _windowPtr, jdouble x, jdouble y) {
    ON_MAIN_THREAD(
        NSWindow* window = (NSWindow*)_windowPtr;
        NSPoint origin = [window.contentView convertPointFromBacking:(NSPoint){ x, y }];
        [window setFrameOrigin:origin];
    );
}

jni_macos_window(void, nSetFocused)(JNIEnv* env, jobject, jlong _windowPtr) {
    ON_MAIN_THREAD(
        NSWindow* window = (NSWindow*)_windowPtr;
        [window orderFrontRegardless];
    );
}

jni_macos_window(void, nSetSize)(JNIEnv* env, jobject, jlong _windowPtr, jdouble width, jdouble height) {
    ON_MAIN_THREAD(
        NSWindow* window = (NSWindow*)_windowPtr;

        NSSize newSize = [window.contentView convertSizeFromBacking:NSMakeSize(width, height)];

        NSRect contentRect = [window contentRectForFrameRect:[window frame]];
        contentRect.origin.y += contentRect.size.height - newSize.height;
        contentRect.size = newSize;

        [window setFrame:[window frameRectForContentRect:contentRect] display:YES animate:YES];
    );
}

jni_macos_window(void, nSetMinSize)(JNIEnv* env, jobject, jlong _windowPtr, jint width, jint height) {
    ON_MAIN_THREAD(
        NSWindow* window = (NSWindow*)_windowPtr;
        [window setMinSize:NSMakeSize(width, height)];
    );
}

jni_macos_window(void, nSetMaxSize)(JNIEnv* env, jobject, jlong _windowPtr, jint width, jint height) {
    ON_MAIN_THREAD(
        NSWindow* window = (NSWindow*)_windowPtr;
        [window setMaxSize:NSMakeSize(width, height)];
    );
}

jni_macos_window(void, nSetCursor)(JNIEnv* env, jobject, jlong _windowPtr, jint index) {
    NSWindow* window = (NSWindow*)_windowPtr;
    View* view = [window contentView];

    if(index == 0)       view->cursor = [NSCursor arrowCursor];
    else if(index == 1)  view->cursor = [NSCursor pointingHandCursor];
    else if(index == 2)  view->cursor = [NSCursor IBeamCursor];
    else if(index == 3)  view->cursor = [NSCursor performSelector:@selector(_waitCursor)];
    else if(index == 5)  view->cursor = [NSCursor crosshairCursor];
    else if(index == 6)  view->cursor = [NSCursor operationNotAllowedCursor];
    else if(index == 7)  view->cursor = [NSCursor performSelector:@selector(_helpCursor)];
    else if(index == 8)  view->cursor = [NSCursor resizeLeftRightCursor];
    else if(index == 9)  view->cursor = [NSCursor resizeUpDownCursor];
    else if(index == 14) view->cursor = [NSCursor performSelector:@selector(_windowResizeNorthEastSouthWestCursor)];
    else if(index == 15) view->cursor = [NSCursor performSelector:@selector(_windowResizeNorthWestSouthEastCursor)];
    else if(index == 16) view->cursor = [NSCursor openHandCursor];
    else                 view->cursor = [NSCursor arrowCursor];
}

jni_macos_window(jlong, nGetScreen)(JNIEnv* env, jobject, jlong _windowPtr) {
    __block NSScreen* result;
    ON_MAIN_THREAD(
        NSWindow* window = (NSWindow*)_windowPtr;
        result = [window screen];
    );
    return (jlong)result;
}

jni_macos_window(void, nSetMinimizable)(JNIEnv* env, jobject, jlong _windowPtr, jboolean value) {
    ON_MAIN_THREAD(
        NSWindow* window = (NSWindow*)_windowPtr;
        if(value) window.styleMask |= NSWindowStyleMaskMiniaturizable;
        else      window.styleMask &= ~NSWindowStyleMaskMiniaturizable;
    );
}

jni_macos_window(void, nSetMaximizable)(JNIEnv* env, jobject, jlong _windowPtr, jboolean value) {
    ON_MAIN_THREAD(
        NSWindow* window = (NSWindow*)_windowPtr;
        if(value) [window setCollectionBehavior: NSWindowCollectionBehaviorFullScreenPrimary | NSWindowCollectionBehaviorManaged];
        else      [window setCollectionBehavior: 0];
    );
}

jni_macos_window(void, nSetClosable)(JNIEnv* env, jobject, jlong _windowPtr, jboolean value) {
    ON_MAIN_THREAD(
        NSWindow* window = (NSWindow*)_windowPtr;
        if(value) window.styleMask |= NSWindowStyleMaskClosable;
        else      window.styleMask &= ~NSWindowStyleMaskClosable;
    );
}

jni_macos_window(void, nSetResizable)(JNIEnv* env, jobject, jlong _windowPtr, jboolean value) {
    ON_MAIN_THREAD(
        NSWindow* window = (NSWindow*)_windowPtr;
        if(value) window.styleMask |= NSWindowStyleMaskResizable;
        else      window.styleMask &= ~NSWindowStyleMaskResizable;
    );
}

jni_macos_window(jfloat, nGetDpi)(JNIEnv* env, jobject, jlong _windowPtr) {
    NSWindow* window = (NSWindow*)_windowPtr;
    return (jfloat)[window backingScaleFactor];
}

jni_macos_window(jfloat, nSetEnabled)(JNIEnv* env, jobject, jlong _windowPtr, jboolean enabled) {
    ON_MAIN_THREAD(
        NSWindow* window = (NSWindow*)_windowPtr;
        View* view = [window contentView];
        view->disabled = !enabled;
    );
}

jni_macos_window(void, nSetStyle)(JNIEnv* env, jobject, jlong _windowPtr, jint style) {
    ON_MAIN_THREAD(
        NSWindow* window = (NSWindow*)_windowPtr;

        window.styleMask &= ~NSWindowStyleMaskBorderless;
        window.styleMask |= NSWindowStyleMaskTitled;
        window.styleMask &= ~NSWindowStyleMaskFullSizeContentView;
        window.titleVisibility = NSWindowTitleVisible;
        window.titlebarAppearsTransparent = false;

        if(style == 1) {
            window.styleMask |= NSWindowStyleMaskBorderless;
            window.styleMask &= ~NSWindowStyleMaskTitled;
        } else if(style == 2) {
            window.styleMask |= NSWindowStyleMaskFullSizeContentView;
            window.titleVisibility = NSWindowTitleHidden;
            window.titlebarAppearsTransparent = true;
        }

        BOOL hideButtons = style == 2;
        [[window standardWindowButton:NSWindowCloseButton] setHidden:hideButtons];
        [[window standardWindowButton:NSWindowMiniaturizeButton] setHidden:hideButtons];
        [[window standardWindowButton:NSWindowZoomButton] setHidden:hideButtons];
    );
}