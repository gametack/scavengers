import QtQuick 2.4
import "../../helpers"
import "../../objectCreation.js" as ObjectCreation

Rectangle{
    id:createGameRoot
    anchors.fill: parent
    property var gameType
    signal doneCreation

    onDoneCreation: {
        console.log("Destroying...")
        gameType.destroy()
    }

    RaisedButton{
        id:hunt
        text: qsTr("CREATE A SCAVANGER HUNT GAME")
        width: parent.width-50
        color: "#405ede"
        rippleColor: "yellow"
        radius: 10*dp
        anchors.bottom:tag.top
        anchors.bottomMargin: 20*dp
        anchors.horizontalCenter: parent.horizontalCenter
        height: 60*dp
        onClicked: {
            gameType=ObjectCreation.createObject("dynamic/creategame/Hunt.qml",createGameRoot,{})
        }
    }
    RaisedButton{
        id:tag
        text: qsTr("CREATE A GEOTAG EXPLORER")
        width: parent.width-50
        color: "#405ede"
        rippleColor: "yellow"
        radius: 10*dp
        anchors.centerIn: parent
        height: 60*dp
        onClicked: {
            gameType=ObjectCreation.createObject("dynamic/creategame/Tag.qml",createGameRoot,{})
        }
    }
    RaisedButton{
        id:tour
        text: qsTr("CREATE A TOUR GUIDE")

        width: parent.width-50
        color: "#405ede"
        rippleColor: "yellow"
        radius: 10*dp
        anchors.top:tag.bottom
        anchors.topMargin: 20*dp
        anchors.horizontalCenter: parent.horizontalCenter
        height: 60*dp
        onClicked: {
            gameType=ObjectCreation.createObject("dynamic/creategame/Tour.qml",createGameRoot,{})
        }
    }
        RaisedButton{
            id:tour1
            text: qsTr("END CREATION")

            width: parent.width-50
            color: "RED"
            rippleColor: "yellow"
            radius: 10*dp
            anchors.top:tour.bottom
            anchors.topMargin: 20*dp
            anchors.horizontalCenter: parent.horizontalCenter
            height: 60*dp
            onClicked: {
                console.log("Destroying...")
                createGameRoot.destroy()
            }
        }
}


