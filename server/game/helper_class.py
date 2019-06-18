from net_class import DecToHex
from net_class import DecToHexS
from net_class import HexToDec
import math

def ASSERT( ex ):
    if ex == 0:
        print 10 / 0


def clamp( minimum, x, maximum ):
    return max( minimum, min( x, maximum ) )


class vec2:
    X = 0
    Y = 0

    def __init__( self, X, Y ):
        self.X = X
        self.Y = Y

    def __add__( self, Other ):
        return vec2( self.X + Other.X, self.Y + Other.Y )

    def __sub__( self, Other ):
        return vec2( self.X - Other.X, self.Y - Other.Y )

    def __mul__( self, Other ):
        return vec2( self.X * Other.X, self.Y * Other.Y )

    def __truediv__( self, Other ):
        return vec2( self.X /Other.X, self.Y / Other.Y )

    def __eq__( self, Other ):
        return self.X == Other.X and self.Y == Other.Y

    def __ne__( self, Other ):
        return self.X != Other.X or self.Y != Other.Y

    def InRect( self, Rect ):        
        if self.X >= Rect.MinPos.X and self.Y >= Rect.MinPos.Y and self.X < Rect.MaxPos.X and self.Y < Rect.MaxPos.Y:
            return True
        else:
            return False

    def ToHexXY( self, ByteDepth ):       
        return str( DecToHex( self.X, ByteDepth ) ) + str( DecToHex( self.Y, ByteDepth ) )

    def ToHexSigXY( self, ByteDepth ):       
        return str( DecToHexS( self.X, ByteDepth ) ) + str( DecToHexS( self.Y, ByteDepth ) )
               

class rect:
    MinPos = vec2( 0, 0 )
    MaxPos = vec2( 0, 0 )
    Pos = vec2( 0, 0 )
    Size = vec2( 0, 0 )

    def Print( self ):
        print "rect Pos Size", self.Pos.X, self.Pos.Y, self.Size.X, self.Size.Y, "|| min max", self.MinPos.X, self.MinPos.Y, self.MaxPos.X, self.MaxPos.Y

    def CalcRect( self ):
        if self.Size.X == 0 and self.Size.Y == 0:
            self.Size = self.MaxPos - self.MinPos
            HalfSize = vec2( int( self.Size.X / 2 ), int( self.Size.Y / 2 ) )
            self.Pos = self.MaxPos - HalfSize
        else:
            HalfSize = vec2( int( self.Size.X / 2 ), int( self.Size.Y / 2 ) )
            self.MinPos = self.Pos - HalfSize
            self.MaxPos = self.Pos + HalfSize

    def __init__( self, Pos, Size ):
        self.Pos = Pos
        self.Size = Size
        self.CalcRect()

    def SetPos( self, Pos ):      
        self.Pos = Pos       
        self.CalcRect()

    def SetSize( self, Size ):
        self.Size = Size    
        self.CalcRect()

    def InRect( self, Rect ):
        if self.MinPos.X >= Rect.MinPos.X and self.MinPos.Y >= Rect.MinPos.Y and self.MaxPos.X < Rect.MaxPos.X and self.MaxPos.Y < Rect.MaxPos.Y:
            return True
        else:
            return False

    def OutRect( self, Rect ):
        if self.MaxPos.X < Rect.MinPos.X or self.MaxPos.Y < Rect.MinPos.Y or self.MinPos.X >= Rect.MaxPos.X or self.MinPos.Y >= Rect.MaxPos.Y:
            return True
        else:
            return False

    def CrossRectFast( self, Rect ):
        if Rect.MinPos.X > self.MaxPos.X or Rect.MaxPos.X < self.MinPos.X:
           return False
        if Rect.MinPos.Y > self.MaxPos.Y or Rect.MaxPos.Y < self.MinPos.Y:
           return False

        return True
        
    def CrossRectFastWithOffset( self, Rect, Offset ):
        if Rect.MinPos.X + Offset.X > self.MaxPos.X or Rect.MaxPos.X + Offset.X < self.MinPos.X:
           return False
        if Rect.MinPos.Y + Offset.Y > self.MaxPos.Y or Rect.MaxPos.Y + Offset.Y < self.MinPos.Y:
           return False

        return True
        

def RotatePoint( Point, Angle, AxisPoint ):
    X = math.cos( Angle ) * ( Point.X - AxisPoint.X ) - math.sin( Angle ) * ( Point.Y - AxisPoint.Y ) + AxisPoint.X
    Y = math.sin( Angle ) * ( Point.X - AxisPoint.X ) + math.cos( Angle ) * ( Point.Y - AxisPoint.Y ) + AxisPoint.Y
    return vec2( X, Y )    


def DistToNormPlane( NormalizedNormal, PlanePoint, Point ):
    C = -( ( NormalizedNormal.X * PlanePoint.X ) + ( NormalizedNormal.Y * PlanePoint.Y ) )
    return NormalizedNormal.X * Point.X + NormalizedNormal.Y * Point.Y + C