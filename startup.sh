#!/bin/sh
/lms-setup.sh
/dbus-setup.sh
/avahi-setup.sh
exec /sbin/my_init
