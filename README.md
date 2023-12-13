# paperless-scripts

If Companion is needed install at start! ```curl https://raw.githubusercontent.com/bitfocus/companion-pi/main/install.sh | bash```

## Steps
1. Install Raspberry PI OS 32-bit Full
2. ```sudo apt update && sudo apt upgrade```
3. ```sudo apt install libsane1 jq libqpdf-dev```
4. ```python3 -m pip install --upgrade pip```
5. ```pip3 install --no-deps img2pdf```
6. ```sudo ln /usr/share/color/icc/colord/sRGB.icc /usr/share/color/icc/sRGB.icc```
7. ```git clone https://github.com/itsteddyyo/paperless-scripts.git```
8. ```chmod 755 paperless-scripts/* && sudo cp paperless-scripts/scan2paperless.sh /usr/local/bin/scan2paperless && sudo cp paperless-scripts/post2paperless.sh /usr/local/bin/post2paperless```
9. Add to ~/.bashrc
    ```
    export hostname=XXX
    export auth_token=XXX
    ```
10. ```scan2paperless -d --type=auto```
