#include <grapl.h>
#include <iostream>

typedef int GLint;
typedef int GLsizei;
typedef float GLfloat;
typedef void GLvoid;
typedef char GLchar;
typedef unsigned int GLuint;
typedef unsigned int GLenum;
typedef unsigned char GLubyte;
typedef unsigned int GLbitfield;
typedef unsigned char GLboolean;
typedef signed long int GLintptr;
typedef signed long int GLsizeiptr;

#define GL_FALSE          0
#define GL_TRUE           1
#define GL_MAJOR_VERSION  0x821B
#define GL_MINOR_VERSION  0x821C
#define GL_CONTEXT_FLAGS  0x821E
#define GL_CONTEXT_FLAG_DEBUG_BIT 0x00000002

typedef void (*GLDEBUGPROCARB)(GLenum source, GLenum type, GLuint id, GLenum severity, GLsizei length, const GLchar *message, const void *userParam);

typedef void (*glGetIntegervPtr)(GLenum pname, GLint* data);
typedef void (*glFlushPtr)();
typedef void (*glDebugMessageCallbackARBPtr)(GLDEBUGPROCARB callback, const void *userParam);

static glGetIntegervPtr glGetIntegerv;
static glFlushPtr glFlush;
static glDebugMessageCallbackARBPtr glDebugMessageCallbackARB;



static JavaVM* jvm = NULL;
static jclass debugCallbackClass;

static void callbackFunction(GLenum source, GLenum type, GLuint id, GLenum severity, GLsizei length, const GLchar *message, const void *userParam){
    JNIEnv* env;
    jvm->AttachCurrentThread((void**)&env, NULL);

    jmethodID callbackMethod = env->GetStaticMethodID(debugCallbackClass, "dispatchDebug", "(JIIIILjava/lang/String;)V");
    env->CallStaticVoidMethod(debugCallbackClass, callbackMethod,
        (jlong)userParam,
        source,
        type,
        id,
        severity,
        env->NewStringUTF(message)
    );

    jvm->DetachCurrentThread();
}

static void bindDefaultDebugFunction(JNIEnv* env, jclass callbackClass, const void* handle) {
    if(jvm == NULL){
        env->GetJavaVM(&jvm);
        debugCallbackClass = (jclass)env->NewGlobalRef(callbackClass);
    }
    glDebugMessageCallbackARB(&callbackFunction, handle);
}