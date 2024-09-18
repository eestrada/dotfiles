#!/bin/sh

mmb_scroll_setup()
{
    xinput --set-prop "$1" 'Evdev Wheel Emulation' 1;
    xinput --set-prop "$1" 'Evdev Wheel Emulation Button' 2;
    xinput --set-prop "$1" 'Evdev Wheel Emulation Axes' 6 7 4 5;
    xinput --set-prop "$1" 'Evdev Wheel Emulation Timeout' 200;
}

_mmb_scroll_init()
{
    mmb_scroll_setup 'Logitech USB Optical Mouse';
    mmb_scroll_setup 'pointer:Microsoft Microsoft® Nano Transceiver v1.0';
}

_mmb_scroll_init 2>/dev/null;
