import json
from helper_class import *

class rect_ex:
    Rect = None
    Rotate = 0
    RotateRect = None

    def __init__( self, Pos, Size ):
        self.Rect = rect( Pos, Size )


class map:
    MinPoint = vec2( 0, 0 )
    MaxPoint = vec2( 640, 480 )
    Size = vec2( 640, 480 )
    Rect = rect( vec2( 320, 240 ), Size )

    CollisionRects = []
    BattleAreaRects = []
    SpawnTrigger = None

    def __init__( self ):
       with open( 'data/map_last_sesson.mrt' ) as data_file:    
           data = json.load( data_file )
       self.MinPoint.X = data[ 'MapSize' ][ 0 ][ 0 ]
       self.MinPoint.Y = data[ 'MapSize' ][ 0 ][ 1 ]
       self.MaxPoint.X = data[ 'MapSize' ][ 1 ][ 0 ]
       self.MaxPoint.Y = data[ 'MapSize' ][ 1 ][ 1 ]

       self.Size.X = self.MaxPoint.X - self.MinPoint.X
       self.Size.Y = self.MaxPoint.Y - self.MinPoint.Y
       self.Rect.MinPos = self.MinPoint
       self.Rect.MaxPos = self.MaxPoint

       for Rect in data[ 'Rects' ]:
           Pos = vec2( Rect[ "Pos" ][ 0 ], Rect[ "Pos" ][ 1 ] )
           Size = vec2( Rect[ "Size" ][ 0 ], Rect[ "Size" ][ 1 ] )
           
           assert Size.X > 0 and Size.Y > 0, 'Map rect size < 0'

           NewRect = rect_ex( vec2( 0, 0 ), vec2( 0, 0 ) ) #TODO good init
           NewRect.Rect.MinPos = Pos
           NewRect.Rect.MaxPos = Pos + Size
           NewRect.Rect.CalcRect()

           if Rect[ "Rotate" ]:
               NewRect.Rotate = Rect[ "Rotate" ]
               RotateRect = Rect[ "RotateRect" ]
               
               PosR = vec2( RotateRect[ 0 ], RotateRect[ 1 ] )
               SizeR = vec2( RotateRect[ 2 ], RotateRect[ 3 ] )
               NewRect.RotateRect = rect( vec2( 0, 0 ), vec2( 0, 0 ) )
               NewRect.RotateRect.MinPos = PosR
               NewRect.RotateRect.MaxPos = PosR + SizeR
               NewRect.RotateRect.CalcRect()
               #print "NewRect.Rotate", NewRect.Rotate

           #NewRect.Print()
           if Rect[ "Name" ] == 'battle_area':
               self.BattleAreaRects.append( NewRect.Rect )
               NewRect.Rect.Print()
           else:
               self.CollisionRects.append( NewRect )
                       
       for Trigger in data[ 'Triggers' ]:
           if Trigger[ "TriggerType" ] == "spawn":
               Pos = vec2( Trigger[ "Pos" ][ 0 ], Trigger[ "Pos" ][ 1 ] )
               Size = vec2( Trigger[ "Size" ][ 0 ], Trigger[ "Size" ][ 1 ] )
               
               assert Size.X > 0 and Size.Y > 0, 'Map Trigger size < 0'
               
               NewRect = rect( vec2( 0, 0 ), vec2( 0, 0 ) ) #TODO good init
               NewRect.MinPos = Pos
               NewRect.MaxPos = Pos + Size
               NewRect.CalcRect()
               #NewRect.Print()
               self.SpawnTrigger = NewRect
       
       assert self.SpawnTrigger, 'no SpawnTrigger'
       print( "load map", self.MinPoint.X, self.MinPoint.Y, self.MaxPoint.X, self.MaxPoint.Y )


    def CheckCollisionByPlane( self, Rect, Angle, PlayerRect ):
        Point1 = Rect.MinPos
        Point2 = Point1 + vec2( Rect.Size.X, 0 )
        Point3 = Point1 + vec2( Rect.Size.X, Rect.Size.Y )
        Point4 = Point1 + vec2( 0, Rect.Size.Y )

        PlRectPoint1 = PlayerRect.Pos
        
        RotatePoint1 = Point1
        RotatePoint2 = RotatePoint( Point2, Angle, Point1 )
        RotatePoint3 = RotatePoint( Point3, Angle, Point1 )
        RotatePoint4 = RotatePoint( Point4, Angle, Point1 )

        if DistToNormPlane( RotatePoint1 - RotatePoint2, RotatePoint1, PlRectPoint1 ) >= 0: return False
        if DistToNormPlane( RotatePoint2 - RotatePoint3, RotatePoint2, PlRectPoint1 ) >= 0: return False
        if DistToNormPlane( RotatePoint3 - RotatePoint4, RotatePoint3, PlRectPoint1 ) >= 0: return False
        if DistToNormPlane( RotatePoint4 - RotatePoint1, RotatePoint4, PlRectPoint1 ) >= 0: return False

        return True


    def CheckCollision( self, PlayerRect ):
        if not PlayerRect.InRect( self.Rect ):
            return True

        for RectEx in self.CollisionRects:
            if RectEx.RotateRect:
                if RectEx.RotateRect.CrossRectFast( PlayerRect ):
                    return self.CheckCollisionByPlane( RectEx.Rect, RectEx.Rotate, PlayerRect )
            else:
                if RectEx.Rect.CrossRectFast( PlayerRect ):
                    return True
        
        return False