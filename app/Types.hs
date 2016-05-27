module Types where

import Graphics.Gloss

type Speed = Float
type Accsel = Float
type Time = Float

startVel :: Float
startVel = 10

height :: Int
height = 700

width :: Int
width = 700

offsetx :: Int
offsetx = 100

offsety :: Int
offsety = 100

jumpVel :: Float
jumpVel = 250

gravity :: Float
gravity = 10

fps :: Int
fps = 60	

background :: Color
background = makeColor 0.5 0.5 0.5 1.0

playerClr :: Color
playerClr = makeColor 1.0 1.0 1.0 1.0

spickesClr :: Color
spickesClr = makeColor 0.0 0.0 0.0 1.0

blwidth :: Int
blwidth = 20

blheighth :: Int
blheighth = 20

data WorldState = World Player [Block] Time

data Player = Player {
playerSpeed :: Speed,
playerAcc :: Accsel,
playerLoc :: (Float, Float),
playerH :: Float,
playerW :: Float,
playerAlive :: Bool,
playerScore :: Int,
playerJumpCount :: Int,
playerLives :: Int
}

data Block = Block{
blockSpeed :: Speed,
blockLoc :: (Float, Float),
blockH :: Float,
blockW :: Float,
addingTime :: Time,
bonus :: Int
}
