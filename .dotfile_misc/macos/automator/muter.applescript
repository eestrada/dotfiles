on getMicrophoneVolume()
	input volume of (get volume settings)
end getMicrophoneVolume

on disableMicrophone()
	set volume input volume 0
	display notification "Microphone OFF" with title "Sound input" subtitle "Disabled" sound name "Submarine"
	say "Microphone off." using "Alex"
end disableMicrophone

on enableMicrophone()
	display notification "Microphone ON" with title "Sound input" subtitle "Enabled" sound name "Ping"
	say "Microphone on."
	set volume input volume 100
end enableMicrophone

if getMicrophoneVolume() is greater than 0 then
	disableMicrophone()
else
	enableMicrophone()
end if