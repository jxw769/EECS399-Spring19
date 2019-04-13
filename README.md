# EECS399_Spring19
Senior Project II for EECS399 in Spring 2019.

## Updated DDS Project 
In folder `DE10_Standard_AD9913`. Changed board to DE10 Standard from DE1. <br/>**See [DE10 setup](/DE10_Standard_AD9913/documentation/de10_setup.md) for the setup tutorial.**

## Sample Bluetooth Program
In folder `Bluetooth_SPP`. The Linux program is under `Linux_BT_App`; the Android app is under `TerasicBluetooth`. 
Linux_BT_App includes all C++ codes and the make file used by this project. 
The .apk file of the app is under `TerasicBluetooth/bin/`.

## Bluetooth SPP Android App
`btspp.aia` is the Thunkable based Android app that can display scanning images via Bluetooth. Image data via Bluetooth is parsed to JSON from text format and converted to orignal PNG type from base64 JSON string. The app supports continous transmission and display of the scanning images, with a FPS around 0.5~1 due to Bluetooth transmission rate limit. *Can only be imported to [Thunkable Classic Platform](http://app.thunkable.com/?locale=en) (Not Cross Platform ver.).*

### How to use it
* Press **Connect** to connect with a paired device (DE10 for current use).
* **Scan** to accept image data transmission via Bluetooth. Image are displayed in the *Log* section. 
    * Scroll down *Log* to see activity history.
* **Stop** to stop accepting images. 
* **Proceed** to stop accepting images and proceed to the next task. 
* **Clear** to clear *Log* section and delete stored image data.
* **Disconnect** to disconnect from current connected device.

### Screenshots
(not completed)

### References
1. Thunkable Sample Bluetooth Chat App
`btchat.aia` is a sample Android app for Bluetooth SPP communication. It supports tranferring and receiving text data from connected devices. 
2. Used extensions: 
    * JSONTools: https://community.thunkable.com/t/free-jsontools-extension-version-4-released/5447
    * SimpleBase64: https://groups.google.com/d/msg/mitappinventortest/TAkRiwgY1yI/wQBnn6E0CwAJ
