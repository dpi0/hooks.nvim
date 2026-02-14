# `hooks.nvim`

Hook your buffers and jump to them!

Hard forked from [xavierchen0/hooks.nvim](https://github.com/xavierchen0/hooks.nvim).

## Changes

1. Replaced slot-based system with a simple ordered list
2. `append()` is now the only way to add buffers (removed `add(key)`)
3. Simplified the floating editor (`list()`)
4. Reduce plugin usage complexity (no slots)
5. Add native cursor position remembrance (via `remember_cursor_position` opt)

Basically, in it's current state, this is a lighter and simpler [ThePrimeagen/harpoon](https://github.com/ThePrimeagen/harpoon/tree/harpoon2).

<img width="1412" height="795" alt="preview" src="https://github.com/user-attachments/assets/249cca1b-6569-4cf4-baa2-b2f08722d5d0" />

## What?

You enter a project and want to use a certain number of files regularly.

To switch b/w these 4-5 files quickly you can now "hook" them.

Use `:lua require("hooks").append()` to append current buffer to the list. This will be buffer `1`.

Manage the buffer list using `:lua require("hooks").list()` floating window.

The list is editable like a regular buffer. So move and delete items from it and save it.

Use `:lua require("hooks").buffer(N)` to switch to a hooked buffer.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "dpi0/hooks.nvim"
  opts = {
    remember_cursor_position = true,
  },
  keys = {
    { "<leader>ha", function() require("hooks").append() end, desc = "Hooks: Append current buffer" },
    { "<leader>hl", function() require("hooks").list() end, desc = "Hooks: List buffers" },
    { "<leader>1", function() require("hooks").buffer(1) end, desc = "Hooks: Buffer 1" },
    { "<leader>2", function() require("hooks").buffer(2) end, desc = "Hooks: Buffer 2" },
    { "<leader>3", function() require("hooks").buffer(3) end, desc = "Hooks: Buffer 3" },
    { "<leader>4", function() require("hooks").buffer(4) end, desc = "Hooks: Buffer 4" },
  },
}
```

## Configuration

```lua
opts = {
  remember_cursor_position = true, -- Remember last cursor position in the buffer (Default: true)
}
```
