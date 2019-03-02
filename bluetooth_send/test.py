#!/usr/bin/env python3

import bluetooth
import json #code needed: read, write file and send as json.
import base64

server_sock=bluetooth.BluetoothSocket(bluetooth.RFCOMM)
port = 1
server_sock.bind(("",port))
server_sock.listen(1)

#confirm connection
client_sock, address = server_sock.accept()
print ("Accepted connection from", address)

try:
    while True:
        #receive data
#       received_data = json.loads(client_sock.recv(1024)) #Terminal use bytes not json
        received_data = client_sock.recv(1024)
        if len(received_data) == 0: break
        print ("received [%s]" % received_data)

        #send data
        with open("1.png","rb") as img:
            imgdata = base64.b64encode(img.read()).decode('ascii')
        msg = json.dumps({"data": imgdata, "cmd":{"transmit_flag":True}}) #add cmd type here
        client_sock.send(msg)

        #on receiving end of android: #only as reference in this file
        #imgdata = received_data["data"]
        #with open("newimg.png","wb") as imgwrite:
        #    imgwrite.write(base64.b64decode(imgdata.encode('ascii')))

except IOError:
    pass

print("disconnected")
client_sock.close()
server_sock.close()
