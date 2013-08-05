Kwin Tiling (written in Nimrod)
===============================

This implements tiling for the KWin window manager. It is written in
[Nimrod](http://nimrod-code.org/), which compiles to JavaScript. The
resulting script (`nimcache/tiling.js`) can then be loaded with kwin.
Better distribution mechanisms in progress.

Building the script
-------------------

    nimrod -d:release -d:nodejs -d:kwin tiling.nim
    # Produces tiling.js in nimcache/tiling.js
    
Development Setup
-----------------

Grab [kwin-minor-mode](https://github.com/Tass/kwin-minor-mode), which
already handles nimrod. `C-c C-l` compiles the current buffer and
sends it to kwin. Before the next iteration, I recommend
`kwin-kill-script` which kills all scripts. This is needed to
unregister the shortcuts from the previous script.
