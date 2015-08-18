import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
	id: aboutpage
	SilicaFlickable {
		anchors.fill: parent
		contentWidth: parent.width
		contentHeight: col.height + Theme.paddingLarge

		VerticalScrollDecorator {}

		Column {
			id: col
			spacing: Theme.paddingLarge
			width: parent.width
			PageHeader {
				title: qsTr("About DPC")
			}

			Image {
				anchors.horizontalCenter: parent.horizontalCenter
				source: "/usr/share/icons/hicolor/86x86/apps/harbour-dewpointcalc.png"
			}

			SectionHeader {
				text: qsTr("Information")
			}
			Label {
				text: qsTr("Dew point calculation based on formulas found on\
				<a href='http://www.wetterochs.de/wetter/feuchte.html'>www.wetterochs.de</a><br><br>\
				This application has been build using GO language and QML bindings.<br>\
				It was a proof of concept to verify GO runtime compilation for ARM target,\
				building cgo QML bindings and launching Silica QML from it.<br>\
				(C)2015 Nekron, released as freeware (maybe someone finds it useful).")
				anchors.horizontalCenter: parent.horizontalCenter
				wrapMode: Text.WrapAtWordBoundaryOrAnywhere
				width: (parent ? parent.width : Screen.width) - Theme.paddingLarge * 2
				verticalAlignment: Text.AlignVCenter
				horizontalAlignment: Text.AlignLeft
				x: Theme.paddingLarge
			}
			SectionHeader {
				text: qsTr("Additional Copyright")
			}

			Label {
				text: qsTr("<a href='https://github.com/go-qml/qml'>GO-QML package</a> (C) Gustavo Niemeyer.")
				anchors.horizontalCenter: parent.horizontalCenter
				wrapMode: Text.WrapAtWordBoundaryOrAnywhere
				width: (parent ? parent.width : Screen.width) - Theme.paddingLarge * 2
				verticalAlignment: Text.AlignVCenter
				horizontalAlignment: Text.AlignLeft
				x: Theme.paddingLarge
			}
			Label {
				text: qsTr("<a href='https://golang.org/'>GO</a> Copyright (c) 2012 The Go Authors. All rights reserved.")
				anchors.horizontalCenter: parent.horizontalCenter
				wrapMode: Text.WrapAtWordBoundaryOrAnywhere
				width: (parent ? parent.width : Screen.width) - Theme.paddingLarge * 2
				verticalAlignment: Text.AlignVCenter
				horizontalAlignment: Text.AlignLeft
				x: Theme.paddingLarge
			}

			Label {
				text: qsTr("Compiled using GO Runtime %1<br>Application version %2").arg(dewpointctrl.runtimeVersion()).arg(dewpointctrl.version())
				anchors.horizontalCenter: parent.horizontalCenter
				wrapMode: Text.WrapAtWordBoundaryOrAnywhere
				width: (parent ? parent.width : Screen.width) - Theme.paddingLarge * 2
				verticalAlignment: Text.AlignVCenter
				horizontalAlignment: Text.AlignLeft
				x: Theme.paddingLarge
			}
		}
	}
}

