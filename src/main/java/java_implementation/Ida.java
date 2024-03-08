package java_implementation;

final class Ida {

    static int solutions(Board board, BoardCache cache) {
        if (board.distance() == 0) {
            return 1;
        }

        if (board.distance() > board.bound()) {
            return 0;
        }

        Board[] children = board.makeMoves(cache);
        int result = 0;

        for (int i = 0; i < children.length; i++) {
            if (children[i] != null) {
                result += solutions(children[i], cache);
            }
        }
        cache.put(children);
        return result;
    }

    static int solutions(Board board) {
        if (board.distance() == 0) {
            return 1;
        }

        if (board.distance() > board.bound()) {
            return 0;
        }

        Board[] children = board.makeMoves();
        int result = 0;

        for (int i = 0; i < children.length; i++) {
            if (children[i] != null) {
                result += solutions(children[i]);
            }
        }
        return result;
    }

    private static void solve(Board board, boolean useCache) {
        BoardCache cache = null;
        if (useCache) {
            cache = new BoardCache();
        }
        int bound = board.distance();
        int solutions;

        System.out.print("Try bound ");
        System.out.flush();

        do {
            board.setBound(bound);

            System.out.print(bound + " ");
            System.out.flush();

            if (useCache) {
                solutions = solutions(board, cache);
            } else {
                solutions = solutions(board);
            }

            bound += 2;
        } while (solutions == 0);

        System.out.println("\nresult is " + solutions + " solutions of "
                + board.bound() + " steps");

    }

    public static void main(String[] args) {
        String fileName = null;
        boolean cache = true;
        int threads = 1;

        int length = 58;

        for (int i = 0; i < args.length; i++) {
            if (args[i].equals("--file")) {
                fileName = args[++i];
            } else if (args[i].equals("--nocache")) {
                cache = false;
            } else if (args[i].equals("--threads")) {
                i++;
                threads = Integer.parseInt(args[i]);
            }else if (args[i].equals("--length")) {
                i++;
                length = Integer.parseInt(args[i]);
            } else {
                System.err.println("No such option: " + args[i]);
                System.exit(1);
            }
        }

        Board initialBoard = null;

        if (fileName == null) {
            initialBoard = new Board(length);
        } else {
            try {
                initialBoard = new Board(fileName);
            } catch (Exception e) {
                System.err
                        .println("could not initialize board from file: " + e);

            }
        }
        System.out.println("Running IDA*, initial board:");
        System.out.println(initialBoard);
    }
}