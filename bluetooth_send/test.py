import bluetooth
import json #code needed: read, write file and send as json.
import requests

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
        filedata = str(open("/home/root/1.png","rb")) #something is not working
        msg = json.dumps({"data": filedata, "cmd":{"transmit_flag":True}}) #add cmd type here
        client_sock.send(msg)

except IOError:
    pass

print("disconnected")
client_sock.close()
server_sock.close()
