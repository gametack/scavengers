import QtQuick 2.4
import QtGraphicalEffects 1.0
import "../../helpers"

Item {
    id: control
    width: parent.width
    height: 50 * dp

    property alias color: background.color
    property alias depth: ps.depth
    property alias boolRaise: control.raised
    property bool raised: true


    MouseArea {
        id: eventEater
        anchors.fill: parent
    }

    PaperShadow {
        id:ps
        source: background
        depth: control.raised ? 2 : 0
        anchors.fill: parent
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: "white"
    }
    FloatingActionButton {
        id: backButton
        anchors.left: parent.left
        anchors.leftMargin: 10 * dp
        anchors.verticalCenter: parent.verticalCenter
        color: "transparent"
        iconSource: "../../svg/icon_back.svg"
        MouseArea{
            id:temp
            anchors.fill: parent
            onClicked: {
                actionBar.color = "#405ede"
                stackView.pop()
            }
        }
        visible: stackView.depth > 2? true:false

    }
    FloatingActionButton {
        id: settingsButton
        anchors.left: parent.left
        anchors.leftMargin: 10 * dp
        anchors.verticalCenter: parent.verticalCenter
        color: "transparent"
        iconSource: "../../svg/icon_menu.svg"
        MouseArea{
            anchors.fill: parent
            onClicked: {
                sideBar.x=0
            }
        }
        visible: !backButton.visible

    }
    Rectangle {
        id: notificationButton
        height:notification.newMessageCount>0 ? 30*dp: 12*dp
        width:notification.newMessageCount>0 ? 30*dp: 12*dp
        radius:height/2
        anchors.right: parent.right
        anchors.rightMargin: 15 * dp
        anchors.verticalCenter: parent.verticalCenter
        color: notification.newMessageCount>0 ? "red":"grey"

        Text{
            id: notificationCountText
            anchors.centerIn:parent
            text:notification.newMessageCount
            color:"white"
            font.bold: true
            visible: notification.newMessageCount>0 ? true:false
        }

        MouseArea{
            anchors.fill: parent
            onClicked:{

                if(stackView.depth>1)
                {
                    stackView.push({item:notification,replace:true})
                }
                else
                {
                    stackView.push(notification)
                }
            }}

        visible: true
        Behavior on height { SpringAnimation { spring: 10; damping: 0.05} }
        Behavior on width { SpringAnimation { spring: 10; damping: 0.05 } }
        Behavior on color {ColorAnimation{ duration: 1000 }}

    }
    //        Image{
    //            id:discoverButton
    //            height: 40
    //            width: 45
    //            source: "../../svg/discover.svg"
    //            anchors.left: control.left
    //            anchors.leftMargin: 10
    //            MouseArea{
    //                anchors.fill: parent
    //                onClicked:{
    //currentView=1
    //                }
    //            }
    //        }
    //        ColorOverlay {
    //            id:discoverOverlay
    //            color:currentView===1?"#ff5177":"white"
    //            anchors.fill: discoverButton
    //            source: discoverButton
    //        }
    //        Image {
    //            id:adventureButton
    //            height: 40
    //            width: 45
    //            source: "../../svg/adventure.svg"
    //            anchors.right: userSpaceText.left
    //            anchors.rightMargin: 30
    //            MouseArea{
    //                anchors.fill: parent

    //                onClicked:{
    //                    currentView=2
    //                    userSpace.state = "adventurePage"
    //                    if(stackView.depth>1)
    //                    {
    //                        stackView.push({item:adventure,replace:true})
    //                    }
    //                    else
    //                    {
    //                        stackView.push(adventure)
    //                    }
    //                }
    //            }
    //        }

    //        ColorOverlay {
    //            id:adventureOverlay
    //            color:currentView===2?"#ff5177":"white"
    //            anchors.fill: adventureButton
    //            source: adventureButton
    //        }

    Text {
        id: userSpaceText
        anchors.centerIn: parent
        text: "AdventurUs"
        color: "white"
        font.pointSize: 16*dp
        MouseArea{
            anchors.fill: parent
            onClicked: {
                stackView.pop()
                userSpace.state = "mainPage"
            }
        }

    }

    //        Image {
    //            id:peopleButton
    //            height: 40
    //            width: 45
    //            source: "../../svg/people.svg"
    //            anchors.left: userSpaceText.right
    //            anchors.leftMargin: 30
    //            MouseArea{

    //                anchors.fill: parent

    //                onClicked:{
    //                    currentView=3

    //                }
    //            }
    //        }

    //        ColorOverlay {
    //            id:peopleOverlay
    //            color:currentView===3?"#ff5177":"white"
    //            anchors.fill: peopleButton
    //            source: peopleButton
    //        }

    //        Image {
    //            id: notificationButton
    //            height: 40
    //            width: 45
    //            // color: userSpace.notification ? "red" : "grey"
    //            anchors.right: control.right
    //            anchors.rightMargin: 10
    //            Text {
    //                id: notificationCountText
    //                anchors.centerIn: parent
    //                text: "1"
    //                color: "white"
    //                font.bold: true
    //            }
    //            source: "../../svg/notification.svg"
    //            MouseArea{
    //                anchors.fill: parent
    //                onClicked:{
    //                    currentView=4
    //                    userSpace.state = "notificationPage"
    //                    if(stackView.depth>1)
    //                    {
    //                        stackView.push({item:notification,replace:true})
    //                    }
    //                    else
    //                    {
    //                        stackView.push(notification)
    //                    }
    //                }

    //            }
    //        }

    //        ColorOverlay {
    //            id:notificationOverlay
    //            color:currentView===4?"#ff5177":"white"
    //            anchors.fill: notificationButton
    //            source: notificationButton
    //        }
}
