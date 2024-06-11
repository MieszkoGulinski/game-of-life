
# Game of Life implementation in Rexx (BREXX/370) for MVS TK5

This implementation improves over [this implementation](https://github.com/moshix/mvs/blob/master/life.rexx), demonstrated [in this video](https://www.youtube.com/watch?v=JzIyFzF6y9Q).

## How to use

Valid user commands are:
- empty string (just pressing Enter) - proceed to the next generation
- `clear` - clear the board
- `random` - set the board to a random state
- `x y` where x and y are numbers - toggle the cell at position (x, y) on/off (the coordinates are 0-based)

Also, a name of a predefined state can be used as a command - the predefined states are:
```
block
beehive
loaf
...
```
See the list [here](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life#Examples_of_patterns) for the patterns.

Pressing F3 closes the program.

## Implementation

1. Allocate two 2D arrays of size WxH, one for the current state and one for the next state.
2. Initialize the current state with empty values.
3. Display the current state.
3. Wait for user input. Because of the platform limitations, user can enter only text. So the user can manually toggle on/off a given cell, clear the board, set the board to a predefined or random state, or just press Enter (no command) to proceed to the next generation. If the pressed key is not Enter but F3, the program exits.
4. For each generation, calculate the next state based on the current state. 
5. Swap the current state with the next state. This is very fast because the arrays are accessed by reference.
6. Go to step 3.

Cells out of the board are considered unpopulated.

## How to upload the code to MVS TK5 and run it

You can use the FTP feature of Hercules to upload the code to MVS TK5. The code can be uploaded as a text file, and then you can use the `RX` command to run it.