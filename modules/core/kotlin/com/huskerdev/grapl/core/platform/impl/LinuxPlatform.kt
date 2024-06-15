package com.huskerdev.grapl.core.platform.impl

import com.huskerdev.grapl.core.display.Display
import com.huskerdev.grapl.core.display.impl.X11DisplayPeer
import com.huskerdev.grapl.core.platform.Platform


class LinuxPlatform: Platform() {
    companion object {

        val windowingSystem: WindowingSystem by lazy {
            if ("WAYLAND_DISPLAY" in System.getenv())
                X11() else X11()
        }
    }

    override fun specifyLibName(libName: String) =
        "$libName-$arch.so"

    override val primaryDisplay: Display
        get() = windowingSystem.primaryDisplay
    override val displays: Array<Display>
        get() = windowingSystem.displays

    override fun peekMessages() = windowingSystem.peekMessages()
    override fun waitMessages(timeout: Int) = windowingSystem.waitMessages(timeout)
    override fun postEmptyMessage() = windowingSystem.postEmptyMessage()
}

interface WindowingSystem {
    val primaryDisplay: Display
    val displays: Array<Display>

    fun peekMessages()
    fun waitMessages(timeout: Int)
    fun postEmptyMessage()
}

class X11: WindowingSystem {
    companion object {
        @JvmStatic private external fun nXOpenDisplay(): Long

        @JvmStatic private external fun nPeekMessages(): Long
    }

    val display = nXOpenDisplay()

    init {
        println("Display: $display")
    }

    override val primaryDisplay = Display(X11DisplayPeer.primary(display))
    override val displays = X11DisplayPeer.list(display).map { Display(it) }.toTypedArray()

    override fun peekMessages() {
        TODO("Not yet implemented")
    }

    override fun waitMessages(timeout: Int) {
        TODO("Not yet implemented")
    }

    override fun postEmptyMessage() {
        TODO("Not yet implemented")
    }
}

class Wayland: WindowingSystem {
    companion object {
        @JvmStatic private external fun nConnectDisplay(): Long
    }

    val display = nConnectDisplay()

    init {

    }

    override val primaryDisplay: Display
        get() = TODO("Not yet implemented")
    override val displays: Array<Display>
        get() = TODO("Not yet implemented")

    override fun peekMessages() {
        TODO("Not yet implemented")
    }

    override fun waitMessages(timeout: Int) {
        TODO("Not yet implemented")
    }

    override fun postEmptyMessage() {
        TODO("Not yet implemented")
    }

}