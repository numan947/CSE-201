package main;

/**
 * Sample Skeleton for 'client_side_gui.fxml' Controller Class
 */

import java.io.File;
import java.net.URL;
import java.util.Date;
import java.util.ResourceBundle;

import javafx.application.Platform;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.*;
import javafx.stage.DirectoryChooser;

public class Client_GUI_Controller {


    private ClientSide initiator;
    private File saveLocation;
    MainNetworkThread networkThread;
    Alert alert =null;
    @FXML
    private Button questionSavePath;
    @FXML
    private Label warning_time;
    @FXML
    private TextField exam_code;

    @FXML
    private TextField studentID;

    @FXML // ResourceBundle that was given to the FXMLLoader
    private ResourceBundle resources;

    @FXML // URL location of the FXML file that was given to the FXMLLoader
    private URL location;

    @FXML // fx:id="duration"
    private Label duration; // Value injected by FXMLLoader

    @FXML // fx:id="correction_list"
    private ListView<String> correction_list; // Value injected by FXMLLoader

    @FXML // fx:id="start_time"
    private Label start_time; // Value injected by FXMLLoader

    @FXML // fx:id="rules_and_regulations"
    private TextArea rules_and_regulations; // Value injected by FXMLLoader

    @FXML // fx:id="server_ip_address"
    private TextField server_ip_address; // Value injected by FXMLLoader

    @FXML // fx:id="port_number"
    private TextField port_number; // Value injected by FXMLLoader

    @FXML // fx:id="exam_name"
    private Label exam_name; // Value injected by FXMLLoader

    @FXML // fx:id="backup_interval"
    private Label backup_interval; // Value injected by FXMLLoader

    @FXML // fx:id="connect"
    private Button connect; // Value injected by FXMLLoader

    @FXML // fx:id="status"
    private Label status; // Value injected by FXMLLoader

    public void clearConnectButton()
    {
        if (networkThread != null) {
            networkThread.setRunning(false);
        }
        Platform.runLater(() -> {
            connect.setText("Connect");
            status.setText("Status: Server Not Connected");
            exam_code.setEditable(true);
        });
    }



    @FXML
    void connect(ActionEvent event) {

        System.out.println("H1");
        if(!connect.getText().equals("Connected")&&!studentID.getText().equals("")
                &&!exam_code.getText().equals("") && !server_ip_address.getText().equals("")
                && !port_number.getText().equals("")) {
            System.out.println("H2");
            try {
                String ipaddress = server_ip_address.getText();
                int port = Integer.parseInt(port_number.getText());
                String sid = studentID.getText();
                String e_c = exam_code.getText();
                //todo here'll be the code for initializing the MainNetworkThread
                networkThread = new MainNetworkThread(this, e_c, sid, ipaddress, port, saveLocation);
                connect.setText("Connected");
                status.setText("Status: Server Connected");
            } catch (Exception e) {
                //todo throw with alert dialog
                System.out.println(e);
            }
        }
        else {
            System.out.println("H3");
            clearConnectButton();
        }
    }


    @FXML // This method is called by the FXMLLoader when initialization is complete
    void initialize() {
        assert duration != null : "fx:id=\"duration\" was not injected: check your FXML file 'client_side_gui.fxml'.";
        assert studentID != null : "fx:id=\"studentID\" was not injected: check your FXML file 'client_side_gui.fxml'.";
        assert correction_list != null : "fx:id=\"correction_list\" was not injected: check your FXML file 'client_side_gui.fxml'.";
        assert start_time != null : "fx:id=\"start_time\" was not injected: check your FXML file 'client_side_gui.fxml'.";
        assert rules_and_regulations != null : "fx:id=\"rules_and_regulations\" was not injected: check your FXML file 'client_side_gui.fxml'.";
        assert server_ip_address != null : "fx:id=\"server_ip_address\" was not injected: check your FXML file 'client_side_gui.fxml'.";
        assert port_number != null : "fx:id=\"port_number\" was not injected: check your FXML file 'client_side_gui.fxml'.";
        assert exam_name != null : "fx:id=\"exam_name\" was not injected: check your FXML file 'client_side_gui.fxml'.";
        assert backup_interval != null : "fx:id=\"backup_interval\" was not injected: check your FXML file 'client_side_gui.fxml'.";
        assert connect != null : "fx:id=\"connect\" was not injected: check your FXML file 'client_side_gui.fxml'.";
        assert exam_code != null : "fx:id=\"exam_code\" was not injected: check your FXML file 'client_side_gui.fxml'.";
        assert status != null : "fx:id=\"status\" was not injected: check your FXML file 'client_side_gui.fxml'.";
        rules_and_regulations.setEditable(false);
        saveLocation=new File(System.getProperty("user.home"));
        alert=new Alert(Alert.AlertType.ERROR);
    }

    public void setInitiator(ClientSide initiator) {
        this.initiator = initiator;
    }

    public ClientSide getInitiator() {
        return initiator;
    }


    public void setAll(String fullmsg)
    {
        Platform.runLater(() -> {
            String[] info = fullmsg.split("\\$\\$\\$\\$");
            //parsed all the basic info
            String e_c=info[0];
            String examName=info[1];
            int duration=Integer.parseInt(info[2]);
            int backupInterval=Integer.parseInt(info[3]);
            int warningTime=Integer.parseInt(info[4]);
            long startTimeInLong=Long.parseLong(info[5]);
            String rules=info[6];
            Date startTime=new Date(startTimeInLong);

            this.backup_interval.setText("Backup Interval: "+backupInterval/1000+" seconds");
            this.exam_code.setText(e_c);
            this.exam_code.setEditable(false);
            this.exam_name.setText("Exam Name: "+examName);
            this.start_time.setText("Start Time: "+startTime.toString());
            this.duration.setText("Duration: "+duration+" seconds");
            this.warning_time.setText("Warning Time: "+warningTime/1000+" seconds");
            this.rules_and_regulations.setText(rules);

        });

    }

    @FXML
    void setQuestionSavePath(ActionEvent actionEvent) {
        DirectoryChooser dc=new DirectoryChooser();
        saveLocation=dc.showDialog(initiator.getMainStage());
    }

    public void showErrorDialog(String ss)
    {
        Platform.runLater(() -> {
            alert.setAlertType(Alert.AlertType.ERROR);
            alert.setTitle("ERROR!!");
            alert.setHeaderText("There's an error while connecting");
            alert.setContentText(ss);
            alert.showAndWait();
            this.clearConnectButton();
        });

    }



    public void informationDialog(String ss)
    {
        Platform.runLater(() -> {
            alert.setAlertType(Alert.AlertType.INFORMATION);
            alert.setTitle("NEW INFORMATION!");
            alert.setHeaderText("You've received a new information!");
            alert.setContentText(ss);
            alert.showAndWait();
        });

    }

    public void addToCorrectionsList(String msg) {

        Platform.runLater(() -> {
            this.correction_list.getItems().add(0,msg);
        });
    }
}
