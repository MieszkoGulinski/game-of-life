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
blinker
toad
beacon
glider
```

TODO: add more predefined patterns

See the list [here](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life#Examples_of_patterns) for the patterns.

Pressing F3 closes the program. Pressing F1 opens help screen.

## Implementation

1. Allocate two 1D integer arrays of size WxH, one for the current state and one for the next state. Floating point matrices did not work because they introduce rounding errors.
2. Initialize the current state with empty values.
3. Display the current state.
4. Wait for user input. Because of the platform limitations, user can enter only text. So the user can manually toggle on/off a given cell, clear the board, set the board to a predefined or random state, or just press Enter (no command) to proceed to the next generation. If the pressed key is not Enter but F3, the program exits.
5. For each generation, calculate the next state based on the current state.
6. Swap the current state with the next state. This is very fast because the arrays are accessed by reference.
7. Go to step 3.

Cells out of the board are considered unpopulated.

## How to upload the code to MVS TK5 and run it

You can use the FTP feature of Hercules to upload the code to MVS TK5. The code can be uploaded as a text file, and then you can use the `RX` command to run it.

To start FTP on TK5, after the OS starts, run `/s ftpd` command in the Hercules main console. Then duplicate the `life.rexx` file into `life` (without extension) and upload the file using FTP in ASCII mode. In the Linux command-line FTP client, this is done by:

1. To duplicate the file `life.rexx` into `life`: `cp life.rexx life`
1. To open the FTP client: `ftp localhost 2121` (after running this command, you should be prompted for username and password)
1. To list content of the currently active directory (or the root of the file system): `ls`
1. To enter the BREXX samples directory: `cd BREXX.V2R5M3.SAMPLES`
1. To set ASCII mode: `asci`
1. To upload the file with the game: `put life`. If the file already exists on the MVS system, this file will be overwritten. Uploading a file with `.rexx` extension fails.
1. To close the FTP client: `quit`
