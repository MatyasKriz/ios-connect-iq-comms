using Toybox.Application;
using Toybox.WatchUi as Ui;
using Toybox.Timer;
using Toybox.Communications as Comms;

var log = new Log(LOG_LEVEL_VERBOSE);

enum {
    MESSAGE_KEY_LATITUDE = 0,
    MESSAGE_KEY_LONGITUDE = 1,
    MESSAGE_KEY_MESSAGE = 2
}

class ExampleCommsApp extends Application.AppBase {
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

    function phoneMessageCallback(_message) {
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

    function updateMessage() {
        $.log.verbose("Updating message.");

        progressBar.setDisplayString("Sending..");

		// basic string
//		var message = "heya!"

		// standard dictionary
        var message = [
            {
                MESSAGE_KEY_LATITUDE => 49.233162,
                MESSAGE_KEY_LONGITUDE => 16.572311,
                MESSAGE_KEY_MESSAGE => "NAyayayaaa"
            },
            {
                MESSAGE_KEY_LATITUDE => 49.216426,
                MESSAGE_KEY_LONGITUDE => 16.587749,
                MESSAGE_KEY_MESSAGE => "Ayayayaaa"
            }
        ];
        $.log.verbose("Transmitting message.");
        Comms.transmit(message, null, new CommsRelay(method(:onTransmitComplete)));
        $.log.verbose("Message transmitted.");
    }

	// If you're debugging a problem with connecting/transmitting message, consult `README.md`.
    function onTransmitComplete(isSuccess) {
        if (isSuccess) {
            $.log.info("Message sent successfully.");
            progressBar.setDisplayString("Success.");
        } else {
            $.log.error("Message failed to send.");
            progressBar.setDisplayString("Failure.");
        }
    }
}
