package serial;

import com.fazecast.jSerialComm.SerialPort;

import java.io.InputStream;
import java.util.Arrays;

public class MySerialPort {
    public static SerialPort port = null;
    static String logText="";
    private static boolean isRunning=false;
    private static byte[] sendingPack;
    public static byte[] receivingPack;

    public static boolean isRunning() {
        return isRunning;
    }

    public static void setRunning(boolean running) {
        sendingPack = new byte[1];
        receivingPack = new byte[1];
        isRunning = running;

    }

    public static void setSendingPack(byte[] bytes){
        sendingPack = bytes;
    }

    public static void connectPort(String port) {
//        devicePortName = port;

        int len = SerialPort.getCommPorts().length;
        SerialPort[] serialPorts = new SerialPort[len];
        serialPorts = SerialPort.getCommPorts();

        for (int i = 0; i < len; i++) {

            String portName = serialPorts[i].getDescriptivePortName();
            System.out.println(serialPorts[i].getSystemPortName() + ": " + portName + ": "
                    + i);

            if (portName.contains(port)) {
                try {
                    MySerialPort.port = serialPorts[i];
                    MySerialPort.port.setBaudRate(115200);
                    MySerialPort.port.openPort();
                    setRunning(true);
                    System.out.println("connected to: " + portName + "[" + i + "]");
                    logText="Connected to: " + portName ;

                    break;
                } catch (Exception e) {
                    e.printStackTrace();
//                    logger.stop();
                    MySerialPort.port.closePort();
                }
            } }

        (new Thread(new SerialReader(receivingPack))).start();
        (new Thread(new SerialWriter(sendingPack))).start();
    }
    public static class SerialReader implements Runnable
    {
        byte[] buffer;

        public SerialReader ( byte[] buffer )
        {
            this.buffer = buffer;
//            System.out.println("Reader");
        }

        public void run () {

            readData(buffer, isRunning());
        }
    }
    public static class SerialWriter implements Runnable
    {
        byte[] buffer;

        public SerialWriter ( byte[] buffer )
        {
            this.buffer = buffer;

        }

        public void run () {

            sendData(buffer);

        }
    }
    public static void sendData(byte[] buffer){

        while (isRunning){

            port.writeBytes(sendingPack,1, 0);

            System.out.println("Sending " + bytesToHexString(sendingPack) + " " + Arrays.toString(sendingPack));
            try {
                Thread.sleep(125);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    public static void readData(byte[] buffer, boolean loopStatus){
        while (isRunning()){

            port.readBytes(receivingPack,1,0);

            System.out.println("Read: " + bytesToHexString(receivingPack));

//            if((receivingPack[0] & 0xff) == 144){
//
//                String bufferD=bytesToHexString(receivingPack);
//                System.out.println(bufferD);
//
//            }
            try {
                Thread.sleep(125);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    public static String bytesToHexString(byte[] bytes){
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes){
            sb.append(String.format("%02x", b&0xff));
        }
        return sb.toString();
    }
}
