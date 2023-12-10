# paperless-scripts

## Steps
1. ```Install Raspberry PI OS 32-bit Full```
2. ```sudo apt update && sudo apt upgrade```
3. ```sudo apt install libsane1 jq libqpdf-dev```
4. ```python3 -m pip install --upgrade pip```
5. ```pip3 install --no-deps img2pdf```
6. ```sudo ln /usr/share/color/icc/colord/sRGB.icc /usr/share/color/icc/sRGB.icc```
7. ```git clone https://github.com/itsteddyyo/paperless-scripts.git```
8. ```export hostname=XXX```
9. ```export auth_token=XXX```
10. ```scan2paperless -dr --type=auto```