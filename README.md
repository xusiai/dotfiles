<div align="center">


<!-- BADGES -->
   <p></p>
   <a href="">
      <img src="https://img.shields.io/github/issues/miusaky/bspdots?color=F5D0D0&labelColor=0A0D0F&style=for-the-badge">
   </a>
   <a href="https://github.com/miusaky/bspdots/stargazers">
      <img src="https://img.shields.io/github/stars/miusaky/bspdots?color=FFB2AD&labelColor=0A0D0F&style=for-the-badge">
   </a>
   <a href="https://github.com/miusaky/bspdots/">
      <img src="https://badges.pufler.dev/visits/miusaky/bspdots?style=for-the-badge&color=FFFFC1&logoColor=white&labelColor=0A0D0F"/>
   </a>
   <a href="https://github.com/miusaky/bspdots/">
      <img src="https://img.shields.io/github/repo-size/miusaky/bspdots?color=B4F8C8&labelColor=0A0D0F&style=for-the-badge">
  </a>
  <H3>  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  ❖  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ </H3>
</div>
<p/>


<img src="assets/WALL2.png"></br> 

<div align="center">  <H3>  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  ❖  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ </H3> </br> ** Welcome!** </br> </div>

**This repo hosts a collection of dotfiles for bspwm and various applications I use with it.** </br>

Most of these files will work out of the box assuming you have the applications installed (there is a list below). The file structure is a replica of the expected $HOME structure so installing them is as simple as cloning and linking (or moving if you prefer but linking keeps all your configs in one place). </br>

```
git clone https://github.com/Miusaky/bspdots.git $HOME
cp --remove-destination -as $HOME/bspdots/. $HOME/
```

<h3> Dependencies </h3>

| FUNCTION  | NAME | 
| :----------: |:----------: |
| **WM** | **BSPWM** |
| **TERM** | **KITTY** |
| **BAR** | **POLYBAR** |
| **COMPOSITOR** | **PICOM** |
| **LAUNCHER** | **ROFI** |
| **MUSIC SERVER** | **MPD** |
| **MUSC PLAYER** | **NCMPCPP** |
| **BROWSER** | **FIREFOX** |
</br>

In addition there are a number of utilities I use which make life easier such as fzf, redshift and colorer. You can pick and choose the ones you want but please see the additional notes section below for hard dependencies. 

</br>



<h3> Additional notes </h3>


* If you like the colour scheme you can find it [here](https://github.com/SAGAtheme/SAGA) and *some* pre-written themes [here](https://github.com/SAGAtheme/).
* Some bar modules require additional dependencies to work:
    * CPU modules require lm_sensors.
    * Pipewire (available but not enabled out of the box) requires pamixer.
    * Update module requires the xbps package manager (Void Linux). If you're on Arch you can install [this pkg](https://aur.archlinux.org/packages/checkupdates+aur) and replace the command in the config. 
    * VPN module (available not but enabled) requires Mullvad but can be adapted to other providers.
    * Menus and VPN modules make use of rofi to some extent. 
    * GPU modules require an Nvidia card (and the their drivers).
* The rofi powermenu uses loginctl. Replace the config entries with systemctl if you're using systemd. 
* The included .zshrc depends on the (also included) antigen file to automatically install plugins. Do not use one without the other. 
* If fonts are not rendering make sure you run `fc-cache -v` after linking the files. </br>
* I use [colorer](https://github.com/kiddae/colorer) to switch colour schemes. [SAGA](https://github.com/SAGAtheme/SAGA) is the default palette and if you're satisfied with that you don't need to install colorer as long as you keep its config files ($HOME/.config/colorer). If you do want to test other colours there are quite a few included in $HOME/.config/colorer/flavours. To switch you need to install [colorer](https://github.com/Kiddae/colorer) and run `colorer $HOME/.config/colorer/flavours/schemename`. 
* Fonts, GTK theme and icons are included but you will have to switch to them (either via the config file or something like lxappearance). The font I use is Iosevka Term Heavy.
* The Firefox theme is not included but can be found [here](https://github.com/SAGAtheme/Firefox).
</br>

## BASIC KEY BINDINGS
| KEY  | FUNCTION | 
| :----------: |:----------: |
| **MOD + RETURN** | **KITTY** |
| **MOD + BACKSPACE** | **FIREFOX** |
| **MOD + C** | **CLOSE FOCUSED CLIENT** |
| **ALT_L + F1** | **ROFI** |
| **MOD + M** | **NCMPCPP** |
| **MOD + R** | **ENABLE REDSHIFT** |
| **MOD + SHIFT + R** | **DISABLE REDSHIFT** |

</br>
Look in sxhkdrc for the rest. The above should allow you to adjust the setup to your own preferrences. MOD is Mod4 or what is commonly referred to as the Windows key. If you have https://github.com/hanschen/ksuperkey installed pressing mod4 once will open rofi whilst still functioning as the main modifier. Highly recommend it. 


## GALLERY
<details>
  <summary>Click to expand.</summary>
  
 #### SAGA
 ##### WALL
 <img src="assets/WALL.png"></br> 
 ##### DUNST
 <img src="assets/DUNST.png"></br> 
 ##### ROFI
 <img src="assets/ROFI.png"></br> 
 <img src="assets/POWERMENU.png"></br> 
 ##### FIREFOX
 <img src="assets/FOX.png"></br> 
 ##### GTK
 <img src="assets/GTK.png"></br> 
 ##### LOGSEQ
 <img src="assets/LOGSEQ.png"></br> 
 ##### NCMPCPP
![](assets/NCMPCPP.gif) </br>
 ##### GEDIT
 <img src="assets/GEDIT.png"></br> 
 ##### HELIX
 <img src="assets/HELIX.png"></br> 
 ##### COLORER SUPPORT
 ![](assets/COLOUR_SAMPLES.gif) </br>
</details>

## TODO

## ACKNOWLEDGEMENTS
- [Kiddae](https://github.com/kiddae) for developing colorer :heart:
- [Siduck](https://github.com/siduck) whose dotfiles I've used for inspiration on several occasions :heart:
- [adi1090x](https://github.com/adi1090x) for the beautiful ncmpcpp config :heart:
- [Manas140](https://github.com/Manas140) for a few scripts :heart:
- [Elenapan](https://github.com/elenapan) for the rofi-yt script :heart:

<p align="center"><img src="https://raw.githubusercontent.com/catppuccin/catppuccin/dev/assets/footers/gray0_ctp_on_line.svg?sanitize=true" /></p>
