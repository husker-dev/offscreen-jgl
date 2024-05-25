package com.huskerdev.grapl.core.input

import com.huskerdev.grapl.core.platform.Platform


const val MB_LEFT = 1
const val MB_MIDDLE = 2
const val MB_RIGHT = 3
const val MB_BACK = 4
const val MB_FORWARD = 5

var DOUBLE_CLICK_DELAY = 400
var DOUBLE_CLICK_RADIUS = 5

const val MASK_MODIFIER_ALT    = 1
const val MASK_MODIFIER_CTRL   = 2
const val MASK_MODIFIER_SHIFT  = 4
const val MASK_MODIFIER_COMMAND = 8


fun getMouseButtonName(button: Int) = Platform.current.getMouseButtonName(button)

abstract class Pointer(
    open val id: Int
) {
    abstract val absoluteX: Int
    abstract val absoluteY: Int
    abstract val x: Double
    abstract val y: Double
    abstract val buttons: Set<Int>

    override fun toString(): String {
        return "Pointer(id=$id, absoluteX=$absoluteX, absoluteY=$absoluteY, x=$x, y=$y, buttons=$buttons)"
    }

    open class Event(
        val pointer: Pointer,
        val modifiers: Int
    ) {
        /**
         * Alt on Linux/Windows,
         * Option on macOS
         */
        val isAltDown = modifiers and MASK_MODIFIER_ALT == MASK_MODIFIER_ALT
        val isCtrlDown = modifiers and MASK_MODIFIER_CTRL == MASK_MODIFIER_CTRL
        val isShiftDown = modifiers and MASK_MODIFIER_SHIFT == MASK_MODIFIER_SHIFT

        /**
         * Only for macOS
         */
        val isCommandDown = modifiers and MASK_MODIFIER_COMMAND == MASK_MODIFIER_COMMAND
    }

    open class ClickEvent(
        pointer: Pointer,
        modifiers: Int,
        val clicks: Int
    ): Event(pointer, modifiers)

    class MoveEvent(
        pointer: Pointer,
        modifiers: Int,
        val oldX: Double,
        val oldY: Double,
        val oldAbsoluteX: Double,
        val oldAbsoluteY: Double,
    ): Event(pointer, modifiers) {
        val deltaX = pointer.x - oldX
        val deltaY = pointer.y - oldY
        val deltaAbsoluteX = pointer.x - oldX
        val deltaAbsoluteY = pointer.y - oldY
    }

    class ScrollEvent(
        pointer: Pointer,
        modifiers: Int,
        val deltaX: Double,
        val deltaY: Double
    ): Event(pointer, modifiers)

    class ZoomEvent(
        pointer: Pointer,
        modifiers: Int,
        val zoom: Double,
        val deltaZoom: Double
    ): Event(pointer, modifiers)

    class RotationEvent(
        pointer: Pointer,
        modifiers: Int,
        val angle: Double,
        val deltaAngle: Double
    ): Event(pointer, modifiers)
}