import org.jpl7.Query;
import org.jpl7.Term;

import javax.swing.*;
import javax.swing.border.Border;
import javax.swing.plaf.basic.BasicComboBoxRenderer;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.geom.Ellipse2D;
import java.util.Arrays;
import java.util.Map;
import java.util.Random;

public class PuzzleGame extends JFrame {
    private final String dir = System.getProperty("user.dir").replace("\\", "/");

    private JPanel boardPanel;
    private JButton[][] buttons;
    private int[] numbers;
    private int size;
    private int blankRow;
    private int blankCol;
    private final Random random;

    JTextArea solutionLabel = new JTextArea("");
    private String currentSolution = "";

    public PuzzleGame() {
        size = 3;
        random = new Random();
        initializeUI();
    }

    private void initializeUI() {
        setTitle("N Puzzle");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLayout(new BorderLayout());

        JPanel controlPanel = new JPanel();

        //Size
        JComboBox<Integer> sizeComboBox = new JComboBox<>(new Integer[]{3, 4, 5});
        Font font = new Font("Arial", Font.BOLD, 22);
        sizeComboBox.setFont(font);
        sizeComboBox.setForeground(Color.BLACK);
        sizeComboBox.setBackground(new Color(102, 178, 222));
        sizeComboBox.setBorder(BorderFactory.createLineBorder(Color.BLACK, 2));
        sizeComboBox.setPreferredSize(new Dimension(100, 60));
        sizeComboBox.setRenderer(new CustomComboBoxRenderer());
        sizeComboBox.setSelectedItem(size);
        sizeComboBox.addActionListener(e -> {
            size = (Integer) sizeComboBox.getSelectedItem();
            boardPanel.setLayout(new GridLayout(size, size));
            generateRandomSetup();
        });

        //Change setup
        JButton changeSetupButton = setupPanelButton("Change setup");
        changeSetupButton.addActionListener(e -> generateRandomSetup());

        //Solve
        JButton solveButton = setupPanelButton("Solve");
        solveButton.addActionListener(e -> {
            switch (size) {
                case 3 -> {
                    Query q3 = new Query("consult('" + dir + "/src/main/resources/puzzle8.pl')");
                    q3.oneSolution();
                    Query sol = new Query("solve(" + Arrays.toString(numbers) + ", Moves).");
                    Map<String, Term> solution = sol.oneSolution();
                    if(solution == null) {
                        System.out.println("NO SOLUTIONS.");
                        currentSolution = "NO SOLUTIONS.";
                        solutionLabel.setText(currentSolution);
                    }
                    else {
                        Term term = solution.get("Moves");
                        currentSolution = "SOLUTION: " + Arrays.toString(mapResult(Term.atomListToStringArray(term)));
                        System.out.println(currentSolution);
                        solutionLabel.setText(currentSolution);
                    }
                    sol.close();
                    q3.close();
                    q3.remove();
                }
                case 4 -> {
                    Query q4 = new Query("consult('" + dir + "/src/main/resources/puzzle15.pl')");
                    q4.oneSolution();
                    Query sol = new Query("solve(" + Arrays.toString(numbers) + ", Moves).");
                    Map<String, Term> solution = sol.oneSolution();
                    if(solution == null) {
                        System.out.println("NO SOLUTIONS.");
                        currentSolution = "NO SOLUTIONS.";
                        solutionLabel.setText(currentSolution);
                    }
                    else {
                        Term term = solution.get("Moves");
                        currentSolution = "SOLUTION: " + Arrays.toString(mapResult(Term.atomListToStringArray(term)));
                        System.out.println(currentSolution);
                        solutionLabel.setText(currentSolution);
                    }
                    sol.close();
                    q4.close();
                }
                case 5 -> {
                    Query q5 = new Query("consult('" + dir + "/src/main/resources/puzzle24.pl')");
                    q5.oneSolution();
                    Query sol = new Query("solve(" + Arrays.toString(numbers) + ", Moves).");
                    Map<String, Term> solution = sol.oneSolution();
                    if(solution == null) {
                        System.out.println("NO SOLUTIONS.");
                        currentSolution = "NO SOLUTIONS.";
                        solutionLabel.setText(currentSolution);
                    }
                    else {
                        Term term = solution.get("Moves");
                        currentSolution = "SOLUTION: " + Arrays.toString(mapResult(Term.atomListToStringArray(term)));
                        System.out.println(currentSolution);
                        solutionLabel.setText(currentSolution);
                    }
                    sol.close();
                    q5.close();
                }
                default -> System.err.println("error");
            }
        });

        //Solution
        solutionLabel.setText("");
        Font font2 = new Font("Arial", Font.BOLD, 10);
        solutionLabel.setFont(font2);
        solutionLabel.setForeground(Color.BLACK);
        solutionLabel.setBackground(new Color(102, 178, 222));
        solutionLabel.setBorder(BorderFactory.createLineBorder(Color.BLACK, 2));
        solutionLabel.setPreferredSize(new Dimension(300, 60));
        solutionLabel.setLineWrap(true);
        solutionLabel.setWrapStyleWord(true);

        JLabel sizeLabel = new JLabel("Size:");
        sizeLabel.setFont(font);
        controlPanel.add(sizeLabel);
        controlPanel.add(sizeComboBox);
        controlPanel.add(changeSetupButton);
        controlPanel.add(solveButton);
        controlPanel.add(solutionLabel);

        add(controlPanel, BorderLayout.NORTH);

        boardPanel = new JPanel();
        boardPanel.setLayout(new GridLayout(size, size));
        boardPanel.setBorder(BorderFactory.createLineBorder(Color.BLACK, 25));
        boardPanel.setBackground(new Color(255, 255, 204));
        add(boardPanel, BorderLayout.CENTER);

        generateRandomSetup();

        setSize(900, 950);
        setLocationRelativeTo(null);
        setVisible(true);
    }

    private void generateRandomSetup() {
        numbers = new int[size * size];

        // Generate random numbers
        for (int i = 0; i < size * size; i++) {
            numbers[i] = i;
        }
        for (int i = numbers.length - 1; i > 0; i--) {
            int index = random.nextInt(i + 1);
            int temp = numbers[index];
            numbers[index] = numbers[i];
            numbers[i] = temp;
        }

        int tests = 0;
        switch(tests) {
            //unsolvable 3x3
            case 1 -> {
                size = 3;
                numbers = new int[]{0, 5, 3, 7, 1, 4, 2, 6, 8};
            }
            //solvable 4x4
            case 2 -> {
                size = 4;
                numbers = new int[]{5, 1, 7, 3, 2, 10, 8, 4, 9, 11, 0, 12, 13, 6, 14, 15};
            }
            //unsolvable 4x4
            case 3 -> {
                size = 4;
                numbers = new int[]{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 15, 14, 0};
            }
            //solvable 5x5
            case 4 -> {
                size = 5;
                numbers = new int[]{1,2,3,4,5,7,8,16,9,10,6,12,13,14,15,11,18,0,17,20,21,23,22,19,24};
            }
            //unsolvable 5x5
            case 5 -> {
                size = 5;
                numbers = new int[]{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,24,23,0};
            }
            default -> {}
        }
        boardPanel.setLayout(new GridLayout(size, size));

        boardPanel.removeAll();
        buttons = new JButton[size][size];

        // Create buttons
        for (int i = 0; i < size; i++) {
            for (int j = 0; j < size; j++) {
                int num = numbers[i * size + j];
                JButton button;
                String buttonText = "";
                if (num == 0) {
                    blankRow = i;
                    blankCol = j;
                } else {
                    buttonText = String.valueOf(num);
                }
                button = setupButton(buttonText, i, j);
                buttons[i][j] = button;
                boardPanel.add(button);
            }
        }

        solutionLabel.setText("");

        revalidate();
        repaint();
    }

    private JButton setupButton(String text, int row, int col) {
        JButton button = new JButton(text);

        button.addActionListener(new ButtonClickListener(row, col));

        Font font = new Font("Arial", Font.BOLD, 45);
        button.setFont(font);
        button.setForeground(Color.BLACK);
        button.setBackground(new Color(255,255,200));
        button.setBorder(BorderFactory.createLineBorder(Color.BLACK, 2));
        button.setFocusPainted(false);

        return button;
    }

    private JButton setupPanelButton(String text) {
        JButton button = new JButton(text);

        Font font = new Font("Arial", Font.BOLD, 22);
        button.setFont(font);
        button.setForeground(Color.BLACK);
        button.setBackground(new Color(102, 178, 222));
        button.setBorder(BorderFactory.createLineBorder(Color.BLACK, 2));
        button.setFocusPainted(false);
        button.setPreferredSize(new Dimension(200, 60));

        return button;
    }

    private String[] mapResult(String[] input) {
        String[] res = new String[input.length];

        for(int i = 0; i < input.length; i++) {
            switch(input[i]) {
                case "u" -> {
                    res[i] = "UP";
                }
                case "d" -> {
                    res[i] = "DOWN";
                }
                case "l" -> {
                    res[i] = "LEFT";
                }
                case "r" -> {
                    res[i] = "RIGHT";
                }
                default -> {}
            }
        }

        return res;
    }

    private class ButtonClickListener implements ActionListener {
        public int row;
        public int col;

        public ButtonClickListener(int row, int col) {
            this.row = row;
            this.col = col;
        }

        @Override
        public void actionPerformed(ActionEvent e) {
            if (isAdjacent(row, col, blankRow, blankCol)) {

                JButton temp = buttons[row][col];
                buttons[row][col] = buttons[blankRow][blankCol];
                buttons[blankRow][blankCol] = temp;

                buttons[row][col].removeActionListener(buttons[row][col].getActionListeners()[0]);
                buttons[blankRow][blankCol].removeActionListener(buttons[blankRow][blankCol].getActionListeners()[0]);
                buttons[row][col].addActionListener(new ButtonClickListener(row, col));
                buttons[blankRow][blankCol].addActionListener(new ButtonClickListener(blankRow, blankCol));

                boardPanel.removeAll();
                for (int i = 0; i < size; i++) {
                    for (int j = 0; j < size; j++) {
                        boardPanel.add(buttons[i][j]);
                    }
                }

                blankRow = row;
                blankCol = col;

                revalidate();
                repaint();
            }
        }

        @Override
        public String toString() {
            return row + " " + col;
        }
    }

    static class CustomComboBoxRenderer extends BasicComboBoxRenderer {
        @Override
        public Component getListCellRendererComponent(JList list, Object value, int index, boolean isSelected, boolean cellHasFocus) {
            super.getListCellRendererComponent(list, value, index, isSelected, cellHasFocus);

            setFont(new Font("Arial", Font.BOLD, 14));
            setBackground(new Color(255, 255, 204));

            return this;
        }
    }

    private boolean isAdjacent(int row1, int col1, int row2, int col2) {
        return (Math.abs(row1 - row2) == 1 && col1 == col2) || (Math.abs(col1 - col2) == 1 && row1 == row2);
    }

    public static void main(String[] args) {
        System.err.close();
        SwingUtilities.invokeLater(PuzzleGame::new);
    }
}
