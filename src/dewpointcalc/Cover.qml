import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {

	property string unitString: ""

	onStatusChanged: 
	{
		if (dewpointctrl.unitIndex == 0) unitString = "°C"
		else unitString = "F";
		coverdata.text =  qsTr("Temp: %1 %4\nHum: %2 %\nDewp: %3 %4").arg(Number(dewpointctrl.temperature).toLocaleString(Qt.locale(), "f", 1)).arg(Number(dewpointctrl.humidity).toLocaleString(Qt.locale(), "f", 1)).arg(Number(dewpointctrl.dewpoint).toLocaleString(Qt.locale(), "f", 1)).arg(unitString)
	}

	Column {
		anchors.centerIn: parent
		width: parent.width
		spacing: Theme.paddingMedium

		Image {
			anchors.horizontalCenter: parent.horizontalCenter
			source: "/usr/share/icons/hicolor/86x86/apps/harbour-dewpointcalc.png"
		}

		Label {
			id: coverdata
			anchors.horizontalCenter: parent.horizontalCenter
			color: Theme.highlightColor
			font.pixelSize: Theme.fontSizeLarge
			text:  qsTr("Temp: %1 %4\nHum: %2%\nDewp: %3 %4").arg(Number(dewpointctrl.temperature).toLocaleString(Qt.locale(), "f", 1)).arg(Number(dewpointctrl.humidity).toLocaleString(Qt.locale(), "f", 1)).arg(Number(dewpointctrl.dewpoint).toLocaleString(Qt.locale(), "f", 1)).arg(unitString)
		}
	}
}
