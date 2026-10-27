# Mini-mineur

A small 2D mining game made with Godot 4 in a few days, as a first complete project.
Dig through the mine, find as much gold as you can before your energy or the timer runs out.

**Play it in your browser:** https://denkitsune.itch.io/mining

## How to play

| Action | Keyboard | Touchscreen |
| --- | --- | --- |
| Move | Left / Right arrows | Left / Right buttons |
| Mine | Hold an arrow (Left, Right or Down) against a block | Hold a direction button against a block |
| Jump | Space | Jump button |
| Start / Retry | Space | Touch the screen |

## Rules

- Each block you dig costs energy. You start with 100 energy, and each block costs 5.
- Digging a gold ore gives you 1 point.
- The game ends when your energy reaches 0 or when the 60-second timer runs out.
- Try to beat your best score.

## Features

- Hold-to-dig mining on a tile grid, with auto-tiling of the remaining terrain
- Energy, score and timer HUD
- Title screen and game over screen with instant retry
- Keyboard and touchscreen controls, detected automatically
- Pixel-art rendering at 480 × 270, scaled ×3
- Sound effects, particles and background music

## Run the project locally

1. Install [Godot 4.7](https://godotengine.org/download) or later (standard version, GDScript).
2. Clone the repository:
   ```bash
   git clone https://github.com/loan75/mini-mineur.git
   ```
3. Open Godot, click **Import**, select the `project.godot` file, then press **F5** to play.

To build the web version: **Project > Export > Web**.

## Project structure

```
Assets/          Sprites, tilesets, music and sound effects
Scenes/
  MainMenu/      Title screen with the controls
  Mine/          Level: terrain, ore layer, timer and game rules
  Player/        The miner: movement, digging, animations
  HUD/           Energy, score, timer, game over and touch controls
```

## Credits

- Game design and code: Loan Harrouin (Denkitsune)
- Character and tile sprites: TODO, add the asset pack name, author and licence
- Music and sound effects: TODO, add the sources and licences
- Made with the [Godot Engine](https://godotengine.org)
