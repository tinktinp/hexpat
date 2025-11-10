# ImHex hexpat files Mortal Kombat games

These files are for the ImHex hex editor.

See:
- https://docs.werwolv.net/imhex/views/pattern-data
- https://docs.werwolv.net/imhex/views/pattern-editor
- https://docs.werwolv.net/pattern-language/

To use these, you can either copy and paste them into ImHex's pattern editor, or you can clone this repo and add that folder in your settings, under Settings->Folders. (Remember that it's the `hexpat` folder and not the `includes` folder that you need to add.)

Assuming you've added this repo to your folders. you can use the pattern on a MKT character file like this:

```hexpat
import mkt_character;
```

Or for a background file:

```hexpat
import mkt;
```

Or you can import (or copy/paste) things from `mkt_types.hexpat` and place them yourself.