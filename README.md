# Official Powow Lua libraries

These will be the open source Lua libraries for Powow. Of course, the end-user can add any libraries they want once they
install Powow, but these will be included by default to get started.

So far, I only have a SoundCloud song implementation for
[Wax](http://github.com/probablycorey/wax), which is just a proof of concept. It will be completely rewritten for the framework.

I also have some pseudocode for Google Music.

## Implementation goal

Tick off everything on [this list](http://www.programmableweb.com/apitag/music). (just kidding)

```bash
>>> ls
soundcloud    spotify    google_music    rdio    http_download    google_music_and_itunes_combined
>>> ls soundcloud
song.lua    library.lua    search.lua    newsfeed.lua    starred.lua    sets.lua
>>> ls google_music
song.lua    library.lua    songs.lua    artists.lua    albums.lua    playlists.lua
>>> ls google_music_and_itunes_combined
library.lua    songs.lua    artist.lua    albums.lua    playlists.lua
>>> ls http_download
song.lua
```

The idea is that each different library has its own directory. At the very base, song.lua and library.lua can be implemented,
but there can be other files included as well to support the initial two.

### Library

If library is implemented, it will be selectable from the left-hand side of the application as a UITableViewCell. From there, it will look for a table
of different view controllers. So, for example, in google_music, library would contain four (or more) view controllers. It
would be pretty similar to the music app, so there'd be a "Songs" tab, "Artists" tab, "Albums" tab, etc. And all of these
would be chock full of directories and songs that can be added to the queue (and possibly sent to another device if supported),
which are fully customizable and extendable.

### Song

This basically is used for displaying the title/album/artist, getting the song mp3/flac/whatever data and storing them in a way so that
they can be played in the queue and possibly sent to other devices with powow (if the other device can play the song, that is)

### Directory

Basically a directory of songs. This can also be extensible, I can't really think of any reason why any additional functionality
would be necessary but I'm sure something will come up.

=====

The beauty of this design is that there will be finally a universal place to play your music (on a mobile device, that is). There will
no longer be a need to be constantly switching from different apps on your phone to essentially just call different APIs.
