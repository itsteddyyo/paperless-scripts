# paperless-scripts

## Steps
1. ```Install Raspberry PI OS 32-bit Full```
2. ```sudo -s```
3. ```apt update && apt upgrade```
4. ```apt install libsane1 img2pdf jq```
5. ```exit```
6. ```git clone https://github.com/itsteddyyo/paperless-scripts.git```
7. ```export hostname=XXX```
8. ```export auth_token=XXX```
9. ```scan2paperless -dr --type=auto```