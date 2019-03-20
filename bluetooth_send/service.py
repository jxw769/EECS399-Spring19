#!/usr/bin/env python3

import bluetooth
import json
import base64

class MobileService(object):

    img_dir = "sample_files/1.png"
    server_sock = None
    port = 1
    client_sock = None
    address = None
    received_flg = False #Android's reaction to receiving img; initiate new cycle of transmission
    proceed_flg = False #if user press the button, proceed
    center_flg = False #if the circle is in center; being updated

    def serve(self):
        self.server_sock=bluetooth.BluetoothSocket(bluetooth.RFCOMM)
        self.server_sock.bind(("",self.port))
        self.server_sock.listen(1)
        print("Advertising...")
        self.client_sock, self.address = self.server_sock.accept()
        print("Accepted connection from", self.address)
        self.on_message()

    def on_message(self):
        try:
            while True:
                #received_data = json.loads(client_sock.recv(1024)) #not used; Terminal use bytes not json
                received_data = self.client_sock.recv(1024)

                if len(received_data) == 0: break

                print ("received data: %s" % received_data)

                #if 'received_flg' in received_data:
                    #self.received_flg = received_data['received_flg']

                if self.received_flg == False: #in reality this should be True (send iff last transmission has been received)
                    self.img_read_and_send()

                if self.proceed_flg and self.center_flg == True:
                    self.proceed_task()

                self.received_flg = False #resetting the flags
                self.proceed_flg = False

        except IOError:
            print("error has been detected")

        self.disconnect()

    def img_read_and_send(self):
        with open(self.img_dir,"rb") as img:
            imgdata = base64.b64encode(img.read()).decode('ascii')
        msg = json.dumps({"data": imgdata}) #around 200 kb

        self.bt_send(msg)

        #################################################################
        #on receiving end of android: (only as reference in this file)  #
        #imgdata = received_data["data"]                                #
        #with open("newimg.png","wb") as imgwrite:                      #
        #    imgwrite.write(base64.b64decode(imgdata.encode('ascii')))  #
        #################################################################

    def bt_send(self,msg):
        self.client_sock.send(msg)

    def proceed_task(self):
        pass #start scanning or whatever

    def disconnect(self):
        print("disconnected")
        self.client_sock.close()
        self.server_sock.close()
        self.reconnect() #automatically start new session

    def reconnect(self):
        self.serve() #there is probably a better way to do this

if __name__ == '__main__':
    service = MobileService().serve()
