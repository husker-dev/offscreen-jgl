package com.huskerdev.grapl.gl.platforms.macos

import com.huskerdev.grapl.gl.GLPlatform
import com.huskerdev.grapl.gl.GLProfile
import com.huskerdev.grapl.gl.GLWindow

class MacGLPlatform: GLPlatform() {

    override fun supportsDebug() = false

    override fun createContext(profile: GLProfile, shareWith: Long, majorVersion: Int, minorVersion: Int, debug: Boolean) =
        CGLContext.create(profile, shareWith, majorVersion, minorVersion, debug)

    override fun createFromCurrentContext() =
        CGLContext.fromCurrent()

    override fun clearContext() =
        CGLContext.clearContext()

    override fun createGLWindowPeer(
        profile: GLProfile,
        shareWith: Long,
        majorVersion: Int,
        minorVersion: Int,
        debug: Boolean
    ) = MacGLWindowPeer(profile, shareWith, majorVersion, minorVersion, debug).apply {
        this.onCreated()
    }

    override fun swapBuffers(window: GLWindow) =
        (window.context as NSGLContext).flushBuffer()

    override fun setSwapInterval(window: GLWindow, value: Int) =
        (window.context as NSGLContext).setSwapInterval(value)

}