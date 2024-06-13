/* Implementation of Game of Life for BREXX/370 running on MVS TK5 using FSS mode and integer array extension */

CALL IMPORT FSSAPI
ADDRESS FSS
CALL FSSINIT
CALL FSSTITLE 'Game of Life'
CALL FSSCOMMAND
CALL FSSCURSOR 'ZCMD'
CALL FSSFSET 'ZCMD' ''

width = 10
height = 10

/* We use integer arrays, because writing and reading floating point matrices results in a round-off error */
currentBoard = ICREATE(width * height)
nextBoard = ICREATE(width * height)

/* Main loop */
DO FOREVER
  /* Display the board */
  DO y=1 TO height
    line = ''

    DO x=1 TO width
      cellIndex = (y-1) * width + x /* arrays are 1-indexed */
      cellValue = IGET(currentBoard, cellIndex)
      IF cellValue = 1 THEN
        line = line || '#'
      ELSE
        line = line || ' '
    END

    CALL FSSTEXT line, y+7, 3, , #WHITE+#PROT
  END

  key = FSSREFRESH()
  IF key = 243 THEN LEAVE /* F3 to close the program */
  IF key = 241 THEN CALL displayHelp

  userCommand = FSSFGET('ZCMD')
  CALL runCommand userCommand
  CALL FSSFSET 'ZCMD' ''
  CALL FSSCURSOR 'ZCMD'
END

CALL FSSCLOSE /* Terminate Screen Environment */
RETURN 0

runCommand:
  ARG command

  IF command = 'RANDOM' THEN CALL createRandomBoard
  IF command = 'CLEAR' THEN CALL clearBoard
  IF command = '' THEN CALL performStep
  /* Predefined boards */
  IF command = 'BLOCK' THEN CALL displayBlock
  IF command = 'BEEHIVE' THEN CALL displayBeehive
  IF command = 'BLINKER' THEN CALL displayBlinker
  IF command = 'BEACON' THEN CALL displayBeacon
  IF command = 'GLIDER' THEN CALL displayGlider

  PARSE VALUE command WITH x y
  IF datatype(x) = 'NUM' & datatype(y) = 'NUM' THEN CALL toggleCell(x,y)
RETURN

createRandomBoard:
  DO y=1 TO height
    DO x=1 TO width
      cellIndex = (y-1) * width + x
      CALL ISET(currentBoard, cellIndex, random(0,1))
    END
  END
RETURN

clearBoard:
  DO y=1 TO height
    DO x=1 TO width
      cellIndex = (y-1) * width + x
      CALL ISET(currentBoard, cellIndex, 0)
    END
  END
RETURN

toggleCell:
  ARG x, y

  IF x<1 THEN RETURN
  IF y<1 THEN RETURN
  IF x>width THEN RETURN
  IF y>height THEN RETURN

  cellIndex = (y-1) * width + x

  oldValue = IGET(currentBoard, cellIndex)
  IF oldValue = 1 THEN
    CALL ISET(currentBoard, cellIndex, 0)
  ELSE
    CALL ISET(currentBoard, cellIndex, 1)
RETURN

/* Predefined patterns */

displayBlock:
  CALL clearBoard
  CALL toggleCell(5,5)
  CALL toggleCell(5,6)
  CALL toggleCell(6,5)
  CALL toggleCell(6,6)
RETURN

displayBeehive:
  CALL clearBoard
  CALL toggleCell(5,5)
  CALL toggleCell(6,5)
  CALL toggleCell(4,6)
  CALL toggleCell(7,6)
  CALL toggleCell(5,7)
  CALL toggleCell(6,7)
RETURN

displayBlinker:
  CALL clearBoard
  CALL toggleCell(5,5)
  CALL toggleCell(6,5)
  CALL toggleCell(7,5)
RETURN

displayBeacon:
  CALL clearBoard
  CALL toggleCell(5,5)
  CALL toggleCell(6,5)
  CALL toggleCell(5,6)
  CALL toggleCell(6,6)

  CALL toggleCell(7,7)
  CALL toggleCell(7,8)
  CALL toggleCell(8,7)
  CALL toggleCell(8,8)
RETURN

displayGlider:
  CALL clearBoard
  CALL toggleCell(4,3)
  CALL toggleCell(5,4)
  CALL toggleCell(3,5)
  CALL toggleCell(4,5)
  CALL toggleCell(5,5)
RETURN

/* Actual logic */

performStep:
  DO y=1 TO height
    DO x=1 TO width
      cellIndex = (y-1) * width + x
      currentValue = IGET(currentBoard, cellIndex)
      aliveNeighbors = countAliveNeighbors(x,y)
      newValue = currentValue

      /* Apply Game of Life rules here */
      IF currentValue = 1 & aliveNeighbors < 2 THEN newValue = 0
      IF currentValue = 1 & aliveNeighbors > 3 THEN newValue = 0
      IF currentValue = 0 & aliveNeighbors = 3 THEN newValue = 1

      CALL ISET(nextBoard, cellIndex, newValue)
    END
  END

  /* matrices created by MCREATE are referenced as pointers, not values, so they can be swapped */
  tempBoardPtr = currentBoard
  currentBoard = nextBoard
  nextBoard = tempBoardPtr
RETURN

countAliveNeighbors:
  ARG cx, cy
  neighborsCount = 0

  DO dx = -1 TO 1
    DO dy = -1 TO 1
      nx = cx + dx
      ny = cy + dy

      /* Do not count the cell itself */
      IF dx=0 & dy=0 THEN ITERATE

      /* Boundary condition - cells outside the board are always 0 */
      IF nx>0 & ny>0 & nx<=width & nx<=height THEN DO
        neighborCellIndex = (ny-1) * width + nx
        neighborCellValue = IGET(currentBoard, neighborCellIndex)
        neighborsCount = neighborsCount + neighborCellValue
      END

    END
  END
RETURN neighborsCount

displayHelp:
  SAY 'Commands:'
  SAY ''
  SAY 'random - generates random board'
  SAY 'clear - clears the board'
  SAY '(two numbers with one space between them) - toggle cell on/off'
  SAY '(empty command, just pressing Enter) - evolve the board to next generation'
  SAY ''
  SAY 'block - display block (non-changing shape)'
  SAY 'beehive - display a beehive (non-changing shape)'
  SAY 'blinker - display a blinker (cyclically repeating shape)'
  SAY 'beacon - display a beacon (cyclickally repeating shape)'
  SAY 'glider - display a glider (permanently moving shape)'
RETURN