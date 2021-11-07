# Risk-prevention-app
Risk prevention app. It enables workers and supervisors at a construction to report, share, responde and resolve risk situations at work.
## General info
This project is makes it possible for workers or supervisors at a construction to upload a construction risk report, filling out a dinamic form defined with a web service, adding pictures, videos or audios and sending it to a particular supervisor working on this construction. 
On login, the app determines if the user is a construction worker or a supervisor. There is a basic mode for construction workers, and an advanced mode for supervisors. The basic mode lets workers report incidents to a specific supervisor and recieve an answer, navigate through a risk prevention library (which is a web viewer) and look at the history of reports. The advanced mode has the same functions, with some extra ones: the advanced mode let's supervisors share reports with other supervisors on the same construction, answer reports and add more information and/or media.
When doing a report the app uses the phones location to recognize quickly at which construction the user is currently standing, and with this information the formulary is loaded and the list of available supervisors to report to, etc.

## Technologies
Project is created with:
* Flutter 1.22.3 • channel stable
* Dart 2.10.3