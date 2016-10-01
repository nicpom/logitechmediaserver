#!/bin/sh
if [ ! -d /mnt/state/etc ]; then
   mkdir -p /mnt/state/etc
   cp -pr /etc/squeezeboxserver.orig/* /mnt/state/etc
   chown -R squeezeboxserver.nogroup /mnt/state/etc
fi
# Automatically update to newer version if exists
if [ -f /mnt/state/cache/updates/server.version ]; then
    cd /mnt/state/cache/updates
    UPDATE=`cat server.version`
    dpkg -i $UPDATE
    mv server.version this-server.version
    # Keep a history for rollback in case
    # rm -f $UPDATE 
fi
chown squeezeboxserver.nogroup /mnt/state /srv/playlists
/usr/bin/supervisord -c /etc/supervisord.conf
