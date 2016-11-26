#!/bin/sh
exec /sbin/setuser squeezeboxserver /usr/sbin/squeezeboxserver --prefsdir /mnt/state/prefs --logdir /mnt/state/logs --cachedir /mnt/state/cache --charset=utf8
