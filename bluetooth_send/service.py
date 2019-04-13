#!/usr/bin/env python3
import bluetooth
import json
import base64

class MobileService(object):
    img_dir = "sample_files/1.png" #directory of the image
    server_sock = None
    port = 1
    client_sock = None
    address = None

    send_flg = False #if true, send new image; it is used to continuously send image data
    proceed_flg = False #if user press the button, proceed to the next task
    center_flg = False #if the carotid is in center; This is the "detect circle file being written in MATLAB; 
                       #if the carotid is not in the center when proceed is called, nothing happens. 

    out_of_time = False #times out if no bluetooth input in 30s

    def init(self):
        self.send_flg = False
        self.proceed_flg = False
        self.center_flg = False
        self.out_of_time = False

    def time_ran_out(self): #can be used to construct a "timeout" function - currently not used
        print("Timeout")
        self.out_of_time = True

    def serve(self):
        self.server_sock=bluetooth.BluetoothSocket(bluetooth.RFCOMM)
        self.server_sock.bind(("",self.port))
        self.server_sock.listen(1)
        print("Advertising...")
        self.client_sock, self.address = self.server_sock.accept()
        print("Accepted connection from", self.address)
        self.on_connect()

    def on_connect(self):
        try:
            while not self.out_of_time:
                received_data = self.client_sock.recv(1024)

                if len(received_data) == 0: break

                json_msg = json.loads(received_data.decode('utf8'))
                self.handle_received_data(json_msg)

        except IOError:
            print("error has been detected")

        self.disconnect()

    def handle_received_data(self,received_data):
        print ("received data: %s" % received_data)

        #read in data
        self.send_flg = received_data['send_flg']
        self.proceed_flg = received_data['proceed_flg']

        #handle message
        if self.send_flg == True:
            self.img_read_and_send()

        if self.proceed_flg and self.center_flg:
            self.proceed_task()
        elif self.proceed_flg and self.center_flg == False:
            print("ERROR: Carotid is not centered yet!")

        #set to default values 
        self.send_flg = False
        self.proceed_flg = False

    def img_read_and_send(self):
        with open(self.img_dir,"rb") as img:
            imgdata = base64.b64encode(img.read()).decode('ascii')
        msg = json.dumps({"data": {'image':imgdata}}) #around 200 kb

        self.bt_send(msg)
        print("new image sent")

        ##################################################################
        # Note:                                                          #
        # on receiving end of android: (only as reference in this file)  #
        # imgdata = received_data["data"]                                #
        # with open("newimg.png","wb") as imgwrite:                      #
        #     imgwrite.write(base64.b64decode(imgdata.encode('ascii')))  #
        ##################################################################

    def bt_send(self,msg):
        self.client_sock.send(msg)

    def proceed_task(self):
        print("proceeding with task...")

    def disconnect(self):
        print("disconnected")
        self.client_sock.close()
        self.server_sock.close()

if __name__ == '__main__':
    while True:
        int = MobileService().init()
        service = MobileService().serve()
