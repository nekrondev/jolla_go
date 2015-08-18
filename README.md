## Jolla Go 1.4.2 runtime setup for MerSDK
Quick installation instructions for vanilla MerSDK VM<br>
- Log into MerSDK VM as mersdk (ssh mersdk@127.0.0.1) (you should add your public/private ssh key to your setup)
- Clone repository into home by executing git clone https://github.com/nekrondev/jolla_go.git ~/
- Make setup script executable chmod +x ./mersdk_jolla_go.sh
- Launch setup script ./mersdk_jolla_go.sh

After script has launched it will take some time to build the Jolla Go runtime on MerSDK.<br>
As a bonus I included the world famout dewpoint calculator source. You can compile it by doing the following steps after 
GO runtime has been created:<br>

 - cd ~/src/dewpointcalc
 - mb2 build (will build the i486 RPM for EMU)
 - mb2 -t SailfishOS-armv7hl build (will build the ARM RPM for Jolla)
 - ./deploy (Deploy to Emu, you must have Jolla Emu started to do this)
 