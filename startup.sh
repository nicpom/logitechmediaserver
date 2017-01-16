#!/bin/sh
/lms-setup.sh
exec /usr/sbin/squeezeboxserver --user lms --prefsdir /mnt/state/prefs --logdir /mnt/state/logs --cachedir /mnt/state/cache --charset=utf8


