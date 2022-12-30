---
title: 'Ubuntu graphic interface stopped working'
date: '2016-02-23'
tags:
  - 'work'
  - 'ubuntu'
---

Some time ago, I helped a colleague [install Ubuntu in a Sony Vaio, which ended
up having SSD
problems]({{local_prefix}}/instalando-o-ubuntu-14.10-no-sony-vaio/).
Today, his computer started without the bar and menu from Unity.
Only the desktop and icons were appearing, and the keyboards shortcuts were also
not working.

To fix, I found [this askubuntu
question](http://askubuntu.com/questions/17381/unity-doesnt-load-no-launcher-no-dash-appears),
that worked like a charm.

The steps were simply:

1. Enter the terminal mode with Ctrl+Shift+F2 (or other number);
2. Login;
3. Enter the commands

```
export DISPLAY=:0
sudo dconf reset -f /org/compiz/
setsid unity
```

4. Reboot with

```
sudo reboot
```

5. Verify everything is working now.

This was enough to fix it.
