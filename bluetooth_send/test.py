#!/usr/bin/env python3

import bluetooth
import json #code needed: read, write file and send as json.
import base64

class MobileService(object):

    server_sock = None
    port = 1
    client_sock = None
    address = None

    def serve(self):
        self.server_sock=bluetooth.BluetoothSocket(bluetooth.RFCOMM)
        self.server_sock.bind(("",self.port))
        self.server_sock.listen(1)
        print("Advertising...")
        #confirm connection
        self.client_sock, self.address = self.server_sock.accept()
        print("Accepted connection from", self.address)
        self.on_message()

    def on_message(self):
        try:
            while True:
                #receive data
                #received_data = json.loads(client_sock.recv(1024)) #Terminal use bytes not json
                received_data = self.client_sock.recv(1024)
                if len(received_data) == 0: break
                print ("received [%s]" % received_data)

                #send data
                with open("sample_files/1.png","rb") as img:
                    imgdata = base64.b64encode(img.read()).decode('ascii')
                msg = json.dumps({"data": imgdata, "cmd":{"transmit_flag":True}}) #add cmd type here
                self.client_sock.send("You are connected to the service") #send msg; for testing we send a normal string

                #on receiving end of android: #only as reference in this file
                #imgdata = received_data["data"]
                #with open("newimg.png","wb") as imgwrite:
                #    imgwrite.write(base64.b64decode(imgdata.encode('ascii')))

        except IOError:
            pass
        self.disconnected()

    def disconnected(self):
        print("disconnected")
        self.client_sock.close()
        self.server_sock.close()
        self.reconnect()

    def reconnect(self):
        self.serve()

if __name__ == '__main__':
    service = MobileService().serve()
