package main;

import pair.Pair;

import javax.swing.*;
import java.awt.event.*;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.*;
import java.util.stream.Collectors;

public class Main {

    private static final List<String> types = new ArrayList<>();
    private static final Map<JLabel, Integer> objects = new HashMap<>();

    private static int obj = 0;
    private static int sw_x = 0;
    private static int sw_y = 0;
    private static int x = 0, y = 0;

    private static boolean shift = false;
    private static boolean space = false;

    private static final JFrame frame = new JFrame();
    private static final JPanel contentPane = new JPanel(null);
    private static JLabel img = new JLabel();
    private static JLabel player = new JLabel();

    private static String path = "lvl.json";

    private static String toJson() {
        StringBuilder out = new StringBuilder("[\n");

        for (Map.Entry<JLabel, Integer> e : objects.entrySet()) {
            switch (e.getValue()) {
                case 0:
                    out.append("{\"type\" : \"StaticObject\", \"x\" : \"").append(e.getKey().getX() - x).append("\", \"y\" : \"").append(e.getKey().getY() - y).append("\", \"w\" : \"64\"").append(", \"h\" : \"64\", \"tex\" : \"ground\"},\n");
                    break;

                case 1:
                    out.append("{\"type\" : \"Box\", \"x\" : \"").append(e.getKey().getX() - x).append("\", \"y\" : \"").append(e.getKey().getY() - y).append("\"},\n");
                    break;

                case 2:
                    out.append("{\"type\" : \"Enemy\", \"x\" : \"").append(e.getKey().getX() - x).append("\", \"y\" : \"").append(e.getKey().getY() - y).append("\"},\n");
                    break;

                case 4:
                    out.append("{\"type\" : \"StaticObject\", \"x\" : \"").append(e.getKey().getX() - x).append("\", \"y\" : \"").append(e.getKey().getY() - y).append("\", \"w\" : \"64\"").append(", \"h\" : \"64\", \"tex\" : \"brick\"},\n");
                    break;

                case 5:
                    out.append("{\"type\" : \"StaticObject\", \"x\" : \"").append(e.getKey().getX() - x).append("\", \"y\" : \"").append(e.getKey().getY() - y).append("\", \"w\" : \"64\"").append(", \"h\" : \"64\", \"tex\" : \"cobblestone\"},\n");
                    break;

                case 6:
                    out.append("{\"type\" : \"StaticObject\", \"x\" : \"").append(e.getKey().getX() - x).append("\", \"y\" : \"").append(e.getKey().getY() - y).append("\", \"w\" : \"64\"").append(", \"h\" : \"64\", \"tex\" : \"lavabrick\"},\n");
                    break;

                case 7:
                    out.append("{\"type\" : \"StaticObject\", \"x\" : \"").append(e.getKey().getX() - x).append("\", \"y\" : \"").append(e.getKey().getY() - y).append("\", \"w\" : \"64\"").append(", \"h\" : \"64\", \"tex\" : \"magmabrick\"},\n");
                    break;

                case 8:
                    out.append("{\"type\" : \"StaticObject\", \"x\" : \"").append(e.getKey().getX() - x).append("\", \"y\" : \"").append(e.getKey().getY() - y).append("\", \"w\" : \"32\"").append(", \"h\" : \"32\", \"tex\" : \"syringe\"},\n");
                    break;

                case 9:
                    out.append("{\"type\" : \"finish_line\", \"length\" : \"").append(e.getKey().getX() - x).append("\"},\n");
                    break;

                case 10:
                    out.append(e.getKey().getText());
                    break;

                default:
                    break;
            }
        }

        return out.toString().substring(0, out.length() - 2) + "\n]";
    }

    private static void loadLvl() {
        try {
            JFileChooser chooser = new JFileChooser();
            int returnVal = chooser.showOpenDialog(frame);
            path = returnVal == JFileChooser.APPROVE_OPTION ? chooser.getSelectedFile().getAbsolutePath() : "lvl.json";

            String content = new String(Files.readAllBytes(Paths.get(path)));
            content = content.replaceAll("[\\s+]|[\\]]|[\\[]|[ ]", "")
                    .replaceAll("},\\{", "|")
                    .replaceAll("[\\{]|[\\}]|[\"]", "");
            String[] arr = content.split("\\|");

            List<Map<String, String>> list = Arrays.stream(arr).map(s ->
                    Arrays.stream(s.split(",")).map(o ->
                            new Pair<>(o.split(":")[0].trim(), o.split(":")[1].trim()))
                            .collect(Collectors.toMap(Pair::getKey, Pair::getValue)))
                    .collect(Collectors.toList());

            sw_x = 0;
            sw_y = 0;
            x = 0;
            y = 0;
            objects.clear();
            contentPane.removeAll();
            contentPane.add(img);
            player.setBounds(0, 0, player.getWidth(), player.getHeight());
            contentPane.add(player);

            list.forEach(m -> {
                if (m.get("type").equals("StaticObject")) {
                    final JLabel l;
                    switch (m.get("tex")) {
                        case "ground":
                            l = new JLabel(new ImageIcon("img/ground.png"));
                            l.setBounds(Integer.parseInt(m.get("x")),
                                    Integer.parseInt(m.get("y")),
                                    Integer.parseInt(m.get("w")),
                                    Integer.parseInt(m.get("h")));
                            contentPane.add(l);
                            objects.put(l, 0);
                            break;

                        case "lavabrick":
                            l = new JLabel(new ImageIcon("img/lavabrick.png"));
                            l.setBounds(Integer.parseInt(m.get("x")),
                                    Integer.parseInt(m.get("y")),
                                    Integer.parseInt(m.get("w")),
                                    Integer.parseInt(m.get("h")));
                            contentPane.add(l);
                            objects.put(l, 6);
                            break;

                        case "syringe":
                            l = new JLabel(new ImageIcon("img/syringe.png"));
                            l.setBounds(Integer.parseInt(m.get("x")),
                                    Integer.parseInt(m.get("y")),
                                    Integer.parseInt(m.get("w")),
                                    Integer.parseInt(m.get("h")));
                            contentPane.add(l);
                            objects.put(l, 8);
                            break;

                        case "brick":
                            l = new JLabel(new ImageIcon("img/brick.png"));
                            l.setBounds(Integer.parseInt(m.get("x")),
                                    Integer.parseInt(m.get("y")),
                                    Integer.parseInt(m.get("w")),
                                    Integer.parseInt(m.get("h")));
                            contentPane.add(l);
                            objects.put(l, 4);
                            break;

                        case "cobblestone":
                            l = new JLabel(new ImageIcon("img/cobblestone.png"));
                            l.setBounds(Integer.parseInt(m.get("x")),
                                    Integer.parseInt(m.get("y")),
                                    Integer.parseInt(m.get("w")),
                                    Integer.parseInt(m.get("h")));
                            contentPane.add(l);
                            objects.put(l, 5);
                            break;

                        case "magmabrick":
                            l = new JLabel(new ImageIcon("img/magmabrick.png"));
                            l.setBounds(Integer.parseInt(m.get("x")),
                                    Integer.parseInt(m.get("y")),
                                    Integer.parseInt(m.get("w")),
                                    Integer.parseInt(m.get("h")));
                            contentPane.add(l);
                            objects.put(l, 7);
                            break;

                        default:
                            break;
                    }
                } else {
                    final JLabel l;
                    switch (m.get("type")) {
                        case "DoorSwitch":
                            l = new JLabel(new ImageIcon("img/switch_off.png"));
                            l.setBounds(Integer.parseInt(m.get("x_sw")),
                                    Integer.parseInt(m.get("y_sw")), 32, 10);
                            contentPane.add(l);
                            objects.put(l, 3);

                            final JLabel l1 = new JLabel(new ImageIcon("img/door.png"));
                            l1.setBounds(Integer.parseInt(m.get("x")),
                                    Integer.parseInt(m.get("y")), 16, 150);
                            contentPane.add(l1);
                            objects.put(l1, 3);

                            objects.put(new JLabel("{\"type\" : \"DoorSwitch\", \"x\" : \"" + m.get("x")
                                    + "\", \"y\" : \"" + m.get("y") + "\", \"x_sw\" : \""
                                    + m.get("x_sw") + "\", \"y_sw\" : \"" + m.get("y_sw") + "\"},\n"), 10);
                            break;

                        case "Box":
                            l = new JLabel(new ImageIcon("img/box.png"));
                            l.setBounds(Integer.parseInt(m.get("x")),
                                    Integer.parseInt(m.get("y")), 64, 64);
                            contentPane.add(l);
                            objects.put(l, 1);
                            break;

                        case "Enemy":
                            l = new JLabel(new ImageIcon("img/enemy_r.png"));
                            l.setBounds(Integer.parseInt(m.get("x")),
                                    Integer.parseInt(m.get("y")), 32, 32);
                            contentPane.add(l);
                            objects.put(l, 2);
                            break;

                        case "finish_line":
                            l = new JLabel(new ImageIcon("img/finish_line.png"));
                            l.setBounds(Integer.parseInt(m.get("length")), 0, 1, 150);
                            contentPane.add(l);
                            objects.put(l, 9);
                            break;

                        default:
                            break;
                    }
                }

                SwingUtilities.updateComponentTreeUI(frame);
            });

        } catch (IOException ioException) {
            ioException.printStackTrace();
        }
    }

    public static void main(String[] args) {

        types.add("ground");
        types.add("box");
        types.add("enemy_r");
        types.add("switch_off");
        types.add("brick");
        types.add("cobblestone");
        types.add("lavabrick");
        types.add("magmabrick");
        types.add("syringe");
        types.add("finish_line");
        types.add("door");

        frame.setSize(1500, 800);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setTitle("Kill the Virus! Level Editor");

        img = new JLabel(new ImageIcon("img/" + types.get(obj) + ".png"));
        img.setBounds(10, 10, 64, 64);
        contentPane.add(img);

        player = new JLabel(new ImageIcon("img/player_r.png"));
        player.setBounds(0, 0, 32, 32);
        contentPane.add(player);

        contentPane.addMouseMotionListener(
                new MouseMotionListener() {
                    @Override
                    public void mouseDragged(MouseEvent e) {

                    }

                    @Override
                    public void mouseMoved(MouseEvent e) {
                        if (shift) {
                            img.setBounds(e.getX() - img.getWidth() / 2, img.getY(), img.getWidth(), img.getHeight());
                        }

                        if (space) {
                            img.setBounds(img.getX(), e.getY() - img.getHeight() / 2, img.getWidth(), img.getHeight());
                        }

                        if (!shift && !space) {
                            img.setBounds(e.getX() - img.getWidth() / 2, e.getY() - img.getHeight() / 2, img.getWidth(), img.getHeight());
                        }
                    }
                }
        );

        contentPane.addMouseWheelListener(
                e -> {
                    if (obj != 10) {
                        if (e.getWheelRotation() < 0) {
                            if (++obj > 9) {
                                obj = 0;
                            }
                        } else {
                            if (--obj < 0) {
                                obj = 9;
                            }
                        }

                        img.setIcon(new ImageIcon("img/" + types.get(obj) + ".png"));

                        switch (obj) {
                            case 0:

                            case 1:

                            case 4:

                            case 5:

                            case 6:

                            case 7:
                                img.setBounds(e.getX() - 32, e.getY() - 32, 64, 64);
                                break;

                            case 8:

                            case 2:
                                img.setBounds(e.getX() - 16, e.getY() - 16, 32, 32);
                                break;

                            case 3:
                                img.setBounds(e.getX() - 16, e.getY() - 5, 32, 10);
                                break;

                            case 9:
                                img.setBounds(e.getX(), e.getY(), 1, 150);
                                break;

                            default:
                                break;
                        }
                    }
                }
        );

        contentPane.addMouseListener(
                new MouseListener() {
                    @Override
                    public void mouseClicked(MouseEvent e) {

                    }

                    @Override
                    public void mousePressed(MouseEvent e) {

                    }

                    @Override
                    public void mouseReleased(MouseEvent e) {
                        if (e.getButton() == MouseEvent.BUTTON1) {
                            JLabel l = new JLabel(new ImageIcon("img/" + types.get(obj) + ".png"));
                            l.setBounds(img.getBounds());

                            if (obj == 3) {
                                sw_x = img.getX() - x;
                                sw_y = img.getY() - y;
                                obj = 10;
                                img.setIcon(new ImageIcon("img/" + types.get(obj) + ".png"));
                                img.setBounds(e.getX() - 8, e.getY() - 75, 16, 150);
                                objects.put(l, 3);
                            } else if (obj == 10) {
                                objects.put(new JLabel("{\"type\" : \"DoorSwitch\", \"x\" : \"" + (img.getX() - x)
                                        + "\", \"y\" : \"" + (img.getY() - y) + "\", \"x_sw\" : \""
                                        + sw_x + "\", \"y_sw\" : \"" + sw_y + "\"},\n"), 10);
                                obj = 3;
                                img.setIcon(new ImageIcon("img/" + types.get(obj) + ".png"));
                                img.setBounds(e.getX() - 32, e.getY() - 4, 64, 8);
                                objects.put(l, 3);
                            } else {
                                objects.put(l, obj);
                            }

                            contentPane.add(l);
                        } else if (e.getButton() == MouseEvent.BUTTON3) {
                            JLabel l = null;

                            for (Map.Entry<JLabel, Integer> o : objects.entrySet()) {
                                if (e.getX() > o.getKey().getX() && e.getX() < o.getKey().getX() + o.getKey().getWidth()
                                        && e.getY() > o.getKey().getY() && e.getY() < o.getKey().getY() + o.getKey().getHeight()) {
                                    l = o.getKey();
                                }
                            }

                            if (l != null) {
                                if (objects.get(l) == 3) {
                                    JLabel l1 = new JLabel();
                                    for (Map.Entry<JLabel, Integer> o : objects.entrySet()) {
                                        if (o.getValue() == 10
                                                && ((o.getKey().getText().contains("\"x\" : \"" + (l.getX() - x))
                                                && o.getKey().getText().contains("\"y\" : \"" + (l.getY() - y)))
                                                || (o.getKey().getText().contains("\"x_sw\" : \"" + (l.getX() - x))
                                                && o.getKey().getText().contains("\"y_sw\" : \" " + (l.getY() - y))))) {
                                            l1 = o.getKey();
                                        }
                                    }
                                    objects.remove(l1);
                                }
                                contentPane.remove(l);
                                SwingUtilities.updateComponentTreeUI(frame);
                                objects.remove(l);
                            }
                        }
                    }

                    @Override
                    public void mouseEntered(MouseEvent e) {

                    }

                    @Override
                    public void mouseExited(MouseEvent e) {

                    }
                }
        );

        frame.addKeyListener(
                new KeyListener() {
                    @Override
                    public void keyTyped(KeyEvent e) {

                    }

                    @Override
                    public void keyPressed(KeyEvent e) {
                        switch (e.getKeyCode()) {
                            case KeyEvent.VK_S:
                                try {
                                    if (path.equals("lvl.json")) {
                                        JFileChooser chooser = new JFileChooser();
                                        int returnVal = chooser.showOpenDialog(frame);
                                        path = returnVal == JFileChooser.APPROVE_OPTION ? chooser.getSelectedFile().getAbsolutePath() : "lvl.json";
                                    }
                                    PrintWriter out = new PrintWriter(path);
                                    out.println(toJson());
                                    out.close();
                                } catch (FileNotFoundException fileNotFoundException) {
                                    fileNotFoundException.printStackTrace();
                                }
                                break;

                            case KeyEvent.VK_L:
                                loadLvl();
                                break;

                            case KeyEvent.VK_F:
                                JLabel l = new JLabel();
                                for (Map.Entry<JLabel, Integer> o : objects.entrySet()) {
                                    if (o.getValue() == 9) {
                                        l = o.getKey();
                                    }
                                }
                                contentPane.remove(l);
                                SwingUtilities.updateComponentTreeUI(frame);
                                objects.remove(l);
                                break;

                            case KeyEvent.VK_SHIFT:
                                shift = true;
                                break;

                            case KeyEvent.VK_SPACE:
                                space = true;
                                break;

                            case KeyEvent.VK_RIGHT:
                                x -= 10;
                                for (Map.Entry<JLabel, Integer> o : objects.entrySet()) {
                                    o.getKey().setBounds(o.getKey().getX() - 10, o.getKey().getY(), o.getKey().getWidth(),
                                            o.getKey().getHeight());
                                }
                                player.setBounds(player.getX() - 10, player.getY(), player.getWidth(), player.getHeight());
                                break;

                            case KeyEvent.VK_LEFT:
                                x += 10;
                                for (Map.Entry<JLabel, Integer> o : objects.entrySet()) {
                                    o.getKey().setBounds(o.getKey().getX() + 10, o.getKey().getY(), o.getKey().getWidth(),
                                            o.getKey().getHeight());
                                }
                                player.setBounds(player.getX() + 10, player.getY(), player.getWidth(), player.getHeight());
                                break;

                            case KeyEvent.VK_UP:
                                y += 10;
                                for (Map.Entry<JLabel, Integer> o : objects.entrySet()) {
                                    o.getKey().setBounds(o.getKey().getX(), o.getKey().getY() + 10, o.getKey().getWidth(),
                                            o.getKey().getHeight());
                                }
                                player.setBounds(player.getX(), player.getY() + 10, player.getWidth(), player.getHeight());
                                break;

                            case KeyEvent.VK_DOWN:
                                y -= 10;
                                for (Map.Entry<JLabel, Integer> o : objects.entrySet()) {
                                    o.getKey().setBounds(o.getKey().getX(), o.getKey().getY() - 10, o.getKey().getWidth(),
                                            o.getKey().getHeight());
                                }
                                player.setBounds(player.getX(), player.getY() - 10, player.getWidth(), player.getHeight());
                                break;

                            default:
                                break;
                        }
                    }

                    @Override
                    public void keyReleased(KeyEvent e) {
                        switch (e.getKeyCode()) {
                            case KeyEvent.VK_SHIFT:
                                shift = false;
                                break;

                            case KeyEvent.VK_SPACE:
                                space = false;
                                break;

                            default:
                                break;
                        }
                    }
                }
        );

        frame.setContentPane(contentPane);
        frame.setVisible(true);
    }
}
