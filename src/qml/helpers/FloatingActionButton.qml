import QtQuick 2.4

Item {
    id: button
    width: 35 * dp
    height: 35 * dp

    property alias color: background.color
    property alias rippleColor: ripple.color
    property alias iconSource: icon.source
    property alias iconWidth: button.width
    property alias iconHeight: button.height
    property alias depth:shadow.depth
    property int shape: 0

    signal clicked

    Rectangle {
        id: background
        anchors.fill: parent
        radius: shape===0?button.height/2:5

        visible: false
    }

    PaperShadow {
        id: shadow
        source: background
        depth: button.enabled ? (mouseArea.pressed ? 6 : 2) : 0
    }

    PaperRipple {
        id: ripple
        radius: button.height/2
        color: "#deffffff"
        mouseArea: mouseArea
        startX: button.height/2
        startY: button.width/2
    }

    Image {
        id: icon
        anchors.centerIn: parent
        width: button.height*0.7
        height: button.height*0.7
        sourceSize.width: width
        sourceSize.height: height
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: button.enabled
        onClicked: button.clicked()
    }
}
