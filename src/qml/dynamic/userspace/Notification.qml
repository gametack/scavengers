import QtQuick 2.4
import "../../helpers"
import QtQuick.Controls 1.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.2

Rectangle{
    id:notificationView
    property alias userMessageList:userMessageList
    property alias inviteList: inviteList
    property int currentIndex:-1
    property int newMessageCount: cloud.noticeModel.unreadCount+cloud.messagesModel.unreadCount
    function sendMessage(messageObject,index)
    {

        if(index!==-1)//meaning update message
        {

            cloud.messagesModel.updateMessage(messageObject,index)
        }
        else//new message
        {

            cloud.messagesModel.addNewMessage(messageObject)
        }
    }


    Rectangle{
        id: inviteList
        property var selectedPlayers: []
        property string messageToSend: inviteMessage.text
        property string caller: ""
        visible: false

        function clearList(){
            selectedPlayers=[]
            findUsers.text=""
            inviteMessage.text=""

        }

        function open()
        {
            cloud.usersListModel.query= {"objectType":"objects.userMap", "query":{"username":{"$ne":cloud.username}}, "limit":10, "sort":[{"sortBy":"username","direction":"asc"}]}

            if(stackView.depth>2)
            {
                stackView.push({item:inviteList,replace:true})
            }
            else
            {
                stackView.push(inviteList)
            }
        }

        Rectangle{
            id:inviteContent
            radius:6*dp
            anchors.fill:parent
            anchors.margins: 12*dp
            color: "white"

            TextField{
                id:findUsers
                height: 35*dp
                anchors.margins: 6*dp
                anchors.top: parent.top
                anchors.left:parent.left
                anchors.right:parent.right
                placeholderText: "User & Friends Search"
                horizontalAlignment: Text.AlignHCenter
                onTextChanged: {
                    cloud.usersListModel.query= {"objectType":"objects.userMap", "query":{"username":text}, "limit":20, "sort":[{"sortBy":"username","direction":"asc"}]}
                }

            }
            ListView{
                id: inviteView
                anchors.margins: 6*dp
                anchors.top: findUsers.bottom
                anchors.left:parent.left
                anchors.right:parent.right
                anchors.bottom: inviteMessage.top
                clip:true

                width:parent.width
                model:cloud.usersListModel
                delegate: Item{
                    width:parent.width
                    height:35*dp
                    Item{
                        id:uimageItem

                        anchors.verticalCenter: parent.verticalCenter
                        width: 35*dp
                        height:35*dp

                        Image{
                            id: uimage
                            //source: get from user Db:
                            //source: avatarSrc
                            height: 35*dp
                            width: 35*dp
                            sourceSize.width: 35*dp
                            sourceSize.height: 35*dp
                            visible: false
                        }

                        Image {
                            id:maskk
                            source: "../../images/black_circle.png"
                            sourceSize.width: 35*dp
                            sourceSize.height: 35*dp
                            smooth: true
                            visible: false
                        }
                        OpacityMask {
                            anchors.fill: uimage
                            source: uimage
                            maskSource: maskk
                        }

                    }
                    Text {
                        id: uname
                        anchors.left: uimageItem.right
                        anchors.leftMargin: 6*dp
                        anchors.verticalCenter: parent.verticalCenter
                        font.pointSize: 10*dp
                        text: username
                    }
                    CheckBox{
                        anchors.right:parent.right
                        anchors.rightMargin: 12*dp
                        anchors.verticalCenter: parent.verticalCenter
                        onCheckedChanged: {
                            if(checked)
                            {
                                if(inviteList.selectedPlayers.indexOf(username)===-1)
                                {
                                    inviteList.selectedPlayers.push(username)
                                }
                            }
                            else
                            {
                                inviteList.selectedPlayers.splice(inviteList.selectedPlayers.indexOf(username),1)
                            }
                        }
                        Component.onCompleted:
                        {//this for querying so that it doesn't remove selected users and checked when user searches for username and it queries data base and change list of players
                            if(inviteList.selectedPlayers.indexOf(username)!==-1)
                            {
                                checked=true
                            }
                        }
                    }
                    Rectangle{
                        width:parent.width - 20
                        height: 2*dp
                        color:"lightgrey"
                        anchors.bottom:parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                }
            }
            TextArea{
                id:inviteMessage
                anchors.bottom: select.top
                anchors.margins: 6*dp
                anchors.left:parent.left
                anchors.right:parent.right
                width: parent.width
                visible: inviteList.caller==="message"?true:false
                height:50*dp
                clip:true
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 15*dp
                wrapMode: TextEdit.WrapAtWordBoundaryOrAnywhere

            }

            RaisedButton{
                id:select
                text: inviteList.caller==="message"?"SEND":"SELECT"
                anchors.left:parent.left
                anchors.right:parent.right
                anchors.bottom:parent.bottom
                anchors.margins: 6*dp

                rippleColor: "white"
                width: parent.width
                color: "#ff5177"
                height: 60*dp
                onClicked: {
                    if(inviteList.selectedPlayers.length!==0 && inviteList.caller==="message")
                    {
                        inviteList.selectedPlayers.sort()
                        var messageObject={
                            message:
                            {
                                player:cloud.username,
                                message:inviteList.messageToSend,
                                createdAt:cloud.getDate()
                            },
                            type:"message",
                            players:inviteList.selectedPlayers,
                        }
                        cloud.db.transaction(function(tx){
                            var ret=tx.executeSql('SELECT * FROM Notification WHERE players='+JSON.stringify(messageObject.players.toString()))
                            var index=-1
                            messageObject.notification_id=0

                            if(ret.rows.length!==0)
                            {
                                messageObject.notification_id=ret.rows.item(0).notification_id

                                index=cloud.messagesModel.count-messageObject.notification_id //see comment in cloud.messagesModel.loadMessage for details about notification id to index

                            }

                            sendMessage(messageObject,index)
                            inviteList.clearList()
                        })


                    }
                    stackView.pop()
                }
            }
        }
    }

    TabView {
        id:tabview
        //        anchors{
        //            top:newMessageButton.bottom
        //            bottom: parent.bottom
        //            left: parent.left
        //            right:parent.right
        //            topMargin: 6*dp
        //        }
        anchors.fill: parent
        style: TabViewStyle {
            frameOverlap: 1
            tab: Rectangle {
                color: styleData.selected ? "steelblue" :"lightsteelblue"
                border.color:  "steelblue"
                implicitWidth:  tabview.width/2
                implicitHeight: 50*dp
                radius: 2*dp
                Text {
                    id: text1
                    anchors.centerIn: parent
                    text: styleData.title.split("|")[0]
                    color: styleData.selected ? "white" : "black"
                }
                Rectangle {
                    height:styleData.title.split("|")[1]>0 ? 30*dp: 12*dp
                    width:styleData.title.split("|")[1]>0 ? 30*dp: 12*dp
                    radius:height/2
                    anchors.right: parent.right
                    anchors.rightMargin: 5*dp
                    anchors.verticalCenter: parent.verticalCenter
                    color: styleData.title.split("|")[1]>0 ? "red":"grey"

                    Text{
                        id: countText
                        anchors.centerIn:parent
                        text:styleData.title.split("|")[1]
                        color:"white"
                        font.bold: true
                        visible: styleData.title.split("|")[1]>0 ? true:false
                    }


                    visible: true
                    Behavior on height { SpringAnimation { spring: 10; damping: 0.05} }
                    Behavior on width { SpringAnimation { spring: 10; damping: 0.05 } }
                    Behavior on color {ColorAnimation{ duration: 1000 }}

                }

            }
            //frame: Rectangle { color: "steelblue" }
        }
        Tab {
            title: "Notice|"+cloud.noticeModel.unreadCount


            ListView {
                id:noticeList
                clip:true
                anchors.fill: parent

                anchors.topMargin: 5*dp
                spacing: 5*dp

                model:cloud.noticeModel
                delegate:Rectangle{

                    width:parent.width-10
                    height: 85*dp
                    anchors.horizontalCenter: parent.horizontalCenter
                    border.color: "#4C67A1"
                    border.width: 1*dp
                    radius: 5*dp
                    color: read===0?"#CAE0FE":"transparent"
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {

                        }
                    }
                    Item{
                        id:senderProfileItem
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 20*dp
                        anchors.left:parent.left

                        width: 50*dp
                        height:50*dp

                        Image{
                            id: senderProfile
                            //grr.... get from backend
                            source: "../../images/cute_cat.jpg"
                            height: 50*dp
                            width: 50*dp
                            sourceSize.width: 50*dp
                            sourceSize.height: 50*dp
                            visible: false
                        }

                        Image {
                            id:mask
                            source: "../../images/black_circle.png"
                            sourceSize.width: 50*dp
                            sourceSize.height: 50*dp
                            smooth: true
                            visible: false
                        }
                        OpacityMask {
                            anchors.fill: senderProfile
                            source: senderProfile
                            maskSource: mask
                        }

                    }

                    Column{
                        id: noticeContent
                        spacing: 15*dp
                        anchors.right: noticeInfo.left
                        anchors.left:senderProfileItem.right
                        anchors.leftMargin: 20*dp
                        clip: true
                        Text{
                            text: "Game Invite From "+player
                            clip:true
                            font.pixelSize: 15*dp
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                        Text{
                            text: type==="gameinvite"?extra:message
                            clip:true
                            font.pixelSize: 15*dp
                            color: "blue"
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                        Text{
                            visible: type==="gameinvite"?true:false
                            text: "Game: "+ message
                            clip:true
                            wrapMode: Text.WordWrap
                            font.pixelSize: 15*dp
                            width: parent.width

                        }
                    }

                    Column{
                        id: noticeInfo
                        spacing: 15*dp
                        anchors.right: parent.right
                        // anchors.left:messageContent.right
                        clip: true
                        Text{
                            anchors.right: parent.right
                            text: createdAt
                            clip:true
                            font.pixelSize: 12*dp
                            // width: parent.width
                            wrapMode: Text.WordWrap
                        }
                        Row{
                            id:rowButton

                            //anchors.verticalCenter: parent.verticalCenter
                            spacing: 2*dp
                            visible: (type==="gameinvite" ||type==="friendrequest") ?true:false
                            RaisedButton{
                                color: "green"
                                text: "accept"
                                width: 80*dp
                                height:50*dp
                                radius: 6*dp

                                onClicked: {


                                    var reply = cloud.client.query({"objectType":"objects.activeGames","query":{"players":player,name:message}})
                                    reply.finished.connect(function(){
                                        if(!reply.isError)
                                        {
                                            var notice={}
                                            var hold
                                            var data = reply.data.results[0]
                                            data.players.push(cloud.username)
                                            cloud.client.update(data)

                                            hold=JSON.stringify(data.players)
                                            delete data["players"]
                                            data.players=hold
                                            cloud.activeGamesListModel.addGameLocal([data])

                                            notice.message={
                                                "message":"Accepted game invite",
                                                "player":cloud.username}
                                            console.log(player)
                                            notice.players=player.split(",")
                                            notice.type="requestanswer"
                                            cloud.noticeModel.removeNotice(index)
                                            cloud.noticeModel.sendNotice(notice)
                                        }
                                        else
                                        {
                                            console.log("Error"+reply.errorString)
                                        }
                                    })

                                }
                            }
                            RaisedButton{
                                color: "red"
                                text: "decline"
                                width: 80*dp
                                height:50*dp
                                radius: 6*dp
                                onClicked: {

                                    //decide if to send declined notice or remain anonymous with declines
                                    //                                notice.message={
                                    //                                    message:"Declined game invite",
                                    //                                    player:cloud.username}
                                    //                                notice.players=[player]
                                    //                                notice.type="requestanswer"
                                    //                                cloud.noticeModel.sendNotice(notice)
                                    cloud.noticeModel.removeNotice(index)
                                }
                            }
                        }
                    }
                }
            }
        }
        Tab {
            id:messageTab
            title: "Messages|"+cloud.messagesModel.unreadCount

            Rectangle{

                anchors.fill: parent
                ListView {
                    id:messageList
                    clip:true
                    anchors{
                        top:parent.top
                        bottom: newMessageButton.top
                        left: parent.left
                        right:parent.right
                        topMargin: 5*dp
                    }

                    spacing: 5*dp

                    model:cloud.messagesModel
                    delegate:Rectangle{
                        id:messageItem

                        width:parent.width-10
                        height: 85*dp
                        anchors.horizontalCenter: parent.horizontalCenter
                        border.color: "#4C67A1"
                        border.width: 1*dp
                        radius: 5*dp
                        color: (read===0&&message.player!==cloud.username)?"#CAE0FE":"transparent"
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                if(read===0 && message.player!==cloud.username)
                                {
                                    cloud.messagesModel.setMessageRead(index)
                                }
                                messageList.currentIndex=index
                                notificationView.currentIndex=index

                                cloud.db.readTransaction(
                                            function(tx) {
                                                var getMsgs=tx.executeSql('SELECT * FROM Messages WHERE notification_id='+notification_id+' ORDER BY message_id ASC')
                                                userMsgModel.clear()
                                                for(var i=0;i<getMsgs.rows.length;i++)
                                                {
                                                    userMsgModel.append(getMsgs.rows.item(i))
                                                }
                                                userMessageList.adjustView()
                                                if(stackView.depth>2)
                                                {
                                                    stackView.push({item:userMessageList,replace:true})
                                                }
                                                else
                                                {
                                                    stackView.push(userMessageList)
                                                }

                                            })

                            }
                        }
                        Item{
                            id:senderProfileItem1
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 20*dp
                            anchors.left:parent.left

                            width: 50*dp
                            height:50*dp

                            Image{
                                id: senderProfile1
                                //grr.... get from backend
                                source: "../../images/cute_cat.jpg"
                                height: 50*dp
                                width: 50*dp
                                sourceSize.width: 50*dp
                                sourceSize.height: 50*dp
                                visible: false
                            }

                            Image {
                                id:mask1
                                source: "../../images/black_circle.png"
                                sourceSize.width: 50*dp
                                sourceSize.height: 50*dp
                                smooth: true
                                visible: false
                            }
                            OpacityMask {
                                anchors.fill: senderProfile1
                                source: senderProfile1
                                maskSource: mask1
                            }

                        }
                        Column{
                            id: messageContent
                            spacing: 15*dp
                            anchors.right: msgInfo.left
                            anchors.left:senderProfileItem1.right
                            anchors.leftMargin: 10*dp
                            clip: true
                            Text{
                                text:players
                                clip:true
                                color: "black"
                                font.bold: true
                                font.pixelSize: 15*dp
                                font.underline: true
                                wrapMode: Text.WordWrap
                            }

                            Text{
                                text: message.message
                                clip:true
                                font.pixelSize: 15*dp
                                color: "blue"
                                width: parent.width
                                wrapMode: Text.WordWrap
                            }
                        }
                        Column{
                            id: msgInfo
                            spacing: 15*dp
                            anchors.right: parent.right
                            // anchors.left:messageContent.right
                            clip: true
                            Text{
                                text: message.createdAt
                                clip:true
                                font.pixelSize: 12*dp
                                // width: parent.width
                                wrapMode: Text.WordWrap
                            }
                        }

                    }
                }

                RaisedButton{
                    id:newMessageButton
                    height:35*dp
                    width:parent.width
                    anchors.left:parent.left
                    anchors.leftMargin: 2*dp
                    anchors.bottom: parent.bottom
                    //                    anchors.top: messageList.bottom
                    //text: "New Message"
                    color: "#ff5177"
                    Image {
                        id: addMessage
                        source: "../../svg/icon_add.svg"
                        anchors.centerIn: parent
                        sourceSize.width: 35*dp
                        sourceSize.height: 35*dp
                        width: 35*dp
                        height: 35*dp
                    }


                    onClicked: {
                        inviteList.caller="message"
                        inviteList.open()
                    }

                }
            }
        }

    }


    Rectangle{
        id:userMessageList
        function adjustView(){
            userMessageListView.positionViewAtEnd()
        }

        function addMessageToList(message,index)
        {
            if(index===currentIndex)
                userMsgModel.append(message)
            adjustView()
        }

        visible: false
        ListView{
            id:userMessageListView
            clip:true
            spacing: 15*dp
            snapMode: ListView.SnapToItem
            anchors{
                top:parent.top
                bottom: sendingArea.top
                left: parent.left
                right:parent.right
                topMargin: 6*dp
            }
            model:ListModel{
                id:userMsgModel
            }

            delegate:Rectangle{
                width:200*dp
                anchors{
                    left: player===cloud.username?undefined:parent.left
                    right: player===cloud.username?parent.right:undefined
                    leftMargin: player===cloud.username?0:10
                    rightMargin: player===cloud.username?10:0
                }
                height: playerName.height+messageText.height+16
                color:player===cloud.username?"white":"#B8F5F5"
                radius: 8*dp
                border.width: 1*dp
                Text {
                    id:playerName
                    text: player===cloud.username?"me:":player+":"
                    anchors.topMargin: 8*dp
                    anchors.left: parent.left
                    anchors.leftMargin: 8*dp
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }
                Text {
                    id:messageText
                    text:message
                    width:parent.width-20
                    anchors.top: playerName.bottom
                    anchors.topMargin: 8*dp
                    anchors.left: parent.left
                    anchors.leftMargin: 8*dp
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                }
            }

        }
        Rectangle{
            id:sendingArea
            width: parent.width
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 35*dp
            TextArea{
                id:messagefield

                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.leftMargin: 5*dp
                anchors.right:sendButton.left
                anchors.rightMargin: 5*dp
                height: parent.height*dp
                font.pixelSize: 15*dp
                wrapMode: TextEdit.WrapAtWordBoundaryOrAnywhere


            }
            FloatingActionButton{
                id:sendButton

                width: messagefield.height
                height:messagefield.height
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.rightMargin: 5*dp
                color: actionBar.color
                iconSource: "../../svg/done.svg"
                onClicked: {
                    if(messagefield.text!=="")
                    {
                        //userMsgModel.append({player:cloud.username,message:messagefield.text})
                        var messageObject={
                            message:{
                                message: messagefield.text,
                                player:cloud.username,
                                createdAt:cloud.getDate()

                            },
                            type:"message",
                            players:cloud.messagesModel.get(currentIndex).players.split(",")
                        }
                        messageObject.notification_id = cloud.messagesModel.get(currentIndex).notification_id
                        sendMessage(messageObject,currentIndex)

                        messagefield.text=""
                    }
                }
            }
        }
    }

}
