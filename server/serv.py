#!/usr/bin/env python
# -*- coding: utf-8 -*-

#IS A NOT START FILE!!!!
import socket

sock = socket.socket()
sock.bind(('', 8082))
sock.listen(10)
sock.setblocking(0)
#conn, addr = sock.accept()
#
#print 'connected:', addr


def UpdateConnection( Clients, Adrrs, Socets ):   
    try: client, addr = Socets.accept()
    except socket.error: # данных нет
        pass # тут ставим код выхода
    else: # данные есть
        print '+connected:', addr
        client.setblocking(0) # снимаем блокировку и тут тоже        
        Clients.append( client )
        Adrrs.append( addr )

def UpdateClients( Clients ):
    Counter = 0
    for Client in Clients:
        Counter += 1
        try: data = Client.recv(1024)
        except socket.error: # данных нет
            pass # тут ставим код выхода
        else:
            if not data:
                continue
            Client.send(data.upper())
            print "Client num", Counter
            print "data:", data

Sc = []
Ad = []

while True:
    UpdateConnection( Sc, Ad, sock )
    UpdateClients( Sc )


conn.close() 