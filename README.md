# i3-ansible

Ansible script to setup [i3wm](https://i3wm.org/) on the Ubuntu [mini.iso](https://help.ubuntu.com/community/Installation/MinimalCD).

## STATUS

This is still an active work in progress. It may change, it may break as I work through it.

## How to Use

- Coming Soon

## Gotchas

- `deploy.sh` will not bootstrap properly yet; chicken and the egg.
- Since this is based off of the [mini.iso](https://help.ubuntu.com/community/Installation/MinimalCD) (barebones base), wifi will not work during the install (uses the TUI netboot installer currently). I used a usb ethernet adapter to install, then after I booted in for the first time (with the ethernet attached) I ran `sudo apt install network-manager -y` which will get you the `nmtui` command to config the wifi.

## Default Config Notes

I'm just casually documenting some of the default software that people may not be used to (for a default).

- zsh shell w/ oh-my-zsh
- p10k prompt
- `nmtui` used to cfg the network.
