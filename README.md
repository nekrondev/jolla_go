## Jolla Go 1.4.2 / 1.5 / 1.6 runtime setup for MerSDK

***GO-QML bindings have been updated with https://github.com/SjB/qml/tree/go1.6-port to fix panic issues (Go pointers into c land are not allowed from go1.6 onwards and SjB kindly fixed this issue!).***

Quick installation instructions for vanilla MerSDK VM<br>
- Log into MerSDK VM as mersdk (ssh mersdk@127.0.0.1) (you should add your public/private ssh key to your setup)
- Clone repository into home by executing git clone https://github.com/nekrondev/jolla_go.git ~/tmp
- Copy content of ~/tmp/ into your home folder mv ~/tmp/* ~/
- Make sure that setup script is executable chmod +x ./mersdk_jolla_go.sh
- Make sure that update script for Go 1.5 is executable chmod +x ./mersdk_jolla_go15_upgrade.sh
- Launch setup script ./mersdk_jolla_go.sh
- Optional: If you want to upgrade from Go runtime 1.4 to Go runtime 1.5 execute ./mersdk_jolla_go15_upgrade.sh
- Or Optional: If you want to upgrade from Go runtime 1.4 to Go runtime 1.6 execute ./mersdk_jolla_go16_upgrade.sh

After script has launched it will take some time to build the Jolla Go runtime on MerSDK.<br>
As a bonus I included the world famous dewpoint calculator source. You can compile it by doing the following steps after 
GO runtime has been created:<br>

 - cd ~/src/dewpointcalc
 - mb2 build (will build the i486 RPM for EMU)
 - mb2 -t SailfishOS-armv7hl build (will build the ARM RPM for Jolla)
 - ./deploy (Deploy to Emu, you must have Jolla Emu started to do this)
 
More infos and discussion can be found at https://together.jolla.com/question/105098/how-to-setup-go-142-runtime-and-go-qml-pkg-for-mersdk/

Installation and compilation will take approx. 30 - 60 mins depending on your hardware.
