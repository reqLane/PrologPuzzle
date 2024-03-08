package java_implementation;

import java.io.Serializable;

import java.io.FileReader;

public final class Board implements Serializable {

    private static final long serialVersionUID = 5914825388221307541L;

    private static final class Position {
        int x;

        int y;
    }

    static final int NSQRT = 4;

    static final int NPUZZLE = NSQRT * NSQRT - 1;

    static final int BRANCH_FACTOR = 4;

    private static Position[] goal = new Position[NPUZZLE + 1];

    static {
        for (int i = 0; i <= NPUZZLE; i++) {
            goal[i] = new Position();
        }

        int v = 0;
        for (int y = 0; y < NSQRT; y++) {
            for (int x = 0; x < NSQRT; x++) {
                goal[v].x = x;
                goal[v].y = y;
                v++;
            }
        }
    }

    private byte[] board;

    private int distance;

    private int bound;

    private int blankX, blankY;

    private int prevDx, prevDy;

    private int depth;

    public Board(int length) {
        board = new byte[NSQRT * NSQRT];

        for (int i = 0; i < board.length; i++) {
            board[i] = (byte) i;
        }
        blankX = 0;
        blankY = 0;

        int n = NSQRT - 1;

        for (int i = 0; i < length; i++) {
            int dx;
            int dy;

            if (blankX == 0 && blankY == 0) {
                if (n == NSQRT) {
                    n = NSQRT - 1;
                } else {
                    n = NSQRT;
                }
            }

            if (blankX == 0 && blankY < n - 1) {
                dx = 0;
                dy = 1;
            } else if (blankY == n - 1 && blankX < n - 1) {
                // right
                dx = 1;
                dy = 0;
            } else if (blankX == n - 1 && blankY > 0) {
                dx = 0;
                dy = -1;
            } else if (blankY == 0 && blankX > 0) {
                dx = -1;
                dy = 0;
            } else {
                throw new Error("not going in any direction");
            }
            move(dx, dy);
        }

        bound = 0;
        prevDx = 0;
        prevDy = 0;
        depth = 0;
        distance = calculateBoardDistance();
    }

    public Board(String fileName) throws Exception {
        board = new byte[NSQRT * NSQRT];
        bound = 0;
        prevDx = 0;
        prevDy = 0;
        depth = 0;

        FileReader fileReader = new FileReader(fileName);

        for (int i = 0; i < board.length; i++) {
            char c;
            do {
                int value = fileReader.read();
                if (value == -1) {
                    throw new Exception("unexpected end of stream while "
                            + "reading characters");
                }
                c = (char) value;
            } while (Character.isWhitespace(c));

            if (c == '.') {
                c = '0';
            }

            int digit = Character.digit(c, 16);
            if (digit == 0) {
                blankX = i % NSQRT;
                blankY = i / NSQRT;
            }
            board[i] = (byte) digit;
        }

        distance = calculateBoardDistance();
    }

    public void init(Board original) {
        System.arraycopy(original.board, 0, board, 0, NSQRT * NSQRT);

        distance = original.distance;
        bound = original.bound;
        blankX = original.blankX;
        blankY = original.blankY;
        prevDx = original.prevDx;
        prevDy = original.prevDy;
        depth = original.depth;
    }

    public Board(Board original) {
        board = new byte[NSQRT * NSQRT];

        init(original);
    }

    private byte getBoardValue(int x, int y) {
        return board[(NSQRT * y) + x];
    }

    private void setBoardValue(byte v, int x, int y) {
        board[(NSQRT * y) + x] = v;
    }

    private int tileDistance(int v, int x, int y) {
        if (v == 0) {
            return 0;
        }

        return Math.abs(goal[v].x - x) + Math.abs(goal[v].y - y);
    }

    private int calculateBoardDistance() {
        int result = 0;
        for (int y = 0; y < NSQRT; y++) {
            for (int x = 0; x < NSQRT; x++) {
                result += tileDistance(getBoardValue(x, y), x, y);
            }
        }
        return result;
    }

    private void move(int dx, int dy) {
        int x = blankX + dx;
        int y = blankY + dy;
        byte v = getBoardValue(x, y);

        bound--;
        distance += -tileDistance(v, x, y) + tileDistance(v, blankX, blankY);
        depth++;

        setBoardValue((byte) 0, x, y);
        setBoardValue(v, blankX, blankY);

        prevDx = dx;
        prevDy = dy;
        blankX = x;
        blankY = y;
    }

    public Board[] makeMoves() {
        Board[] result = new Board[BRANCH_FACTOR];
        int n = 0;

        if (blankX > 0 && prevDx != 1) {
            result[n] = new Board(this);
            result[n].move(-1, 0);
            n++;
        }

        if (blankX < (NSQRT - 1) && prevDx != -1) {
            result[n] = new Board(this);
            result[n].move(1, 0);
            n++;
        }

        if (blankY > 0 && prevDy != 1) {
            result[n] = new Board(this);
            result[n].move(0, -1);
            n++;
        }

        if (blankY < (NSQRT - 1) && prevDy != -1) {
            result[n] = new Board(this);
            result[n].move(0, 1);
            n++;
        }
        return result;
    }

    public Board[] makeMoves(BoardCache cache) {
        Board[] result = new Board[BRANCH_FACTOR];
        int n = 0;

        if (blankX > 0 && prevDx != 1) {
            result[n] = cache.get(this);
            result[n].move(-1, 0);
            n++;
        }

        if (blankX < (NSQRT - 1) && prevDx != -1) {
            result[n] = cache.get(this);
            result[n].move(1, 0);
            n++;
        }

        if (blankY > 0 && prevDy != 1) {
            result[n] = cache.get(this);
            result[n].move(0, -1);
            n++;
        }

        if (blankY < (NSQRT - 1) && prevDy != -1) {
            result[n] = cache.get(this);
            result[n].move(0, 1);
            n++;
        }

        return result;
    }

    public int distance() {
        return distance;
    }

    public int depth() {
        return depth;
    }

    public int bound() {
        return bound;
    }

    public void setBound(int bound) {
        if (depth != 0) {
            System.err.println("warning: setting bound only makes sense at"
                    + "the initial job");
        }
        this.bound = bound;
    }

    public String toString() {
        String result = "";
        for (int y = 0; y < NSQRT; y++) {
            for (int x = 0; x < NSQRT; x++) {
                byte value = getBoardValue(x, y);

                if (value == 0) {
                    result += ".";
                } else {
                    result += Character.forDigit(value, 16);
                }
            }
            result += "\n";
        }
        return result;
    }
}