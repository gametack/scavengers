import QtQuick 2.0
import QtPositioning 5.3
import QtGraphicalEffects 1.0
import "../../helpers"
import "../../"
import "../../objectCreation.js" as ObjectCreation

Rectangle {
    id:gamePlayRoot
    anchors.fill: parent
    property bool taskShown: false
    property bool clueShown: false
    property var activeGame
    property var challengeDistances:[]//each element is an array that holds the distance and index of  the challenge

    signal adventureCompleted()

    onAdventureCompleted: {
        playMap.visible=false
        name.text= activeGame.name+ " completed: "+activeGame.points+" points"
        congratsAdventure.visible = true
        var getHunt = {
            challenges: activeGame.completedChallenges,
            points: activeGame.points,
            name: activeGame.name,
            players:activeGame.players
        }

        //console.log("COMPLETED")
        cloud.userUpdate("completedHunts", getHunt)
        //cloud.usersListModel.updateMyInfo("completedHunts", getHunt)
        //hunt to CompletedList
    }

    clip:true

    Component.onCompleted: {
        var challenge,i
        for(i=0;i<activeGame.challenges.length;i++)
        {
            challenge = activeGame.challenges[i]
            challengeDistances.push([-1,i])
            challengeClueListModel.append({clue:challenge.clue})
        }
        //console.log(JSON.stringify(activeGame.challenges))
        // challengeListModel.append(activeGame.challenges)
        for(i=0;i<activeGame.completedChallenges.length;i++)
        {
            challenge = activeGame.completedChallenges[i]
            playMap.addMarkertoMap(challenge.location,false,true)
        }

    }




    MapItem{
        id:playMap
        anchors.fill: parent
        state: "gameplay"
        Component.onCompleted: {
            locationTester.checkDistance()
        }
        onUserMoved:
        {
            //replace this with on map clicked stuff when ready for phone
        }
        onMapClicked: {
            if(!challengeCard.visible)
            {
                var coordinate=map.toCoordinate(Qt.point(mouseX,mouseY))
                userLocation.coordinate = coordinate
                //playMap.map.center = userLocation.coordinate
                locationTester.checkDistance(coordinate.latitude,coordinate.longitude)
                var distance = challengeDistances[0][0]
                //console.log(distance)
                if(distance>400)
                {
                    userLocation.stopIndicate()
                    //locationAlert.visible=false

                }
                else if(distance<400 && distance>300)
                {
                    userLocation.indicate(100,1200)
                    //locationAlert.visible=true

                }
                else if( distance<300 && distance>200)
                {
                    userLocation.indicate(150,800)
                    // playMap.map.zoomLevel = playMap.map.maximumZoomLevel - 3
                    // playMap.map.center = userLocation.coordinate
                    //locationAlert.visible=true
                }
                else if(distance<200 && distance>100)
                {
                    userLocation.indicate(200,500)
                    //playMap.map.zoomLevel = playMap.map.maximumZoomLevel - 2
                    //playMap.map.center = userLocation.coordinate
                    //locationAlert.visible=true
                }
                else if(distance<100 && distance>50)
                {
                    userLocation.indicate(250,200)
                    // playMap.map.zoomLevel = playMap.map.maximumZoomLevel - 1
                    //playMap.map.center = userLocation.coordinate
                    //locationAlert.visible=true

                }
                else if(distance<50 && distance !=-1)
                {
                    userLocation.stopIndicate()
                    challengeCard.enterChallenge()
                    playMap.map.zoomLevel = playMap.map.maximumZoomLevel
                }
            }
        }
    }




//    Rectangle{
//        anchors.fill: challengeClueList
//        color: "white"
//        opacity: clueShown ? 0.7:0

//    }

    ListView{
        id: challengeClueList
        anchors.bottom:parent.bottom
        height: clueShown ? parent.height: 60*dp

        width: parent.width
        clip: true
        model: ListModel{
            id:challengeClueListModel
        }

        delegate:
            Item {

            property real detailsOpacity : 0

            width: stackView.width
            height: 60*dp

            Rectangle {
                id: background
                x: 6*dp
                y: 6*dp
                width: parent.width - x*2
                height: parent.height - y*2
                color: "white"
                // border.color: "grey"
                radius: 4*dp
            }
            PaperShadow{
                anchors.fill:background
                source: background
                depth: 3*dp
            }
            Text{
                id:clueText
                anchors{
                    left:background.left
                    top:background.top
                    leftMargin:  6*dp
                    topMargin: 6*dp
                    right: background.right
                    rightMargin: 50*dp
                }
                text: clue
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                clip:true

            }

        }

    }


    FloatingActionButton{
        id: clueView

        width:35*dp
        height:35*dp
        color: actionBar.color
        anchors.right: parent.right
        anchors.rightMargin: 12*dp
        anchors.bottom:parent.bottom
        anchors.bottomMargin: 12*dp
        iconSource: "../../svg/icon_menu.svg"
        visible:true
        onClicked: {
            clueShown = !clueShown

        }
    }

    Rectangle{
        id:challengeCard
        visible: false
        anchors.fill: parent

        function enterChallenge(){

            challengeCard.visible = true
            var challengeItem
            challengeItem = ObjectCreation.createObject("dynamic/userspace/Challenge_Card.qml",challengeCard,{"challenge":activeGame.challenges[challengeDistances[0][1]]})


            challengeItem.backToAdventure.connect(function (location){
                challengeCard.visible = false
                challengeItem.destroy()
                playMap.addMarkertoMap(location,false,true)


            })

            challengeItem.challengeCompleted.connect( function (finishedChallenge){
                var localUpdateInfo={}
                localUpdateInfo.challenge_id=activeGame.challenges[challengeDistances[0][1]].challenge_id
                   localUpdateInfo.finishedChallenge=finishedChallenge

                activeGame.completedChallenges.push(finishedChallenge)
                activeGame.challenges.splice(challengeDistances[0][1],1)
challengeDistances.shift()
                activeGame.points=activeGame.points+finishedChallenge.points
                activeGame.progress = activeGame.completedChallenges.length/(activeGame.challenges.length+activeGame.completedChallenges.length)



//                 gameObjectToUpdate.points=activeGame.points
//                 gameObjectToUpdate.progress=activeGame.progress
//                gameObjectToUpdate.name=activeGame.name

               cloud.activeGamesListModel.updateActiveGame(activeGame,localUpdateInfo)
                if(activeGame.progress === 1)
                {
                    adventureCompleted(activeGame)
                }

            })
        }


    }

    Rectangle{
        id:congratsAdventure
        anchors.fill: parent
        visible: false
        Text {
            id: name
            anchors.horizontalCenter: parent.horizontalCenter

            font.pixelSize: 16*dp
            font.bold: true
        }
        RaisedButton{

            anchors.bottom: parent.bottom
            anchors.horizontalCenter:parent.horizontalCenter
            width: 125*dp
            height: 30*dp
            color: "#FFD700"
            text: "Finish"
            onClicked: {
                gamePlayRoot.destroy()

            }
        }
    }

    Item{
        id: locationTester


        /*COme Up with a better distance checker*/

        //For easy level. Re order clue list by closest challenge first

        function checkDistance(latitude,longitude)
        {
            //console.log(JSON.stringify(challengeDistances))
            for(var i=0;i<challengeDistances.length;i++)
            {
                var chal=activeGame.challenges[i]
                var asd =  Math.round(QtPositioning.coordinate(chal.location.latitude,chal.location.longitude).distanceTo(QtPositioning.coordinate(latitude,longitude)))

                //                        var chal = challengeListModel.get(i)
                //                        chal.distance = asd

                challengeDistances[i][0]=asd

            }

            challengeDistances.sort(function(a,b){return a[0] - b[0]})
        }
    }

    //        function checkDistance()
    //        {
    //            for(var i=0;i<challengeListModel.count;i++)
    //            {
    //                var asd = QtPositioning.coordinate(challengeListModel.get(i).location.latitude,challengeListModel.get(i).location.longitude).distanceTo(playMap.userLocation.coordinate)

    //                //                        var chal = challengeListModel.get(i)
    //                //                        chal.distance = asd

    //                challengeListModel.setProperty(i,"distance", asd)

    //            }
    //            sortChallenges()
    //        }
    //        function sortChallenges(){
    //            for(var i=0;i<challengeListModel.count;i++)
    //            {
    //                var holda=challengeListModel.get(i)
    //                for(var j=i+1;j<challengeListModel.count;j++)
    //                {
    //                    if(holda.distance>challengeListModel.get(j).distance)
    //                    {

    //                        challengeListModel.move(i,j,1)

    //                    }
    //                }
    //            }
    //        }

    //    }

}

