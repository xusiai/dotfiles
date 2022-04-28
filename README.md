<h2 align="center"> ━━━━━━  ❖  ━━━━━━ </h2>

## ♥️ Welcome! ♥️
This is a collection of dotfiles which I use for a bspwm setup. Hope you find something you like!


### DEPENDENCIES
> 

|  DETAILS   |  SOFTWARE  |
|------------|------------|
| OS         | VOID ♥️     |
| SHELL      | ZSH        |
| BAR        | POLYBAR    |
| TERMINAL   | KITTY      |
| EDITOR     | HELIX      |
| COMPOSITOR | PICOM      |
| LAUNCHER   | ROFI       |
| PALETTE    | SAGA  ♥️    |
</br>

Most of these files will work out of the box assuming you have the applications installed. There are however some exceptions:
- Dotfiles which make use of colour to some extent retrieve these values from `$HOME/.config/colorer/out` and as such [colorer](https://github.com/Kiddae/colorer) is recommended. 
- zshrc require the `.antigen.zsh file included in order to install plugins.

In addition, some of the bar modules require additional dependencies:
- CPU modules require lm_sensors.
- Pipewire requires pamixer.
- Updates requires the xbps package manager.
- VPN require Mullvad. 
- Menu, powermenu & VPN modules make use of Rofi to some extent. 

## GALLERY </br></br>
<details>
  <summary>Click to expand</summary>

<p align="center">
  <img src="assets/WALL.png"></br>
  <img src="assets/ROFI.png"></br>
  <img src="assets/TILED.png"></br>
</p>
</details>

## SETUP
<details>
  <summary>Click to expand</summary>

#### OPTION A
Clone the repo and link or move the files to their appropriate locations. 
```
git clone https://github.com/Miusaky/BSPDOTS $HOME
cp --remove-destination -as $HOME/BSPDOTS/. $HOME/
```
With this method all files remain in the BSPDOTS which make updating and handling them a lot easier. 

#### OPTION B
- Clone the repo and selectively move the files you want and toss the others in the bin. Most files *should* work on their own but some - like the bar - depend on others and therefore will not work without them. YMMV with this method. 
</details>


### NOTES
- BSPWM includes files for [colorer](https://github.com/kiddae/colorer) to switch colour schemes. To do so install colorer and run `colorer path-to-scheme`. I have included a selection in `~/.config/colorer/flavours`. The default colourscheme is [SAGA](https://github.com/SAGAtheme/SAGA). If you like it there are additional dotfiles which make use of it [here](https://github.com/SAGAtheme/). </br>

## ACKNOWLEDGEMENTS
- [Kiddae](https://github.com/kiddae) for developing colorer.
- [Siduck](https://github.com/siduck) for inspiration and rofi template.
- [adi1090x](https://github.com/adi1090x) for the ncmpcpp config.

