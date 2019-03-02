import bluetooth
import json #code needed: read, write file and send as json.

server_sock=bluetooth.BluetoothSocket(bluetooth.RFCOMM)
port = 1
server_sock.bind(("",port))
server_sock.listen(1)

client_sock, address = server_sock.accept()
print ("Accepted connection from", address)

try:
    while True:
        data = client_sock.recv(1024)
        if len(data) == 0: break
        print ("received [%s]" % data)
        client_sock.send("hello!")
except IOError:
    pass

print("disconnected")
client_sock.close()
server_sock.close()
