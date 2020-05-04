x=$(xdpyinfo | grep dimensions | awk '{print $2}' | awk -Fx '{print $1}')
y=$(xdpyinfo | grep dimensions | awk '{print $2}' | awk -Fx '{print $2}')
echo $x $y
