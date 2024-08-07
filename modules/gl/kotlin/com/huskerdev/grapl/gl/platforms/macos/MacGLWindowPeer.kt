package com.huskerdev.grapl.gl.platforms.macos

import com.huskerdev.grapl.core.window.impl.MacWindowPeer
import com.huskerdev.grapl.gl.GLProfile
import com.huskerdev.grapl.gl.GLWindowPeer

class MacGLWindowPeer(
    profile: GLProfile,
    shareWith: Long,
    majorVersion: Int,
    minorVersion: Int,
    debug: Boolean
): MacWindowPeer(), GLWindowPeer {
    override val context = NSGLContext.createAttached(this, profile, shareWith, majorVersion, minorVersion, debug)

    init {
        sizeProperty.listeners += {
            context.setBackingSize(
                sizeProperty.value.width.toInt(),
                sizeProperty.value.height.toInt())
        }
    }

    override fun dispatchUpdate() {
        context.makeCurrent()
        context.lock()
        super.dispatchUpdate()
        context.unlock()
    }
}