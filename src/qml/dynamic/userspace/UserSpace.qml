import QtQuick 2.4
import "../../helpers"
import "../"
import "."
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0
import QtLocation 5.3
import QtPositioning 5.3

Item {

    id: userSpace
    anchors.fill: parent
    clip:true

    property bool userSpace_shown: false
    property bool expanded: false
    //property bool notification: false

    property alias userSpaceActionBar: actionBar
    property alias notification: notification


    transform: [Translate {
            id: sidebar_translate
            x: 0
            Behavior on x { NumberAnimation { duration: 300
                    easing.type: Easing.InOutQuad } }
        }]

    states: [
        State {
            name: "mainPage"

        },
        State {
            name: "discoverPage"
        },
        State {
            name: "adventurePage"

        },
        State {
            name: "peoplePage"

        },
        State {
            name: "notificationPage"

        }
    ]




    ActionBar {
        id: actionBar
        raised: true
        color: "#405ede"
        //z: playSpace.visible ? 0:2
        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }

//        SwipeArea{
//            anchors.left: parent.left
//            anchors.top:parent.top
//            anchors.bottom: parent.bottom
//            width: 100*dp
//            onSwipe: {
//                switch(direction){
//                case "right":
//                    sideBar.x=0
//                }
//            }

//        }
    }

    StackView {
        id: stackView
        anchors {
            top: actionBar.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            topMargin: -1
            bottomMargin: -1
            leftMargin: -1
            rightMargin: -1
        }
        initialItem: adventure
        delegate: StackViewDelegate {
            function transitionFinished(properties)
            {
                properties.exitItem.opacity = 1
            }

            pushTransition: StackViewTransition {
                PropertyAnimation {
                    target: enterItem
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 350
                }
                PropertyAnimation {
                    target: exitItem
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: 350
                }
            }
        }
    }
//    Row{
//        id:bottomMenu
//        anchors.bottom: parent.bottom
//        //anchors.bottomMargin: 32*dp
//        anchors.horizontalCenter: parent.horizontalCenter
//        FloatingActionButton {
//            id: discoverButton
//            width: 30*dp
//            height: 30*dp
//            shape: 1
//            color: "#C0C0C0"
//            iconSource: "../../svg/discover.svg"
//            onClicked: {

//            }

//        }
//        FloatingActionButton {
//            id: homeButton
//            width:30*dp
//            height: 30*dp
//            shape: 1
//            color: "#C0C0C0"
//            iconSource: "../../svg/icon.svg"
//            onClicked: {
//                stackView.pop()
//                userSpace.state = "mainPage"
//            }

//        }
//        FloatingActionButton {
//            id: peopleButton
//            width: 30*dp
//            height:30*dp
//            shape: 1
//            color: "#C0C0C0"
//            iconSource: "../../svg/people.svg"
//            onClicked: {

//            }

//        }
//        spacing:60*dp
//    }


    SideBar {
        id: sideBar

    }

    Notification {
        id: notification
        visible: false
    }



    //    Profile {
    //        id: profile

    //        visible: false
    //        //anchors.fill: parent
    //        // color: "#303030"
    //        // opacity: userSpace.profile_shown ? 1 : 0
    //        // enabled: userSpace.profile_shown ? true:false
    //        //        Behavior on opacity { NumberAnimation { duration: 100}}

    //        //        gradient: Gradient {
    //        //            GradientStop { position: 0.0; color: "#303030" }
    //        //            GradientStop { position: 0.8; color: "#405ede" }
    //        //            //  GradientStop { position: 1.0; color: "green" }
    //        //        }
    //    }



    Adventure{
        id: adventure
        visible: false
    }

}


