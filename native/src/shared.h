#include <jni.h>
#include <iostream>

#define winglfun(returnType, fun)	extern "C" JNIEXPORT returnType JNICALL Java_com_huskerdev_ojgl_gl_platforms_WinGLPlatform_##fun
#define linuxglfun(returnType, fun) extern "C" __attribute__((unused)) JNIEXPORT returnType JNICALL Java_com_huskerdev_ojgl_gl_platforms_LinuxGLPlatform_##fun
#define macosglfun(returnType, fun) extern "C" JNIEXPORT returnType JNICALL Java_com_huskerdev_ojgl_gl_platforms_MacGLPlatform_##fun

#define d3d9fun(returnType, fun)	extern "C" JNIEXPORT returnType JNICALL Java_com_huskerdev_ojgl_d3d9_D3D9Device_##fun

jlongArray createLongArray(JNIEnv* env, int size, jlong* array){
    jlongArray result = env->NewLongArray(size);
    env->SetLongArrayRegion(result, 0, size, array);
    return result;
}