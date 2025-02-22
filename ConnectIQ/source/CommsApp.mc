using Toybox.Application;
using Toybox.WatchUi as Ui;
using Toybox.Timer;
using Toybox.Communications as Comms;

var log = new Log(LOG_LEVEL_VERBOSE);

class CommsApp extends Application.AppBase {
    hidden var timer;
    hidden var message = new Comms.PhoneAppMessage();
    hidden var progressBar = new Ui.ProgressBar("Ready.", null);

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
        timer = new Timer.Timer();
		timer.start(method(:updateMessage), 10000, true);
		updateMessage();

        Comms.registerForPhoneAppMessages(method(:phoneMessageCallback));
    }

    function phoneMessageCallback(_message as $.Toybox.Communications.PhoneAppMessage) as Void {
        $.log.info("Message received. Contents:");
        message = _message.data;
        $.log.info(message);
        progressBar.setDisplayString(message);
    }

    function onStop(state) {
    	timer.stop();
    }

    function getInitialView() {
        return [progressBar];
    }

    function updateMessage() as Void {
        $.log.verbose("Updating message.");

        progressBar.setDisplayString("Sending..");

		// basic string
        // var message = "heya!";

        // array of dictionaries
        // var message = [
        //     {
        //         "latitude" => 49.233162,
        //         "longitude" => 16.572311,
        //         "message" => "NAyayayaaa"
        //     },
        //     {
        //         "latitude" => 49.216426,
        //         "longitude" => 16.587749,
        //         "message" => "Ayayayaaa"
        //     }
        // ];

		// dictionary
        var message = {
            "latitude" => 49.233162,
            "longitude" => 16.572311,
            "message" => "Nope.avi"
        };

        $.log.verbose("Transmitting message.");
        try {
            Comms.transmit(message, null, new CommsRelay(method(:onTransmitComplete)));
            $.log.verbose("Message transmitted.");
        } catch(exception) {
            $.log.error("Message failed to transmit: " + exception.getErrorMessage());
        }
    }

	// If you're debugging a problem with connecting/transmitting message, consult `README.md`.
    function onTransmitComplete(isSuccess) as Void {
        if (isSuccess) {
            $.log.info("Message sent successfully.");
            progressBar.setDisplayString("Success.");
        } else {
            $.log.error("Message failed to send.");
            progressBar.setDisplayString("Failure.");
        }
    }
}
