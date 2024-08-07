#include "grapl-x11.h"

#include <math.h>
#include <cstring>
#include <stdio.h>

jni_x11_display(jlong, nGetPrimaryScreen)(JNIEnv* env, jobject, jlong _display) {
    Display* display = (Display*)_display;
    Window root = DefaultRootWindow(display);

    XRRScreenResources* sr = XRRGetScreenResourcesCurrent(display, root);
    RROutput primary = XRRGetOutputPrimary(display, root);

    for(int i = 0; i < sr->noutput; i++){
        if(sr->outputs[i] == primary){
            XRRFreeScreenResources(sr);
            return i;
        }
    }
    XRRFreeScreenResources(sr);
    return -1;
}

jni_x11_display(jlongArray, nGetAllScreens)(JNIEnv* env, jobject, jlong _display) {
    Display* display = (Display*)_display;
    Window root = DefaultRootWindow(display);

    XRRScreenResources* sr = XRRGetScreenResourcesCurrent(display, root);
    int count = sr->noutput;

    int actualCount = 0;
    for(int i = 0; i < count; i++){
        XRROutputInfo* oi = XRRGetOutputInfo(display, sr, sr->outputs[i]);
        if(oi->crtc && !oi->connection)
            actualCount++;
        XRRFreeOutputInfo(oi);
    }

    jlong* screens = new jlong[actualCount];
    for(int i = 0, r = 0; i < count; i++){
        XRROutputInfo* oi = XRRGetOutputInfo(display, sr, sr->outputs[i]);
        if(oi->crtc && !oi->connection)
            screens[r++] = i;
        XRRFreeOutputInfo(oi);
    }

    XRRFreeScreenResources(sr);
    jlongArray result = createLongArray(env, actualCount, screens);
    delete[] screens;
    return result;
}

jni_x11_display(jintArray, nGetSize)(JNIEnv* env, jobject, jlong _display, jlong index) {
    Display* display = (Display*)_display;
    Window root = DefaultRootWindow(display);

    XRRScreenResources* sr = XRRGetScreenResourcesCurrent(display, root);
    XRROutputInfo* oi = XRRGetOutputInfo(display, sr, sr->outputs[index]);
    XRRCrtcInfo* ci = XRRGetCrtcInfo(display, sr, oi->crtc);

    XRRCrtcTransformAttributes* attributes;
    XRRGetCrtcTransform(display, oi->crtc, &attributes);

    RRMode modeId = ci->mode;

    int width = 0, height = 0;
    for (int i = 0; i < sr->nmode; i++) {
        XRRModeInfo mode = sr->modes[i];
        if (mode.id == modeId) {
            width = mode.width;
            height = mode.height;
            break;
        }
    }

    XRRFreeOutputInfo(oi);
    XRRFreeCrtcInfo(ci);
    XRRFreeScreenResources(sr);
    return createIntArray(env, {
        width,
        height
    });
}

jni_x11_display(jintArray, nGetPosition)(JNIEnv* env, jobject, jlong _display, jlong index) {
    Display* display = (Display*)_display;
    Window root = DefaultRootWindow(display);

    XRRScreenResources* sr = XRRGetScreenResourcesCurrent(display, root);
    XRROutputInfo* oi = XRRGetOutputInfo(display, sr, sr->outputs[index]);
    XRRCrtcInfo* ci = XRRGetCrtcInfo(display, sr, oi->crtc);

    jintArray result = createIntArray(env, {
        ci->x,
        ci->y
    });

    XRRFreeOutputInfo(oi);
    XRRFreeCrtcInfo(ci);
    XRRFreeScreenResources(sr);
    return result;
}

bool cmpD(double a, double b){
    return fabs(a - b) < 0.000001;
}

jni_x11_display(jdouble, nGetDpi)(JNIEnv* env, jobject, jlong _display, jlong index) {
    Display* display = (Display*)_display;
    Window root = DefaultRootWindow(display);

    // Getting DPI from scale
    XRRScreenResources* sr = XRRGetScreenResourcesCurrent(display, root);
    XRROutputInfo* oi = XRRGetOutputInfo(display, sr, sr->outputs[index]);
    XRRCrtcInfo* ci = XRRGetCrtcInfo(display, sr, oi->crtc);

    XRRCrtcTransformAttributes* attributes;
    XRRGetCrtcTransform(display, oi->crtc, &attributes);
    double scale = XFixedToDouble(attributes->currentTransform.matrix[0][0]);

    XRRFreeOutputInfo(oi);
    XRRFreeCrtcInfo(ci);
    XRRFreeScreenResources(sr);

    if(cmpD(scale, 1.599991)) return 1.25;
    if(cmpD(scale, 1.333328)) return 1.50;
    if(cmpD(scale, 1.141663)) return 1.75;
    if(cmpD(scale, 1.362488)) return 2.25;
    if(cmpD(scale, 1.199997)) return 2.50;
    if(cmpD(scale, 1.087494)) return 2.75;
    if(cmpD(scale, 1.233322)) return 3.25;
    if(cmpD(scale, 1.149994)) return 3.50;
    if(cmpD(scale, 1.066666)) return 3.75;

    // If dpi is integer, then get it from Xft.dpi
    XrmValue value;
    char *type = NULL;

    XrmInitialize();
    char *resourceString = XResourceManagerString(display);
    XrmDatabase db = XrmGetStringDatabase(resourceString);
    if (resourceString && XrmGetResource(db, "Xft.dpi", "String", &type, &value) && value.addr)
        return atof(value.addr) / 96.0;

    return 1.0;
}

jni_x11_display(jint, nGetFrequency)(JNIEnv* env, jobject, jlong _display, jlong index) {
    Display* display = (Display*)_display;
    Window root = DefaultRootWindow(display);

    XRRScreenResources* sr = XRRGetScreenResourcesCurrent(display, root);
    XRROutputInfo* oi = XRRGetOutputInfo(display, sr, sr->outputs[index]);
    XRRCrtcInfo* ci = XRRGetCrtcInfo(display, sr, oi->crtc);

    RRMode modeId = ci->mode;

    double rate = 0;
    for (int i = 0; i < sr->nmode; i++) {
        XRRModeInfo mode = sr->modes[i];
        if (mode.id == modeId) {
            rate = round((double)mode.dotClock / ((double)mode.hTotal * (double)mode.vTotal));
            break;
        }
    }

    XRRFreeOutputInfo(oi);
    XRRFreeCrtcInfo(ci);
    XRRFreeScreenResources(sr);
    return rate;
}

jni_x11_display(jstring, nGetSystemName)(JNIEnv* env, jobject, jlong _display, jlong index) {
    Display* display = (Display*)_display;
    Window root = DefaultRootWindow(display);

    XRRScreenResources* sr = XRRGetScreenResourcesCurrent(display, root);
    XRROutputInfo* oi = XRRGetOutputInfo(display, sr, sr->outputs[index]);

    jstring result = env->NewStringUTF(oi->name);

    XRRFreeOutputInfo(oi);
    XRRFreeScreenResources(sr);

    return result;
}

jni_x11_display(jintArray, nGetDisplayModes)(JNIEnv* env, jobject, jlong _display, jlong index) {
    Display* display = (Display*)_display;
    Window root = DefaultRootWindow(display);

    XRRScreenResources* sr = XRRGetScreenResourcesCurrent(display, root);
    XRROutputInfo* oi = XRRGetOutputInfo(display, sr, sr->outputs[index]);
    XRRCrtcInfo* ci = XRRGetCrtcInfo(display, sr, oi->crtc);

    jint* result = new jint[sr->nmode * 4];
    for (int i = 0; i < sr->nmode; i++) {
        XRRModeInfo mode = sr->modes[i];
        result[i*4+0] = mode.width;
        result[i*4+1] = mode.height;
        result[i*4+2] = 32;
        result[i*4+3] = round((double)mode.dotClock / ((double)mode.hTotal * (double)mode.vTotal));
    }

    XRRFreeOutputInfo(oi);
    XRRFreeCrtcInfo(ci);
    XRRFreeScreenResources(sr);
    return createIntArray(env, sr->nmode * 4, result);
}

jni_x11_display(jintArray, nGetCurrentDisplayMode)(JNIEnv* env, jobject, jlong _display, jlong index) {
    Display* display = (Display*)_display;
    Window root = DefaultRootWindow(display);

    XRRScreenResources* sr = XRRGetScreenResourcesCurrent(display, root);
    XRROutputInfo* oi = XRRGetOutputInfo(display, sr, sr->outputs[index]);
    XRRCrtcInfo* ci = XRRGetCrtcInfo(display, sr, oi->crtc);

    RRMode modeId = ci->mode;

    for (int i = 0; i < sr->nmode; i++) {
        XRRModeInfo mode = sr->modes[i];
        if (mode.id == modeId) {
            return createIntArray(env, {
                (int)mode.width,
                (int)mode.height,
                32,
                (int)round((double)mode.dotClock / ((double)mode.hTotal * (double)mode.vTotal))
            });
        }
    }

    XRRFreeOutputInfo(oi);
    XRRFreeCrtcInfo(ci);
    XRRFreeScreenResources(sr);
    return 0;
}

jni_x11_display(jbyteArray, nGetEDID)(JNIEnv* env, jobject, jlong _display, jlong index) {
    Display* display = (Display*)_display;
    Window root = DefaultRootWindow(display);

    XRRScreenResources* sr = XRRGetScreenResourcesCurrent(display, root);

    int nprop = 0;
    Atom* props = XRRListOutputProperties(display, sr->outputs[index], &nprop);

    for (int i = 0; i < nprop; i++) {
        char* atom_name = XGetAtomName(display, props[i]);
        Bool is_edid = strcmp(atom_name, "EDID") == 0;

        if(is_edid){
            unsigned char* prop;
            int actual_format;
            unsigned long nitems, bytes_after;
            Atom actual_type;

            XRRGetOutputProperty(display, sr->outputs[index], props[i],
                      0, 100, False, False,
                      AnyPropertyType,
                      &actual_type, &actual_format,
                      &nitems, &bytes_after, &prop);

            XRRFreeScreenResources(sr);
            return createByteArray(env, nitems, (jbyte*)prop);
        }
    }

    XRRFreeScreenResources(sr);
    return createByteArray(env, {});
}