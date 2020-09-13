# artist.nvim

- `light`  : `:lua require'artist'.artist_use_char_set("light")`
- `heavy`  : `:lua require'artist'.artist_use_char_set("heavy")`
- `double` : `:lua require'artist'.artist_use_char_set("double")`
- `arc`    : `:lua require'artist'.artist_use_char_set("arc")`

Draw lines:

- `light`  : `─────────────────────`
- `heavy`  : `━━━━━━━━━━━━━━━━━━━━━`
- `double` : `═════════════════════`
- `arc`    : `─────────────────────`

Draw boxes:

`light`:

```
       ┌───────────────┐
       │               │
       │               │
       │               │
       └───────────────┘
```

`heavy`:

```
       ┏━━━━━━━━━━━━━━━┓
       ┃               ┃
       ┃               ┃
       ┃               ┃
       ┗━━━━━━━━━━━━━━━┛
```

`double`:

```
       ╔═══════════════╗
       ║               ║
       ║               ║
       ║               ║
       ╚═══════════════╝
```

`arc`:

```
       ╭───────────────╮
       │               │
       │               │
       │               │
       ╰───────────────╯
```

Supports intersections:

```
       ┌───┬──┬────┬───┐
       │ ┌─┴──┘    ├─┐ │
       ├─┘  ┌─┐    │┌┘┌┤
       │   ┌┴─┼────┤└─┘│
       └───┴──┴────┴───┘
```
