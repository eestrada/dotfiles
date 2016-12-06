#!/bin/bash

function _mmb_scroll_generic()
{
    xinput --set-prop "$1" 'Evdev Wheel Emulation' 1;
    xinput --set-prop "$1" 'Evdev Wheel Emulation Button' 2;
    xinput --set-prop "$1" 'Evdev Wheel Emulation Axes' 6 7 4 5;
    xinput --set-prop "$1" 'Evdev Wheel Emulation Timeout' 200;
}

function mmb_scroll()
{
    _mmb_scroll_generic 'Logitech USB Optical Mouse';
    _mmb_scroll_generic 'pointer:Microsoft Microsoft® Nano Transceiver v1.0';
}

mmb_scroll 2>/dev/null;
