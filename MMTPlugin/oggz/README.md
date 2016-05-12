This file is a fork of libogg, supposedly from around 2011-04-29.

But it looks closer to 8698926d9c861d1c156f075467286a4e7d8721ef (from 2012)

With
* disabling of WRITES (OGGZ_CONFIG_WRITE 0)
* adding oggz_keyframe_seek_set from Mozilla ?
* modify Win32 VS paths
* add some android specific build stuff

I also see it misses some patches: e.g. partial fix of abda2f59de98eeb7b70116723190df9f4324f31e

