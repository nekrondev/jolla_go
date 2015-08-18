import QtQuick 2.0
import Sailfish.Silica 1.0

ApplicationWindow {
	id: mainWindow
	cover: Qt.resolvedUrl("Cover.qml")
	initialPage: Component { Dewpoint { id: dpMain } }
	allowedOrientations: Orientation.All
	_defaultPageOrientations: Orientation.All
}

