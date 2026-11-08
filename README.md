# RS Dice 🎲

**RS Dice** is a FiveM resource that allows players to roll dice directly in-game.

When a player uses their dice, a 3D interface appears above their character's head, displaying the dice result. Nearby players can also see the result.

### Features

- In-game dice rolling system.
- Randomly generated results.
- 3D interface displayed above the player's head.
- Results visible to nearby players.
- Dice usable through the inventory.
- ESX and ox_inventory integration.

### Dependencies

- `es_extended`
- `ox_inventory`
- `ox_lib`

### Installation

1. Download this repository.
2. Place the `rs_dice` folder inside your server's `resources` directory.
3. Add the following lines to your `server.cfg`:

```cfg
ensure ox_lib
ensure es_extended
ensure ox_inventory
ensure rs_dice
```

### ox_inventory Item Configuration

Add the following item to your ox_inventory items file:

```lua
['dice'] = {
    label = 'Dice',
    weight = 100,
    stack = true,
    close = true,
    description = 'Dice for playing games',
    client = {
        event = 'lancer_de_des:useDice'
    }
},
```

### Useful Links

- **RS Studio Discord:** https://discord.gg/PEscf54mug
- **RS Studio Store:** https://rs-shop.wh-web.fr/
- **GitHub:** https://github.com/GAGYC

### Developer

**RS Studio**

---

*Developed by RS Studio.*
