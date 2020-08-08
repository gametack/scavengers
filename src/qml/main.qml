import QtQuick 2.4
import QtQuick.Controls 1.3
import "."
import "dynamic"
import "dynamic/userspace"
import "dynamic/creategame"
import "objectCreation.js" as ObjectCreation
import QtQml.StateMachine 1.0

ApplicationWindow {
    title: qsTr("Hello World")
    width: 480*dp
    height: 640*dp
    color: "#dadada"
    visible: true
    id: root

    property var welcome
    property var login
    // property  var createAdvertisement
    property var createGame

    //    signal sessionAuthenticationSuccess
    //    signal sessionAuthenticationFailure
    //    signal createAdventure
    //    signal cancelAdventure
    //    signal finishAdventure
    //    signal createAdvertisementSignal
    //    signal cancelAdvertisement
    //    signal finishAdvertisement
    //    signal cameraStart

    signal loggedOut

    Component.onCompleted:
    {
        var getInfo = net.loadInfo()
        //getInfo = "false"
        if(getInfo === "false")
        {

            cloud.con.loginType=0
            cloud.login("","")
        }
        else
        {//set  connection type to be zero meaning we are logging in
            cloud.con.loginType=0
            cloud.login(getInfo.username,getInfo.password)
        }
    }

    Cloud{
        id:cloud
        property alias con:con
        Connections
        {
            id:con
            target: cloud.client
            property bool logginIn: false
            property int loginType:0 //0=login 1=signup
            property var registerInfo
            onSessionAuthenticated: {
                cloud.getDb()
                if(con.loginType===0)
                {
                    socket.getSocketUri(cloud.username)
                }
                else
                {
                    cloud.addUserToAllUsersGroup(con.registerInfo.userId,con.registerInfo.user,con.registerInfo.profilePicPath)
                }
                if(con.logginIn)
                {
                    con.logginIn=false
                    login.destroy()
                }
                userSpace.visible = true
                //                userSpace.userSpaceActionBar.color = "#405ede"
                //                //mapItem.parent=userSpace.profile.mapBox
                userSpace.state = "mainPage"

            }
            onSessionAuthenticationError: {
                if(!con.logginIn)
                {
                    logginIn=true
                    login=ObjectCreation.createObject("dynamic/Login.qml",root,{z:-1})
                    console.log("Error authenticating")
                }
            }
            onSessionTerminated: {
                console.log("we've terminated")
                net.saveInfo("","")
                if(!con.logginIn)
                {
                    logginIn=true
                    login=ObjectCreation.createObject("dynamic/Login.qml",root,{z:-1})
                    console.log("Error authenticating")
                }
            }


        }
    }

    Socket{
        id:socket
    }

    UserSpace{
        id: userSpace
        visible: false
    }
}
