# 2paco

Generate 2fa codes on your RaspberryPi with an ePpaper display.

* 2 - two step
* pa - paper
* co - codes

## Intro

* This script is written and meant to be used with a Waveshare e-Paper RPi 2.13 inch 3color hat.
https://www.waveshare.com/product/2.13inch-e-paper-hat-b.htm

* Editing `update-ePaper.py` to include another library from the waveshare library should work just fine,
although you might need to play around with the font size and text positioning.

## Software requirements

* Python 3+
`sudo apt install python3`

* [Waveshare library](https://github.com/waveshare/e-Paper)
  
  ```
  git clone https://github.com/waveshare/e-Paper
  sudo python3 e-Paper/RaspberryPi_JetsonNano/python/setup.py install
  ```
  
* GnuPG and oathtool
`sudo apt install gpg oathtool`

## How it works

Just a little heads up:
This script is not considered safe at all, it's just a little home/hobby project I made for fun.

Please do not use it in a release environment. I cannot even count the holes in it.

Anyways:

2paco starts listening on netcat (default port is `9002`).

For testing i just used the same device, stated my request and connected back to 2paco.

`echo IDENTIFIER | nc -q 0 localhost 9002`

You could issue requests from another desktop. E.g.

`echo bitwarden | nc -q 0 raspberrypi.ip 9002`

The screen then updates to the current bitwarden 2FA code and resets when the code's lifetime expires.

The ideal solution for this would be to solder 2 buttons onto the Pi and using them for displaying codes.
Disabling WiFi would essentially be airgapping the device, but that still won't make it even near to being 100% fool-proof.

## Usage

* `./2paco.sh` : Runs 2paco as a daemon.
* `./2paco.sh --add [Identifier]` : Adds a new token for oathtool so it can generate 2FA codes.
* `./2paco.sh --list` : Lists all available identifiers.
* `./2paco.sh --help` : Shows the help message.

## Customizability

You can edit `2paco.sh` and change the following options:

* `mainDir` : Directory where secrets, log and python script should be stored.
* `secretsDir` : Directory where secrets are stored.
* `PASSPHRASE` : Same one you used to encrypt the 2FA tokens.
* `logFile` : Directory and name of the log file.
* `listenPort` : Port on which netcat should listen.
* `rotationTime` : Ammount of seconds in which your 2FA codes rotate (Default is 30s).

You can also add images, which will be printed on the ePaper next to the identifier, inside the `~/.2paco/pic` folder.
For the 2.13 inch display, the dimensions should be `25x25` pixels and the images should use the `.bmp` file format.

As for the other dimension displays, feel free to customize to your heart's content.
