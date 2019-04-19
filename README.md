# EECS399_Spring19
Senior Project II for EECS399 in Spring 2019.

## Updated DDS Project 
In folder `DE10_Standard_AD9913`. Changed board to DE10 Standard from DE1. <br/>**See [DE10 setup](/DE10_Standard_AD9913/documentation/de10_setup.md) for the setup tutorial.**

EAGLE PCB Files and component datasheets are in `AD9913_PCB`.

## Bluetooth SPP Android App
`btspp.aia` is the Thunkable based Android app that can display scanning images via Bluetooth. Image data via Bluetooth is parsed to JSON from text format and converted to orignal PNG type from base64 JSON string. The app supports continous transmission and display of the scanning images, with a FPS around 0.5~1 due to Bluetooth transmission rate limit. *Can only be imported to [Thunkable Classic Platform](http://app.thunkable.com/?locale=en) (Not Cross Platform ver.).*

### How to use it
#### DE10 SoC Setup
* **Make sure DE10 switch setup is the same as below**
   ![DE10 Switch SoC](/Screenshots/switchsoc.PNG) </br>
* Boot up the Linux system.
* Configure Linux such that the device is paired and bluetooth SPP port is enabled. (See below and Ref)
* Execute
```cd ~/eecs399/bluetooth_send/ ```</br>
```./service.py```
  
#### Configuring Bluetooth on Linux
* Management of paired devices is done by bluetoothctl. (Configure etc/bluetooth/main.conf first)
* Once device is paired, we need to open up SPP upon reboot. A sample supervisor file can be found under `supervisor_conf`. If SPP port is not added, bluetooth transmission will not initiate. 
* Dependencies of service.py include PyBluez (for Python3).

#### Service.py
This file is written in mind that in the future, auto-detection of carotid function will be added to the service. The directory in which scanned image file is read and transmitted can be changed. 
One problem with this service file is that no time-out function is added. Therefore if a device is connected and not used (or, more likely, the app suddenly crashed without disconnecting the service), the service file will sit there forever, and must be restarted on Linux. This is not ideal for a product, and the best way is to add a time-out function, i.e. to have De10 automatically disconnect with the Android device if it doesn't receive any command from Android for a certain period of time. 

### Android App
* Press **Connect** to connect with a paired device (DE10 for current use).
* **Scan** to accept image data transmission via Bluetooth. Image are displayed in the (currently disabled) *Log* section. 
    * Scroll down *Log* to see activity history.
* **Stop** to stop accepting images. 
* **Proceed** to stop accepting images and proceed to the next task. 
* **Clear** to clear *Log* section and delete stored image data.
* **Disconnect** to disconnect from current connected device.

### Screenshots

<img src="/Screenshots/App_Icon.png">
<img src="/Screenshots/App_Start_Up.png" width="500">
<img src="/Screenshots/App_Image_Display.png" width="500">
<img src="/Screenshots/De10_Server_Log.png" width="500">
<img src="/Screenshots/ThunkableDesign.PNG" width="500">


### References
1. Thunkable Sample Bluetooth Chat App
`btchat.aia` is a sample Android app for Bluetooth SPP communication. It supports tranferring and receiving text data from connected devices. 
2. Used extensions: 
    * JSONTools: https://community.thunkable.com/t/free-jsontools-extension-version-4-released/5447
    * SimpleBase64: https://groups.google.com/d/msg/mitappinventortest/TAkRiwgY1yI/wQBnn6E0CwAJ
    * PyBluez
3. Configure Bluetooth on Linux
Here are some links that we found useful in setting up bluetooth:
    * Linux Bluetoothctl https://www.intel.com/content/dam/support/us/en/documents/edison/sb/edisonbluetooth_331704007.pdf
    * Setup SPP port (and use RFCOMM) https://unix.stackexchange.com/questions/92255/how-do-i-connect-and-send-data-to-a-bluetooth-serial-port-on-linux
    * Using PyBluez https://people.csail.mit.edu/albert/bluez-intro/x232.html
    
