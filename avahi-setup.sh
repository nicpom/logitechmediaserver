# create dbus/avahi setup
rm -rf /var/run/*
mkdir -p /var/run/dbus
chown messagebus:messagebus /var/run/dbus
dbus-uuidgen --ensure
