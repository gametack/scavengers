import QtQuick 2.0
import QtGraphicalEffects 1.0
import "../../helpers"
import "../../objectCreation.js" as ObjectCreation

Rectangle{
    id:sideBar
    height: parent.height
    width: parent.width * 0.7
    x: -(width+10)

    color: "#303030"

    Behavior on x {
        NumberAnimation {
            duration: 300
            easing.type: Easing.Linear
        }
    }

    states:[

        State{
            name: ""
            PropertyChanges{
                target:profileNavigation
                visible: true
            }
            PropertyChanges{
                target:userSearchNavigation
                visible: true
            }
            PropertyChanges{
                target:createGameNavigation
                visible: true
            }
            PropertyChanges{
                target:settingsNavigation
                visible: true
            }
            PropertyChanges{
                target:aboutUsNavigation
                visible: true
            }
            PropertyChanges{
                target:advertiseNavigation
                visible: true
            }
            PropertyChanges{
                target:logOutNavigation
                visible: true
            }
            PropertyChanges{
                target:userList
                visible: false
            }
            PropertyChanges{
                target:backToMenu
                enabled: false
            }
        },
        State{
            name: "friendNavigation"
            PropertyChanges{
                target:backToMenu
                enabled: true
            }
            PropertyChanges{
                target:profileNavigation
                visible: false
            }
            PropertyChanges{
                target:userSearchNavigation
                visible: false
            }
            PropertyChanges{
                target:createGameNavigation
                visible: false
            }
            PropertyChanges{
                target:settingsNavigation
                visible: false
            }
            PropertyChanges{
                target:aboutUsNavigation
                visible: false
            }
            PropertyChanges{
                target:advertiseNavigation
                visible: false
            }
            PropertyChanges{
                target:logOutNavigation
                visible: false
            }
            PropertyChanges{
                target:userList
                visible: false
            }

        },
        State{
            name: "userSearchNavigation"
            PropertyChanges{
                target:backToMenu
                enabled: true
            }
            PropertyChanges{
                target:profileNavigation
                visible: false
            }
            PropertyChanges{
                target:userSearchNavigation
                visible: true
            }
            PropertyChanges{
                target:createGameNavigation
                visible: false
            }
            PropertyChanges{
                target:settingsNavigation
                visible: false
            }
            PropertyChanges{
                target:aboutUsNavigation
                visible: false
            }
            PropertyChanges{
                target:advertiseNavigation
                visible: false
            }
            PropertyChanges{
                target:logOutNavigation
                visible: false
            }
            PropertyChanges{
                target:userList
                visible: true
            }
        },
        State{
            name: "settingsNavigation"
            PropertyChanges{
                target:backToMenu
                enabled: true
            }
            PropertyChanges{
                target:profileNavigation
                visible: false
            }
            PropertyChanges{
                target:userSearchNavigation
                visible: false
            }
            PropertyChanges{
                target:createGameNavigation
                visible: false
            }
            PropertyChanges{
                target:settingsNavigation
                visible: true
            }
            PropertyChanges{
                target:aboutUsNavigation
                visible: false
            }
            PropertyChanges{
                target:advertiseNavigation
                visible: false
            }
            PropertyChanges{
                target:logOutNavigation
                visible: false
            }
            PropertyChanges{
                target:userList
                visible: false
            }
        },
        State{
            name: "aboutUsNavigation"
            PropertyChanges{
                target:backToMenu
                enabled: true
            }
            PropertyChanges{
                target:profileNavigation
                visible: false
            }
            PropertyChanges{
                target:userSearchNavigation
                visible: false
            }
            PropertyChanges{
                target:createGameNavigation
                visible: false
            }
            PropertyChanges{
                target:settingsNavigation
                visible: false
            }
            PropertyChanges{
                target:aboutUsNavigation
                visible: true
            }
            PropertyChanges{
                target:advertiseNavigation
                visible: false
            }
            PropertyChanges{
                target:logOutNavigation
                visible: false
            }
            PropertyChanges{
                target:userList
                visible: false
            }
        }


    ]

    Column{
        id:sideBarCol
        anchors.top:parent.top
        width: parent.width
        focus: true

        move: Transition {
            NumberAnimation { properties: "x,y"; duration: 250; easing.type: Easing.OutBack }
        }

        RaisedButton{
            id:profileNavigation
            height: 70*dp
            width: parent.width
            visible: true
            color: "transparent"
            depth:0
            rippleColor:"blue"
            Text{
                text: "User Profile"
                anchors.fill: parent
                color:"white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                menu_form.onMenu()
                menu_form.onProfile()
            }

        }
        RaisedButton{
            id:userSearchNavigation
            rippleColor:"blue"
            depth:0
            //only enable this if in hunt
            height: 70*dp
            color: "transparent"

            width: parent.width
            // anchors.top:profileNavigation.bottom
            Text{
                id:userTitle
                text: "Friends & Users"
                anchors.fill: parent
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

            }

            onClicked: {
                sideBarView.state = "userSearchNavigation"


            }



        }
        RaisedButton{
            id:createGameNavigation
            rippleColor:"blue"
            height: 70*dp
            width: parent.width
            color: "transparent"
            depth:0

            //anchors.top:userListNavigation.bottom
            Text{
                text: "Create Adventure"
                anchors.fill: parent
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

            }

            onClicked: {
                ObjectCreation.createObject("dynamic/creategame/CreateGame.qml",sideBar.parent,{})
            }

        }

        RaisedButton{
            id:settingsNavigation
            height: 70*dp
            width: parent.width
            color: "transparent"
            depth:0
            rippleColor:"blue"

            //anchors.top:dataNavigation.bottom
            Text{
                text: "Settings"
                anchors.fill: parent
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                sideBarView.state = "settingsNavigation"
            }

        }

        RaisedButton{
            id:advertiseNavigation
            height: 70*dp
            width: parent.width
            color: "transparent"
            depth:0
            rippleColor:"blue"

            //anchors.top:settingsNavigation.bottom
            Text{
                text: "Advertise with Us"
                anchors.fill: parent
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                menu_form.onMenu()
                root.createAdvertisementSignal()

            }

        }
        RaisedButton{
            id:aboutUsNavigation
            height: 70*dp
            width: parent.width
            color: "transparent"
            depth:0
            rippleColor:"blue"
            Text{
                text: "About Us"
                anchors.fill: parent
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                sideBarView.state = "aboutUsNavigation"
            }

        }
        RaisedButton{
            id:logOutNavigation
            height: 70*dp
            width: parent.width
            color: "transparent"
            depth:0
            rippleColor:"blue"
            Text{
                text: "Logout"
                anchors.fill: parent
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }


            onClicked: {
                root.userLoggedOut()
            }

        }
    }
    MouseArea{
        id:backToMenu
        height: 70*dp
        width: parent.width
        enabled:false
        onClicked: {
            sideBarView.state = ""
        }
    }
    Rectangle{
        id:userList
        width:parent.width-25*dp
        height: parent.height - userSearchNavigation.height
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10*dp
        anchors.horizontalCenter: parent.horizontalCenter
        // anchors.top:parent.top
        radius: 10*dp

        clip:true
        visible: false

        //        TextField{
        //            id:searchFriend
        //            anchors.top:parent.top
        //            anchors.horizontalCenter: parent.horizontalCenter
        //            height:50*dp
        //            width:parent.width-20*dp
        //            anchors.margins: 10*dp
        //            focus:false
        //            placeholderText: "Friend and User Search"
        //            onTextChanged: {
        //                userSearchResult.visible = true
        //                cloud.usersListModel.query={"objectType":"objects.userMap", "query":{"username":text}, "limit":20, "sort":[{"sortBy":"username","direction":"asc"}]}
        //                //cloud.userSearchModel.queryUsers(text)
        //            }
        //        }

        Component{
            id:userDelegateComponent
            RaisedButton{

                height:60*dp
                width:userList.width

                Item{
                    id:profilePictureItemUser

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left:parent.left
                    anchors.leftMargin: 10*dp
                    width: 60*dp
                    height:60*dp


                    Image{
                        id: profilePicUser
                        //source: get from user Db:
                        //source:avatarSrc
                        height: 50*dp
                        width: 50*dp
                        sourceSize.width: 60*dp
                        sourceSize.height: 60*dp
                        visible: false
                    }
                    Image {
                        id: maskUser
                        source: "../../images/black_circle.png"
                        sourceSize.width: 60*dp
                        sourceSize.height: 60*dp
                        smooth: true
                        visible: false
                    }
                    OpacityMask {
                        anchors.fill: profilePicUser
                        source: profilePicUser
                        maskSource: maskUser
                    }

                }
                Text{
                    id:userText
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: profilePictureItemUser.right
                    anchors.leftMargin: 10*dp
                    text:username
                }

                //                TextField{
                //                    id:playerMessage1
                //                    anchors.verticalCenter: parent.verticalCenter
                //                    anchors.left: profilePictureItemUser.right
                //                    anchors.leftMargin: 10*dp
                //                    visible: false
                //                    placeholderText: "Message to " + username
                //                }

                FloatingActionButton{
                    id:userAddFriend
                    anchors.right:parent.right

                    anchors.rightMargin: 10*dp
                    color:"grey"
                    iconHeight: 45*dp
                    iconWidth: 45*dp
                    iconSource: "../../svg/person_add.svg"
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: {
                        if(playerMessage1.visible===false){
                            userText.visible = false
                            playerMessage1.visible =true
                        }
                        else{
                            //cloud.sendPrivateMessage()
                            userText.visible = true
                            playerMessage1.visible =false

                        }
                    }
                }
                FloatingActionButton{
                    id:userMessageFriend
                    anchors.right:parent.right
                    anchors.rightMargin: 10*dp
                    visible: false
                    color:"grey"
                    iconHeight: 45*dp
                    iconWidth: 45*dp
                    iconSource: "../../svg/ic_message_24px.svg"
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: {

                        if(playerMessage1.visible===false){
                            userText.visible = false
                            playerMessage1.visible =true
                        }
                        else{
                           //cloud.sendPrivateMessage()
                            userText.visible = true
                            playerMessage1.visible =false
                        }
                    }
                }

            }

        }

        ListView{
            id: userSearchResult
            width:parent.width
            anchors.top:searchFriend.bottom
            anchors.topMargin:10*dp
            anchors.bottom:parent.bottom
            // model:(!searchFriend.focus) ? cloud.usersListModel : cloud.friendListModel
            model: cloud.usersListModel
            highlightFollowsCurrentItem: true
            clip:true

            //delegate:( userSearchResult.model === cloud.friendListModel) ?  friendDelegateComponent:userDelegateComponent
            delegate: userDelegateComponent
            //  spacing: 5
        }
    }
}

