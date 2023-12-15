# paperless-scripts

## Steps
1. Install Raspberry PI OS 64-bit Full
2. ```sudo apt update && sudo apt upgrade```
3. ```curl https://raw.githubusercontent.com/bitfocus/companion-pi/main/install.sh | bash```
4. ```sudo apt install libsane1 jq libqpdf-dev```
5. ```python3 -m pip install --upgrade pip```
6. ```pip3 install --no-deps img2pdf```
7. ```sudo ln /usr/share/color/icc/colord/sRGB.icc /usr/share/color/icc/sRGB.icc```
8. ```git clone https://github.com/itsteddyyo/paperless-scripts.git```
9. ```cd paperless-scripts```
10. ```chmod 755 * && sudo cp scan2paperless.sh /usr/local/bin/scan2paperless && sudo cp post2paperless.sh /usr/local/bin/post2paperless && sudo cp watch2scan.sh /etc/init.d/watch2scan```
11. ```sudo update-rc.d watch2scan defaults```
12. Add to ~/.bashrc
    ```
    export hostname=XXX
    export auth_token=XXX
    ```
13. ```scan2paperless -d --type=auto```
