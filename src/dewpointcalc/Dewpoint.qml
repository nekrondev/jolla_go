import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
	property string unitString: ""

	SilicaFlickable {
		anchors.fill: parent
		contentHeight: column.height + Theme.paddingLarge

		PullDownMenu {
			id: pullDownMenu
			MenuItem {
				text: qsTr("About DPC")
				onClicked: pageStack.push(Qt.resolvedUrl("about.qml"))
			}
		}

		VerticalScrollDecorator {}
		Column {
			id: column
			spacing: Theme.paddingLarge
			width: parent.width
			PageHeader { title: qsTr("Dew Point Calculator") }
			ComboBox {
				id: unit
				objectName: "unit"
				width: parent.width
				anchors.left: parent.left
				label: qsTr("Temperature Unit")
				currentIndex: dewpointctrl.unitIndex
				
				menu: ContextMenu {
					id: unitModel
					MenuItem { text: qsTr("Celsius") }
					MenuItem { text: qsTr("Fahrenheit") }
				}
				onCurrentIndexChanged:
				{
					dewpointctrl.switchUnit(currentIndex)
					if (currentIndex == 0) unitString = "°C"
					else unitString = "F"
				}
				Component.onCompleted:
				{
					console.log("Index is", dewpointctrl.unitIndex)
					currentIndex = dewpointctrl.unitIndex
					unit.currentIndexChanged(currentIndex)
				}
			}

			Slider {
				id: tempSlider
				objectName: "tempslider"
				width: parent.width
				anchors.horizontalCenter: parent.horizontalCenter
				valueText: Number(value).toLocaleString(Qt.locale(), "f", 1) + " "+unitString
				value: 0.0
				minimumValue: 0
				maximumValue: 50
				stepSize: 0.1
				label: qsTr("Temperature") + " " + unitString

			}
			Slider {
				id: humidySlider
				objectName: "humidityslider"
				width: parent.width
				anchors.horizontalCenter: parent.horizontalCenter
				value: 30.0
				valueText: Number(value).toLocaleString(Qt.locale(), "f", 1) + " %"
				minimumValue: 0
				maximumValue: 100
				label: qsTr("Humidity %")
			}
			Label {
				text: qsTr("Dew point is at %1 ").arg(Number(dewpointctrl.calc(tempSlider.value, humidySlider.value)).toLocaleString(Qt.locale(), "f", 1)) + unitString
				anchors.horizontalCenter: parent.horizontalCenter
				color: Theme.highlightColor
				font.pixelSize: Theme.fontSizeLarge
				font.family: Theme.fontFamilyHeading
			}

			// Not working, unpack() GO QML has to be modified for QDateTime type
			//Label {
			//	text: qsTr("Last cal time was %1").arg(dewpointctrl.lastcalctime.toLocaleString(Qt.locale, Locale.ShortFormat))
			//	color: Theme.highlightColor
			//	font.family: Theme.fontFamilyHeading
			//}
		}
	}
}

