package com.example.gui;

import javafx.animation.AnimationTimer;
import javafx.application.Application;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.chart.LineChart;
import javafx.scene.chart.NumberAxis;
import javafx.scene.chart.XYChart;
import javafx.scene.input.KeyCode;
import javafx.stage.Stage;
import serial.MySerialPort;

import java.math.BigInteger;
import java.util.ArrayList;

public class Main extends Application {
    private Scene scene;
    public static ArrayList<Integer> generateSineWave(){
        ArrayList<Integer> toReturn = new ArrayList<>();
        double i = 0.0;
        while (i < 2.01){
            toReturn.add( (int) (Math.sin(i * Math.PI) * 100) );
            i += 0.01;
        }
        return toReturn;
    }

    public static ArrayList<Integer> generateSawtoothWave(){
        ArrayList<Integer> toReturn = new ArrayList<>();
        double i = 0.0;
        while (i < 1.0){
            if(toReturn.contains(0)){
                toReturn.add( (int) ((i - 0.89) * 1000 / 1.1));
            }
            else{
                toReturn.add( (int) ((0.9 - i) * 100));
            }
            i += 0.01;
        }
        return toReturn;
    }

    // defining the series
    XYChart.Series<Number, Number> series = new XYChart.Series<>(); // input (unfiltered)
    XYChart.Series<Number, Number> series2 = new XYChart.Series<>(); // output (filtered)
    // defining the axes
    private final NumberAxis xAxis = new NumberAxis(0, MAX_DATA_POINTS, MAX_DATA_POINTS / 10);
    private final NumberAxis yAxis = new NumberAxis(-130, 130, 10);
    final LineChart<Number,Number> lineChart = new LineChart<>(xAxis,yAxis);
    // creating the scene
    private Parent createContent(){
        series.setName("Unfiltered signal");
        series2.setName("Filtered signal");
        lineChart.setTitle("Select input\nSine - S\nSawtooth - W");
        lineChart.getData().add(series);
        lineChart.getData().add(series2);
        lineChart.setPrefSize(800, 600);

        // Every frame to take any data from queue and add to chart
        new AnimationTimer() {
            @Override
            public void handle(long now) {
                try {
                    Thread.sleep(125); // frequency is 8 Hz
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                addDataToSeries();
            }
        }.start();

        return lineChart;
    }
    static final int MAX_DATA_POINTS = 300;
    int xSeriesData = 0;

    ArrayList<Integer> input = new ArrayList<>();
    public int inputSelect = 0;
    public ArrayList<Integer> selectInput(){
        switch (inputSelect){
            case 0 -> {
                return generateSineWave();
            }
            case 1 -> {
                return generateSawtoothWave();
            }
        }
        // default selection
        return generateSineWave();
    }

    public void addDataToSeries(){
        for (int i = 0; i < 1; i++) {
            if (input.isEmpty()){
                input = selectInput();
            }
            MySerialPort.setSendingPack(new byte[]{(byte)(int) input.get(0)});
            series.getData().add(new XYChart.Data<>(xSeriesData++, input.remove(0)));
            series2.getData().add(new XYChart.Data<>(xSeriesData, new BigInteger(MySerialPort.receivingPack).intValue()));
        }
        // remove points to keep us at no more than MAX_DATA_POINTS
        if (series.getData().size() > MAX_DATA_POINTS) {
            series.getData().remove(0, series.getData().size() - MAX_DATA_POINTS);
        }
        // update
        xAxis.setLowerBound(xSeriesData - MAX_DATA_POINTS);
        xAxis.setUpperBound(xSeriesData - 1);
    }

    @Override
    public void start(Stage stage) throws Exception {
        stage.setTitle("Digital Signal Filter");
        scene = new Scene(createContent());

        scene.setOnKeyPressed(keyEvent -> {
            if(keyEvent.getCode().equals(KeyCode.S)){ // sinusoidal wave select
                input.removeAll(input);
                inputSelect = 0;
            }
            if(keyEvent.getCode().equals(KeyCode.W)){ // sawtooth wave select
                input.removeAll(input);
                inputSelect = 1;
            }
            if(keyEvent.getCode().equals(KeyCode.ESCAPE)){ // stop application
                MySerialPort.setRunning(false);
                System.exit(0);
            }
        });

        stage.setScene(scene);
        stage.show();
    }

    public static void main(String[] args) {
        MySerialPort.setRunning(true);
        MySerialPort.connectPort("COM10");
        launch(args);
    }
}
