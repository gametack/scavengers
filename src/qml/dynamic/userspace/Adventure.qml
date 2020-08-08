import QtQuick 2.4
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0
import "../../helpers"
import "../../objectCreation.js" as ObjectCreation

//THIS IS THE MAIN GAME LIST
Rectangle
{
    id:adventure
    property var gamePlay
    property alias playingList: playingList
    property string playingChallengeName: ""
    property var checkPlayingChallenge: function(challengeName)
    {
        return challengeName===playingChallengeName
    }

    //property alias userPoints: userPoints
    //property alias userNameText: userNameText



    ListView{
        id:myInfoView
        width: parent.width
        height: 190 * dp
        model:cloud.myInfoModel
        delegate: myInfoDelegate
        anchors.horizontalCenter: parent.horizontalCenter
    }
    Component{
        id:myInfoDelegate
        Rectangle {
            id: userCard
            width: parent.width
            height: 190 * dp

            Rectangle {
                id: profilePicture

                property alias picture: picture
                anchors.horizontalCenter: parent.horizontalCenter
                height: 90 * dp
                width: 90 * dp
                radius: 45 * dp
                color: "#dadada"

                Image {
                    id: picture
                    source: "../../images/male.png"
                    fillMode: Image.PreserveAspectFit
                    height: 90 * dp
                    width: 90 * dp

                    sourceSize.width: 100 * dp
                    sourceSize.height: 100 * dp
                    //visible: false
                }
            }
            Row {
                id: userText
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: profilePicture.bottom

                Text {
                    id: userNameText

                    text: username
                    font.underline: true
                    font.bold: true
                    font.family: "Arial"

                    color: "yellow"

                    font.pointSize: 18*dp
                    Component.onCompleted: {
                    }
                }
                Text {
                    //text: "Points:"+ get user total points from db
                    id: userPoints
                    text: points
                    font.bold: true

                    color: "yellow"
                    font.pointSize: 18*dp

                }
                spacing: 5*dp
            }
        }
    }
    Rectangle{
        id: gameList
        color:"#dadada"
        anchors{
            top:myInfoView.bottom
            bottom:parent.bottom
            left:parent.left
            right:parent.right
        }

        ListView{
            id:playingList
            width:parent.width
            height: parent.height
            clip:true
            model: cloud.activeGamesListModel
            section{
                property:"status"
                criteria: ViewSection.FullString
                delegate:
                    Rectangle {
                    id: secRec
                    color: section === "Playing" ? "green":"red"

                    width: parent.width
                    height: 30*dp

                    anchors.horizontalCenter: parent.horizontalCenter
                    Text{
                        text: section
                        color: "white"
                        font.pixelSize: 12*dp
                        font.bold :true
                        font.capitalization: Font.AllUppercase
                        anchors.centerIn: parent

                    }

                }
            }
            delegate:
                Item{
                property alias playingRec: playingRec
                width: parent.width
                height: 90*dp


                Rectangle {
                    id:playingRec
                    color: "white"
                    radius:5*dp
                    x: 6*dp
                    y: 6*dp
                    clip:true
                    height:parent.height -10
                    width:parent.width - 20



                    MouseArea{
                        id: playingButton
                        anchors.fill:parent
                        onClicked: {
                            cloud.activeGamesListModel.activeIndex=index
                            cloud.db.readTransaction(
                                        function(tx) {
                                            var completedChallenges=[]
                                            var challenges=[]
                                            var getChals=tx.executeSql('SELECT * FROM Challenges WHERE activegame_id='+activegame_id)
                                            for(var i =0;i<getChals.rows.length;i++)
                                            {
                                                var challenge=getChals.rows.item(i)
                                                var location = JSON.parse(challenge.location)

                                               // challenge.distance=-1

                                                delete challenge["location"]

                                                challenge.location={
                                                    latitude:location[0],
                                                    longitude:location[1]
                                                }

                                                challenges.push(challenge)
                                            }
                                            getChals=tx.executeSql('SELECT * FROM CompletedChallenges WHERE activegame_id='+activegame_id+' ORDER BY completedchallenge_id DESC')
                                            for(i =0;i<getChals.rows.length;i++)
                                            {
                                                completedChallenges.push(getChals.rows.item(i))
                                            }
                                            var hold={}
                                            hold.completedChallenges = completedChallenges
                                            hold.challenges = challenges
                                            hold.name = name
                                            hold.points = points
                                            hold.progress = progress
                                            hold.players = players
                                            hold.remote_id=remote_id
                                            hold.activegame_id=activegame_id
                                            hold.type = type
                                            playingList.currentIndex = index
                                            gamePlay=ObjectCreation.createObject("dynamic/userspace/GamePlay.qml",userSpace,{"activeGame":hold})
                                        })
                        }

                    }
                    Text{
                        id:playingTitle
                        text: name
                        anchors{
                            left:parent.left
                            top:parent.top
                            leftMargin: 6*dp
                            topMargin: 6*dp
                        }
                        font.pointSize: 14*dp
                        color:"black"

                    }
                    FloatingActionButton{
                        id:playingPoint
                        iconWidth:55*dp
                        iconHeight:55*dp
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right:parent.right
                        anchors.rightMargin: 6*dp

                        color:"#4DD0E1"
                        enabled: false

                        Text{
                            id:playingPointText
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            color:"white"
                            font.pointSize: 8*dp
                            font.bold: true
                            text: points
                        }
                    }


                    FloatingActionButton{
                        id:playingUsers
                        iconWidth:34*dp
                        iconHeight:34*dp
                        anchors.bottom: parent.bottom
                        anchors.left:parent.left
                        anchors.leftMargin: 6*dp
                        anchors.bottomMargin: 12*dp
                        color:"#4DB6AC"
                        iconSource:"../../svg/ic_account_child_24px.svg"
                        onClicked:{
                            userShow.visible = true
                        }
                    }
                    ProgressBar{
                        height:8*dp
                        width:parent.width
                        value:progress
                        anchors.bottom:parent.bottom

                    }

                }
                Rectangle{
                    id:userShow

                    color: "white"
                    radius:5*dp
                    x: 6*dp
                    y: 6*dp
                    visible:false
                    height:parent.height -10
                    width:parent.width - 20
                    ListView{
                        id:currentPlayersList
                        anchors.fill:parent
                    }
                    MouseArea{
                        anchors.fill: parent
                        onClicked: photoShow.visible = false
                    }
                }

                PaperShadow {
                    id: playingShadow
                    anchors.fill: playingRec
                    source: playingRec
                    depth: playingButton.pressed ? 4 : 2
                }
            }
        }

    }
    FloatingActionButton {
        id: addButton
        anchors {
            right: parent.right
            top: parent.top
            margins: 15 * dp
        }
        width: 50*dp
        height: 50*dp

        color: "#ff5177"
        iconSource: "../../svg/ic_play_arrow_24px.svg"
        MouseArea{
            id:temp
            anchors.fill: parent
            onClicked: {

                stackView.push(gameSearchList)
                //actionBar.color = addButton.color
            }
        }

    }

    ListView{
        id: gameSearchList
        model: cloud.gamesListModel
        visible:false
        clip:true
        anchors.topMargin: 5
        signal sectionClicked(string name)
        section{
            property:"type"
            criteria: ViewSection.FullString
            delegate:
                Rectangle {
                id: secRec
                color: "blue"
                border.width: 2*dp
                border.color: "grey"
                width: parent.width
                height: 50*dp

                anchors.horizontalCenter: parent.horizontalCenter
                Text{
                    text: section
                    color: "white"
                    font.pixelSize: 20
                    font.bold :true
                    font.capitalization: Font.AllUppercase
                    anchors.centerIn: parent

                }
                MouseArea {
                    id:initSectionClick
                    anchors.fill: parent
                    onClicked: gameSearchList.sectionClicked(section)
                    Component.onCompleted: {//invoke the act of click on the section (first one) to show the games that goes with it.)
                        //only do this when the last item is created and check to only click on scavanger hunt to show
                        //                        if(section ==="scavanger hunt")
                        //                        {
                        //                            gameSearchList.sectionClicked(section)
                        //                        }
                    }
                }
            }
        }

        delegate:gameSearchDelegate

    }

    Component{
        id:gameSearchDelegate
        Rectangle{
            id:rect
            border.width: 1*dp
            border.color: "grey"
            width: parent.width
            height: shown ?60*dp:0
            visible: shown
            property bool shown: false
            Rectangle {
                id:myRec2
                height:parent.height -10
                width:parent.width
                //x: 6*dp
                //y: 6*dp
                //color: myRec.color
                opacity: 0.5
                //radius:5*dp
                clip:true
                property bool playOption: false

            }
            FloatingActionButton {
                id: playButton
                anchors.right:myRec2.right
                anchors.rightMargin: 12*dp
                anchors.verticalCenter: myRec2.verticalCenter
                iconHeight: 35*dp
                iconSource: "../../svg/ic_play_arrow_24px.svg"
                iconWidth: 35*dp
                color:myRec.color

                onClicked: {

                    actionBar.color = "#405ede"
                    var getChallenges=[]

                    for(var i=0;i<challenges.length;i++)
                    {
                        var challenge = challenges[i]
                        challenge.distance = -1
                        challenge.points=0
                        getChallenges.push(challenge)
                    }
                    var game = {
                        challenges:getChallenges,
                        name:name,
                        progress:0,
                        points:0,
                        completedChallenges:[],
                        players:[cloud.username],
                        type:type}

                    if(notification.inviteList.selectedPlayers.length!==0)
                    {
                        var messageObject={
                            message:
                                {
                                    player:cloud.username,
                                    message:name,
                                    createdAt:cloud.getDate(),
                                    extra:type
                                },
                            players:notification.inviteList.selectedPlayers.sort(),
                            type:"gameinvite"
                        }
                        cloud.activeGamesListModel.addGame(game,messageObject,"multi")

                    }
                    else
                    {
                        cloud.activeGamesListModel.addGame(game,messageObject,"solo")
                    }

                    notification.inviteList.clearList()
                    stackView.pop()
                }
            }
            FloatingActionButton {
                id: inviteButton
                anchors.right:playButton.left
                anchors.rightMargin: 12*dp
                anchors.verticalCenter: myRec2.verticalCenter
                iconHeight: 35*dp
                iconSource: "../../svg/group_add.svg"
                iconWidth: 35*dp
                color:myRec.color

                onClicked: {

                    notification.inviteList.caller="gameinvite"
                    notification.inviteList.open()
                }
            }
            Rectangle {
                id:myRec
                //  anchors.fill:myRec2

                //color: Qt.rgba( Math.random(), Math.random(), Math.random(), 1)
                border.width: 1*dp
                border.color: "grey"
                //radius:5*dp
                property bool playOption: false
                property bool playOptionFriend: false
                x: playOption ?  (playOptionFriend ? -width + 30 :-105*dp) : 0                //y: 6*dp

                height:parent.height
                width:parent.width

                Behavior on x{
                    NumberAnimation{duration: 250; easing.type:Easing.OutBack}}
                MouseArea{
                    id: gamesButton
                    anchors.fill:parent
                    onClicked: {

                        myRec.playOption = !myRec.playOption
                    }
                }
                Text{
                    id:captionText
                    text: name
                    anchors.horizontalCenter: myRec.horizontalCenter
                    anchors.bottom: myRec.bottom
                    anchors.bottomMargin: 12*dp

                }

            }
            Connections {
                target: rect.ListView.view
                onSectionClicked: {
                    shown=false
                    if (rect.ListView.section === name) shown = !shown;
                }
            }
        }

    }
}

