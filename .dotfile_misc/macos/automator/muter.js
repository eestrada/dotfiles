const app = Application.currentApplication();
app.includeStandardAdditions = true;

function disableMicrophone() {
	app.setVolume(null, { inputVolume: 0 });
	app.say("Off.", { using: "Alex" });
	app.displayNotification("Microphone OFF", {
		withTitle: "Sound input",
		subtitle: "Disabled",
		soundName: "Submarine"
	});
}

function enableMicrophone() {
	app.say("On.", { using: "Alex" })
	app.displayNotification("Microphone ON", {
		withTitle: "Sound input",
		subtitle: "Enabled",
		soundName: "Ping"
	});
	app.setVolume(null, { inputVolume: 100 });
}

function getMicrophoneVolume() {
	return Number(app.getVolumeSettings()["inputVolume"]);
}

function run(input, parameters) {
	if (getMicrophoneVolume() > 0) {
		disableMicrophone();
	} else {
		enableMicrophone();
	}

	return input;
}