import QtQuick 2.4
import "."

Item {
    id: button
    width: Math.max(88 * dp, label.paintedWidth + 32 * dp)
    height: 36 * dp

    property alias text: label.text
    property color color: "white"
    property alias textColor: label.color
    property alias rippleColor: ripple.color
    property alias depth: shadow.depth

    signal clicked

    Rectangle {
        id: background
        anchors.fill: parent
        //radius: 3 * dp
        color: button.enabled ? button.color : "#eaeaea"
        visible: false
    }

    PaperShadow {
        id: shadow
        source: background
        depth: button.enabled ? (mouseArea.pressed ? 2 : 0) : 0
    }

    Text {
        id: label
        anchors.centerIn: parent
        font.family: UIConstants.sansFontFamily

        opacity: button.enabled ? 1 : 0.62

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.Bezier; easing.bezierCurve: [0.4, 0, 0.2, 1, 1, 1]
            }
        }
    }

    PaperRipple {
        id: ripple
        radius: 3 * dp
        mouseArea: mouseArea
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: button.enabled
        onClicked: button.clicked()
    }
}
