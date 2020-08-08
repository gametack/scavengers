import QtQuick 2.4

Item {
    id: card

    property bool raised: true
    property alias mouseArea: mouseArea

    signal clicked

    Rectangle {
        id: background
        anchors.fill: parent
        color: "lightgrey"
        radius: 10*dp
        visible: false
    }

    PaperShadow {
        id: shadow
        source: background
        depth: card.enabled ? (card.raised ? 2 : 1) : 0
    }


}
