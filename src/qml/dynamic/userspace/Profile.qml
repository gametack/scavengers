import QtQuick 2.0
import QtGraphicalEffects 1.0
import "../../helpers"

Rectangle {

    property alias profilePicture: profilePicture

    property alias mapBox: mapBox
    //color: "yellow"

    Rectangle {
        id: userCard
        width: parent.width
        height: 400 * dp

        Rectangle {
            id: profilePicture

            property alias picture: picture
            anchors.horizontalCenter: parent.horizontalCenter
            height: 150 * dp
            width: 150 * dp
            radius: 72 * dp
            color: "white"

            Image {
                id: picture
                source: "../../images/male.png"
                fillMode: Image.PreserveAspectFit
                height: 150 * dp
                width: 150 * dp

                sourceSize.width: 300 * dp
                sourceSize.height: 300 * dp
                //visible: false
            }
        }
        Row {
            id: userText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: profilePicture.bottom

            Text {
                id: userNameText

                text: cloud.username
                font.underline: true
                font.bold: true
                font.family: "Arial"

                color: "yellow"

                font.pointSize: 18
            }
            Text {
                //text: "Points:"+ get user total points from db
                id: userPoints
                text: cloud.userPoints
                font.bold: true

                color: "yellow"
                font.pointSize: 18
            }
            spacing: 5
        }
        Column {
            id: inviteEvent
            anchors.bottom: buttons.top
            anchors.topMargin: 5
            anchors.left: buttons.left

            visible: buttons.inviteButtonClicked
            RaisedButton {
                id: inviteButton1
                width: 200 * dp
                height: 50 * dp
                text: "Game Invite"
                color: "#405ede"
                textColor: "white"
            }
            RaisedButton {
                id: inviteButton2
                width: 200 * dp
                height: 50 * dp
                text: "Friend Invite"
                color: "#405ede"
                textColor: "white"
            }
        }

        Row {
            id: buttons
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: userCard.bottom
           // anchors.bottomMargin: -10 * dp
            property bool inviteButtonClicked: false
            RaisedButton {

                id: button1
                width: 200 * dp
                height: 70 * dp
                text: "Invite"
                color: "#405ede"
                textColor: "white"
                onClicked: buttons.inviteButtonClicked = !buttons.inviteButtonClicked
            }
            RaisedButton {
                id: button2
                width: 200 * dp
                height: 70 * dp
                text: "something"
                color: "#FF8000"
                textColor: "white"
            }
            RaisedButton {
                id: button3
                width: 200 * dp
                height: 70 * dp
                text: "Message"
                color: "#04B4AE"
                textColor: "white"
            }
            spacing: 15
        }
    }
    Rectangle {
        id: mapBox
        width: parent.width
        anchors.top: userCard.bottom
        height: 500 * dp
        //color: "blue"
    }
}
