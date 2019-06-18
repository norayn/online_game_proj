import socket


def HexToDec( Hex ):
    if Hex[ 0 ] == "Y":
        return int( Hex[ 1: ], 16 )
    elif Hex[ 0 ] == "X":
        return -int( Hex[ 1: ], 16 )
    else:
        return int( Hex, 16 )


def DecToHex( Dec, ByteCount ):
    Res = hex( int( Dec ) )[2:]        
    if len( Res ) < ByteCount * 2:
        Res = "0" * ( ByteCount * 2 - len( Res ) ) + Res

    return Res.upper()


def DecToHexS( Dec, ByteCount ):
    if Dec < 0:
        Res = hex( int( -Dec ) )[2:]        
        if len( Res ) < ByteCount * 2:
            Res = "0" * ( ByteCount * 2 - len( Res ) ) + Res

        return "X" + Res.upper()
    else:
        Res = hex( int( Dec ) )[2:]        
        if len( Res ) < ByteCount * 2:
            Res = "0" * ( ByteCount * 2 - len( Res ) ) + Res

        return "Y" + Res.upper()


class connection:
    ClientSocket = None
    Adres = None
    SendBuffer = None
    ResvBuffer = None
    PlayerId = ""

    def __init__( self ):
        self.SendBuffer = []
        self.ResvBuffer = []
        self.PlayerId = "none"


class net:
    sock = socket.socket()
    AddNewConnFunc = None
    Connections = []
    DebugSendedByte = 0
    DebugResvedByte = 0

    def __init__( self, Port, MaxConnections, AddNewConnFunc ):
       # self.sock.setsockopt( SOL_SOCKET, SO_REUSEADDR, 1 )
        self.sock.bind( ( '', Port ) )
        self.sock.listen( MaxConnections )
        self.sock.setblocking( 0 )
        self.sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        self.AddNewConnFunc = AddNewConnFunc
        #print "SO_SNDBUF", self.sock.getsockopt( socket.SOL_SOCKET, socket.SO_SNDBUF )


    def Update( self ):
        for Connection in self.Connections:
            #InData = self.RecvClientData( Connection )
            #if InData:
            #    Connection.ResvBuffer.append( InData )

            while Connection.SendBuffer:
                SendData = Connection.SendBuffer[ 0 ]
                #print "PlayerId", Connection.PlayerId, "SendData", SendData
                if self.SendClientData( Connection, SendData ):
                    Connection.SendBuffer.pop( 0 )
                else:
                    break

        self.UpdateConnection()
                                    

    def UpdateConnection( self ):
        Connection = connection()
        try: ClientSocket, Addr = self.sock.accept()
        except socket.error: # no data
            pass # exit code
        else:
            print 'connected:', Addr, 'fileno():', ClientSocket.fileno()         
            ClientSocket.setblocking( 0 ) 
            Connection.ClientSocket = ClientSocket            
            Connection.Adres = Addr
            self.Connections.append( Connection )
            self.AddNewConnFunc( Connection )           
  

    #def UpdateSend( self, Connection ):
               

    #def UpdateRecv( self, Connection ):
      
              
    def CloseConnection( self, Connection ):
        self.Connections.remove( Connection )
        Connection.ClientSocket.close()
        print 'disconnected:', Connection.Adres
        
           
    def RecvClientData( self, Connection ):
        try: Data = Connection.ClientSocket.recv(1024)
        except socket.error: # no data     
            pass # exit code
        else:
            if not Data:
                return None

            self.DebugResvedByte += len( Data )
            return Data            


    def SendClientData( self, Connection, Data ):
        self.DebugSendedByte += len( Data )
        #print "SendClientData", Data
        try: Connection.ClientSocket.send( Data )
        except socket.error: # no data
            print "SendClientData socket.error"
            return False
            pass # exit code

        return True


    def SendToClient( self, Connection, Cmd, Data ):        
        SendData = str( DecToHex( Cmd, 1 ) ) + str( Data ) + "\n"
        
        #if Cmd == 5:       #for net test
        #     SendData = SendData + SendData + SendData + SendData + SendData

        if not Connection.SendBuffer or len( Connection.SendBuffer[ - 1 ] ) > 4096:
            Connection.SendBuffer.append( SendData )
        else:
             Connection.SendBuffer[ - 1 ] = Connection.SendBuffer[ - 1 ] + ( SendData )
             