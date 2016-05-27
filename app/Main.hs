module Main where

import Lib
import Types
import Graphics.Gloss
import Graphics.Gloss.Interface.Pure.Game


window :: Display
window = InWindow "endless-runner" (width, height) (offsetx, offsety)

startPlayer :: Player
startPlayer = Player {
    playerSpeed = 0,
    playerAcc = 0,
    playerLoc = (-300 , 0),
    playerH = 50,
    playerW = 50,
    playerAlive = True,
    playerScore = 0,
    playerJumpCount = 0,
    playerLives = 3
}

delBlocks :: Player -> [Block]->[Block]
delBlocks pl [] = []
delBlocks pl b = filter(\bl->not(blockIntersection pl bl)) b
{-delBlocks pl (b:bs)
   | fst (blockLoc b) > fst(playerLoc pl) - (playerW pl) - 100 = (b : bs)
   | otherwise = delBlocks pl bs
-}

blockIntersection :: Player -> Block -> Bool
blockIntersection p b = abs(x1-x2)<=w && abs(y1-y2)<=h
    where 
        (x1, y1) = playerLoc p
        (x2, y2) = blockLoc b
        w = (blockW b) / 2 + (playerW p) / 2
        h = (blockH b) / 2 + (playerH p) / 2

blocksIntersection :: Player -> [Block] -> Int
blocksIntersection _ [] = 4
blocksIntersection p (x:xs) = if (blockIntersection p x) then bonus x
 --  if (isBon) then 2 else 1
    else blocksIntersection p xs
 --          where
 --             isBon = bonus x

--update player in world
updatePlayer :: Time -> WorldState -> WorldState
updatePlayer tm (World p b t) = if ((not(playerAlive p)) || (bl && (l==1))) 
     then (World (p {playerAlive = False}) (delBlocks p b) t)
     else if (bl && (l>1)) 
          then (World (p {playerLoc = (x , y), playerSpeed = v, playerScore = s, playerLives=l-1, playerJumpCount = kl}) b t)
          else if (bon)
               then (World (p {playerLoc = (x , y), playerSpeed = v, playerScore = s+1*fps, playerLives=l, playerJumpCount = kl}) b t)
          else if (extra_life)
               then (World (p {playerLoc = (x , y), playerSpeed = v, playerScore = s, playerLives=l+1, playerJumpCount = kl}) b t)
	  else
		(World (p {playerLoc = (x , y), playerSpeed = v, playerScore = s, playerJumpCount = kl}) b t)
     where 
            bl = if ((blocksIntersection p b) == 0) then True else False
            bon = if ((blocksIntersection p b) == 1) then True else False
            extra_life = if ((blocksIntersection p b) == 2) then True else False
            (x0, y0) = playerLoc p
            x = x0
            l = playerLives p
            y = y0 + (playerSpeed p) * tm
            s = playerScore p
            k = playerJumpCount p
            kl = if (y <=1) then 0
                  else k
            v = if(y <= 1) then 0.0
                else
                (playerSpeed p) - gravity


--update all coord
updatePos :: Time -> WorldState -> WorldState
updatePos t w = (updatePlayer t (updateBlocks t w))

--update block list
updateBl :: Time -> [Block] -> [Block]
updateBl tm b = map (\bl -> updateOneBlock tm bl) b 

--update one block position
updateOneBlock :: Time -> Block -> Block
updateOneBlock t bl = (bl {blockLoc = (x, y)})
    where
        (x0, y0) = blockLoc bl
        x = x0 - (blockSpeed bl)
        y = y0

--update blocs in world
updateBlocks :: Time -> WorldState -> WorldState
updateBlocks tm (World p b t) = (World p (updateBl tm b) t)

--update world
updateWorld :: Time -> WorldState -> WorldState
updateWorld tm (World p b t) = addBlock (updatePos tm (World p (delBlocks p b) (t + 1))) 

--init world
startWorld :: WorldState
startWorld = World startPlayer [] 0

--create new block
makeBlock :: [Block] -> Time -> [Block]
makeBlock b 130 = ((Block{blockSpeed = startVel, blockLoc = (348, -25+10), blockH = 20, blockW = 10, addingTime = 130, bonus = 0}):b)
makeBlock b 65 = ((Block{blockSpeed = startVel, blockLoc = (348,-25+15), blockH = 30, blockW = 30, addingTime = 65, bonus = 0}):b)


makeBonus :: [Block] -> Time -> [Block]
makeBonus b 230 = ((Block{blockSpeed = startVel, blockLoc = (348,30), blockH = 30, blockW = 10, addingTime = 65, bonus = 1}):b)
makeBonus b 999 = ((Block{blockSpeed = startVel, blockLoc = (348,25), blockH = 30, blockW = 30, addingTime = 65, bonus = 2}):b)

--add new block to world
addBlock :: WorldState -> WorldState
addBlock (World p b t) = if ((truncate t) `mod` 130 == 0) then (World p (makeBlock b 130) t)
	else if ((truncate t) `mod` 65) == 0 then (World p (makeBlock b 65) t)
        else if ((truncate t) `mod` 230) == 0 then (World p (makeBonus b 230) t)
	else if ((truncate t) `mod` 999) == 0 then (World p (makeBonus b 999) t)
	else (World p b t)
addBlock w = w 

--pressing key
handleKey :: Event -> WorldState -> WorldState
handleKey  (EventKey (SpecialKey KeyUp) Down _ _)(World p b t) = if (playerJumpCount p == 2) then (World p b t) 
	else (World (p{playerSpeed = jumpVel, playerJumpCount = k+1}) b t)
	where 
		k = playerJumpCount p 
handleKey  (EventKey (Char 'r') Down _ _)(World p b t) = startWorld
handleKey  _ w = w

--drawing 

ground = polygon [
    (350, 175),
    (350, -175),
    (-350, -175),
    (-350, 175)
    ]

sky = polygon [
    (350, 350),
    (350, -175),
    (-350, -175),
    (-350, 350)
    ]

playerPic :: Player -> Picture
playerPic pl = polygon [
                    (0, 25),
                    (25, 12),
                    (25, -12),
                    (0, -25),
                    (-25, -12),
                    (-25, 12)
    ]

finishPic = polygon [
    (350, 175),
    (-350, 175),
    (-350, -175),
    (350, -175)
    ]

blockOnePic :: Block -> Picture
blockOnePic bl | bonus bl ==1 = polygon [
                    (0, y),
                    (-x, 10),
                    (-x, -10),
                    (0, -y),
                    (x, -10),
                    (x, 10)
                    ]
		| bonus bl ==2 = polygon [
                    (0, 5),
                    (-5, y),
                    (-10, y),
                    (-x, 0),
                    (0, -y),
		    (x, 0),
                    (10, y),
                    (5, y)
                    ]
		| otherwise = polygon [
                    (-10, -y),
                    (-x, -10),
                    (-10, -5),
                    (-x, 5),
                    (-5, y),
                    (0, 10),
                    (5, y),
                    (x, 5),
                    (10, -5),
                    (15, -10),
                    (10, -y)]
{-		| bonus bl == 0 = polygon [
                    (0, y*3/5),
                    (-x/3, y),
                    (-x*2/3, y*3/5),
                    (0, -y)
                    (x, y*2/3),
                    (x, -y*2/3),
                    ]
  -}                  where
                        x = blockW bl / 2
                        y = blockH bl / 2

{-isBonus :: Block -> Bool
isBonus b = c
          where 
             c = bonus b
-}
whatColor :: Block -> Color
whatColor b | bonus b == 0 = black
	    | bonus b == 1 = yellow
	    | bonus b == 2 = red

fonPic :: Player -> [Block] -> Picture
fonPic pl bl = pictures ([
    translate (0) (175 - (playerH pl) / 2) (color blue sky),
    translate (0) (-175 - (playerH pl) / 2) (color green ground)
    ] 
    ++
    map (\b -> translate (fst (blockLoc b)) (snd (blockLoc b)) (color (whatColor b) (blockOnePic b))) bl
    ++
    [
    translate (125) (250) (color red (polygon [
                    (0, 10),
                    (-10, 30),
                    (-20, 30),
                    (-30, 0),
                    (0, -30),
		    (30, 0),
                    (20, 30),
                    (10, 30)
                    ]))
    ]    
    ++
    [
    if (playerAlive pl) then translate (150) (200) (color white (text (show (playerLives pl))))
                        else translate (0) (0) (color black finishPic)
    ]
    ++
    [
    translate (-175) (250) (color yellow (polygon [
                    (0, 30),
                    (-10, 20),
                    (-10, -20),
                    (0, -30),
                    (10, -20),
                    (10, 20)
                    ]))
    ]
    ++
    [
    if (playerAlive pl) then translate (-150) (200) (color white (text (show ((playerScore pl) `div` 60))))
                        else translate (0) (0) (color black finishPic)
    ]
    ++
    [
    if (playerAlive pl) then translate (x) (y) (color magenta (playerPic pl))
                        else translate (0) (0) (color black finishPic) 
    ]
    ++
    [
    if (not (playerAlive pl)) then translate (-250) (-40) (color white (text "Press R"))
                              else translate (-100) (-250) (color black (text "GO"))
    ])
    where
        (x,y) = playerLoc pl


renderPic :: WorldState -> Picture
renderPic (World pl bl tm) = fonPic pl bl


main :: IO ()
main = play window background fps startWorld renderPic handleKey updateWorld
