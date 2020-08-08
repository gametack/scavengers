import QtQuick 2.4

Item {

    anchors.fill: parent
    property alias welcomeImage:welcomeImage
    Image {
        id: welcomeImage
        anchors.centerIn: parent

        sourceSize.height: 150*dp
        sourceSize.width: 150*dp
        source: "../svg/icon.svg"
    }
    Text {
        anchors.top:welcomeImage.bottom
        text:"AdventurUs"
        font.pointSize: 14*dp
        anchors.horizontalCenter: welcomeImage.horizontalCenter
    }
}

