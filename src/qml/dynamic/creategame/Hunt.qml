import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import QtLocation 5.3
import QtPositioning 5.3
import "../../helpers"
import "../../"

Rectangle{
    id:huntCreateRoot
    anchors.fill: parent
    //property alias mapBox: mapBox
    property var challengeTempLocation
    property bool validated:false
    property alias finButt:addChallengeToAdventure


    function addChallenge(coordinate,name)
    {
        challengeTempLocation ={latitude:coordinate.latitude,longitude:coordinate.longitude}
        huntCreateRoot.state = "enterChallengeInfo"
        challengeTempMarker.coordinate = coordinate
        mapItem.map.addMapItem(challengeTempMarker)
        mapItem.map.center = coordinate
        mapItem.map.zoomLevel = mapItem.map.maximumZoomLevel
        mapItem.map.pan(0,150)
        //mapItem.searchResults.state = "backToMap"
        for(var i=0;i<3;i++)//clears challenge form/ insert name of location if available
        {
            mymodel.setProperty(i,"locationName",name)
            mymodel.setProperty(i,"locationClue","")
            mymodel.setProperty(i,"arrival","")
            mymodel.setProperty(i,"prompt1","")
            mymodel.setProperty(i,"prompt2","")
            mymodel.setProperty(i,"prompt3","")
            mymodel.setProperty(i,"prompt4","")
        }

        //locationTitle.text = name
    }


    Rectangle {
        id: actionBar
        width: parent.width
        height: 50 * dp
        property alias getName:gameName
        color: "#405ede"
        z: 2
        //Behavior on color {ColorAnimation{ duration: 200 }}


        TextField{
            id:gameName
            property bool valid:true
            placeholderText: "Enter Adventure Name"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            width: actionBar.width - 200
            opacity: 0.7*dp
            horizontalAlignment: TextInput.AlignHCenter
            height:actionBar.height - 20
            onTextChanged: {if(text!=="")valid=true}
            style: TextFieldStyle{background: Rectangle{color: gameName.valid?"white":"red"}}
        }
        FloatingActionButton {
            id: backButton
            anchors.left: parent.left
            anchors.leftMargin: 16 * dp
            anchors.verticalCenter: parent.verticalCenter
            iconSource: "../../svg/icon_back.svg"
            color:"transparent"
            onClicked:{
                huntCreateRoot.parent.doneCreation()
            }
            visible: true
        }
        FloatingActionButton {
            id: finishButton
            anchors.right: parent.right
            anchors.rightMargin: 16 * dp
            anchors.verticalCenter: parent.verticalCenter
            iconSource: "../../svg/done_all.svg"
            color:"green"
            onClicked: {
                addChallengeInfo.currentItem.validateForm("all")
                if(validated)
                {
                    var game ={}
                    var hchallenges = []

                    for(var i=0;i<challenges.count;i++)
                    {
                        var hold =challenges.get(i)
                        var challenge={}
                            challenge.arrival= hold.arrival
                            challenge.clue= hold.clue
                            challenge.location= [
                                hold.location.latitude,
                                hold.location.longitude
                            ]

                            challenge.name= hold.name
                            challenge.type= hold.type
                        if(hold.type==="Trivia")
                        {
                            challenge.trivia=hold.trivia
                        }
                        hchallenges.push(challenge)
                        //cloud.placesListModel.append({geoloc:[hold.location[0], hold.location[1]]})
                    }
                    game.name = gameName.text
                    game.type = "scavanger hunt"
                    game.createdAt=cloud.date.
                    game.challenges = hchallenges
                    cloud.gamesListModel.append(game)
                    huntCreateRoot.parent.doneCreation()
                }
            }
            visible: true
        }
    }

    MapItem{
        id:mapItem
        width: parent.width
        state:"creategame"
        height: parent.height - actionBar.height
        anchors.top: actionBar.bottom
        onAddMapMarkerToGame: {
            huntCreateRoot.addChallenge(coordinate,name)
        }
        onMapMarkerPressandHold: {
            huntCreateRoot.addChallenge(coordinate,"")
        }
        onMapPressandHold: {
            huntCreateRoot.addChallenge(coordinate,"")
        }
        onMapClicked: {
            huntCreateRoot.state = ""
            mapItem.map.removeMapItem(challengeTempMarker)
        }
        onMapSearch:{
            huntCreateRoot.state = ""
            mapItem.map.removeMapItem(challengeTempMarker)
        }
        MapQuickItem{
            property alias image: challengeTempMarkerImage
            signal pressHold
            id:challengeTempMarker

            anchorPoint.x: challengeTempMarkerImage.width/4
            anchorPoint.y: challengeTempMarkerImage.height
            sourceItem:
                Image {
                id: challengeTempMarkerImage
                fillMode: Image.PreserveAspectFit
                width: 35*dp
                height: 35*dp
            }
            //            MouseArea{
            //                anchors.fill: parent

            //            }

        }
    }

    Rectangle{
        id:addChallengeInfoCard
        //height: addChallengeInfo.currentIndex == 2 ? 450*dp:300*dp
        height:300*dp
        width: huntCreateRoot.width * 0.7
        visible:false
        color: "white"
        anchors.horizontalCenter: parent.horizontalCenter
        y:huntCreateRoot.height/2 - 100

    }




    PaperShadow{
        id:addChallengeInfoCardShadow
        source: addChallengeInfoCard
        visible:false
        anchors.fill: addChallengeInfoCard
        width:addChallengeInfoCard.width + 4
        height:addChallengeInfoCard.height
        depth: 3
    }

    ListView{
        id:addChallengeInfo
        //property alias ittem:ittem
        anchors.fill:addChallengeInfoCard
        anchors.margins:10*dp
        clip: true
        visible:false
        keyNavigationWraps: true
        onCurrentIndexChanged: {
            challengeTempMarker.image.source = mymodel.get(currentIndex).iconSrc
        }

        orientation: Qt.Horizontal
        snapMode: ListView.SnapToItem
        highlightRangeMode: ListView.StrictlyEnforceRange
        spacing:10*dp

        model:
            ListModel{
            id:mymodel
            ListElement{
                type:"Photo"
                iconSrc: "../../svg/camera.svg"
                locationName: ""
                locationClue:""
                arrival:""
                prompt1:""
                prompt2:""
                prompt3:""
                prompt4:""
            }
            ListElement{
                type: "Activity"
                locationName: ""
                locationClue:""
                iconSrc: "../../svg/activity.svg"
                arrival:""
                prompt1:""
                prompt2:""
                prompt3:""
                prompt4:""
            }

            ListElement{
                type: "Trivia"
                locationName: ""
                locationClue:""
                iconSrc: "../../svg/trivia.svg"
                arrival:""
                prompt1:""
                prompt2:""
                prompt3:""
                prompt4:""
            }
        }
        delegate: Rectangle {
            color: "#405ede"
            id:ittem
            function validateForm(type)
            {
                validated=true //set to true then AND with all validated  input to see if it remains true
                if(type==="all")
                {
                    if(gameName.text===""){gameName.valid=false;validated=false} else{validated=validated&gameName.valid}
                }
                if(huntCreateRoot.state === "enterChallengeInfo"||challenges.count===0)//if we dont have any challenged made yet
                {
                    if(addChallengeInfo.currentIndex === 2)
                    {
                        if(answer1.text===""){answer1.valid=false;validated=false} else{validated=validated&answer1.valid}
                        if(answer2.text===""){answer2.valid=false;validated=false} else{validated=validated&answer2.valid}
                        if(answer3.text===""){answer3.valid=false;validated=false} else{validated=validated&answer3.valid}
                        if(answer4.text===""){answer4.valid=false;validated=false} else{validated=validated&answer4.valid}
                    }

                    if(locationTitle.text===""){locationTitle.valid=false;validated=false} else{validated=validated&locationTitle.valid}
                    if(locationClue.text===""){locationClue.valid=false;validated=false} else{validated=validated&locationClue.valid}
                    if(onArivalInstruction.text===""){onArivalInstruction.valid=false;validated=false} else{validated=validated&onArivalInstruction.valid}
                }
            }


            height:  addChallengeInfoCard.height
            width: addChallengeInfoCard.width-20
            radius: 4*dp
            ScrollView{
                id:scrollview
                height:parent.height - 100
                width:parent.width

                Rectangle {
                    id:textRec
                    color:"transparent"
                    height: addChallengeInfo.currentIndex == 2 ? 450:300
                    width: addChallengeInfoCard.width-20
                    radius: 4*dp
                    Text {
                        id:typeTitle
                        text: type
                        font.bold: true
                        font.pointSize: 10
                        anchors.top:parent.top
                        anchors.horizontalCenter: textRec.horizontalCenter
                        anchors.topMargin: 2*dp
                    }
                    TextField{
                        id: locationTitle
                        property bool valid:true
                        anchors.top:typeTitle.bottom
                        anchors.topMargin: 10*dp
                        text:mymodel.get(addChallengeInfo.currentIndex).locationName
                        anchors.horizontalCenter: textRec.horizontalCenter
                        width: addChallengeInfo.width - 20
                        placeholderText: "Enter Location Name"
                        onTextChanged: {
                            mymodel.setProperty(addChallengeInfo.currentIndex,"locationName",text)
                            if(text!=="")valid=true
                        }
                        style: TextFieldStyle{background: Rectangle{color: locationTitle.valid?"white":"red"}}
                    }
                    TextField{
                        id:locationClue
                        property bool valid:true
                        anchors.top:locationTitle.bottom
                        anchors.topMargin: 10*dp
                        anchors.horizontalCenter: textRec.horizontalCenter
                        width: addChallengeInfo.width - 20
                        text:mymodel.get(addChallengeInfo.currentIndex).locationClue
                        placeholderText: "Enter Your Clue"
                        onTextChanged: {
                            mymodel.setProperty(addChallengeInfo.currentIndex,"locationClue",text)
                            if(text!=="")valid=true
                        }
                        style: TextFieldStyle{background: Rectangle{color: locationClue.valid?"white":"red"}}
                    }
                    TextField{
                        id: onArivalInstruction
                        property bool valid:true
                        anchors.top:locationClue.bottom
                        anchors.topMargin: 10*dp
                        anchors.horizontalCenter: textRec.horizontalCenter
                        width: addChallengeInfo.width - 20
                        text:mymodel.get(addChallengeInfo.currentIndex).arrival
                        placeholderText: addChallengeInfo.currentIndex == 2?"Enter Question":"Enter Arrival Message"
                        onTextChanged: {
                            mymodel.setProperty(addChallengeInfo.currentIndex,"arrival",text)
                            if(text!=="")valid=true
                        }
                        style: TextFieldStyle{background: Rectangle{color: onArivalInstruction.valid?"white":"red"}}
                    }
                    TextField{
                        id:answer1
                        property bool valid:true
                        width: addChallengeInfo.width - 40
                        anchors.top:onArivalInstruction.bottom
                        anchors.topMargin: 10*dp
                        anchors.horizontalCenter: textRec.horizontalCenter
                        text:mymodel.get(addChallengeInfo.currentIndex).prompt1
                        placeholderText: "enter an answer"
                        visible: addChallengeInfo.currentIndex == 2 ? true:false
                        onTextChanged: {
                            mymodel.setProperty(addChallengeInfo.currentIndex,"prompt1",text)
                            if(text!=="")valid=true
                        }
                        style: TextFieldStyle{background: Rectangle{color: answer1.valid?"white":"red"}}
                    }
                    TextField{
                        id:answer2
                        property bool valid:true
                        width: addChallengeInfo.width - 40
                        anchors.top:answer1.bottom
                        anchors.topMargin: 10*dp
                        anchors.horizontalCenter: textRec.horizontalCenter
                        text: mymodel.get(addChallengeInfo.currentIndex).prompt2
                        placeholderText: "enter an answer"
                        visible: addChallengeInfo.currentIndex == 2 ? true:false
                        onTextChanged: {
                            mymodel.setProperty(addChallengeInfo.currentIndex,"prompt2",text)
                            if(text!=="")valid=true
                        }
                        style: TextFieldStyle{background: Rectangle{color: answer2.valid?"white":"red"}}
                    }
                    TextField{
                        id:answer3
                        property bool valid:true
                        width: addChallengeInfo.width - 40
                        anchors.top:answer2.bottom
                        anchors.topMargin: 10*dp
                        anchors.horizontalCenter: textRec.horizontalCenter
                        text: mymodel.get(addChallengeInfo.currentIndex).prompt3
                        placeholderText: "enter an answer"
                        visible: addChallengeInfo.currentIndex == 2 ? true:false
                        onTextChanged: {
                            mymodel.setProperty(addChallengeInfo.currentIndex,"prompt3",text)
                            if(text!=="")valid=true
                        }
                        style: TextFieldStyle{background: Rectangle{color: answer3.valid?"white":"red"}}
                    }
                    TextField{
                        id:answer4
                        property bool valid:true
                        width: addChallengeInfo.width - 40
                        anchors.top:answer3.bottom
                        anchors.topMargin: 10*dp
                        anchors.horizontalCenter: textRec.horizontalCenter
                        text: mymodel.get(addChallengeInfo.currentIndex).prompt4
                        placeholderText: "enter an answer"
                        visible: addChallengeInfo.currentIndex == 2 ? true:false
                        onTextChanged: {
                            mymodel.setProperty(addChallengeInfo.currentIndex,"prompt4",text)
                            if(text!=="")valid=true
                        }
                        style: TextFieldStyle{background: Rectangle{color: answer4.valid?"white":"red"}}
                    }

                }
            }
        }
        Row {
            id:iOSindicator
            spacing: 16
            width: 3*16
            anchors.bottom:addChallengeInfo.bottom
            anchors.bottomMargin: 5*dp
            anchors.horizontalCenter: addChallengeInfo.horizontalCenter
            Repeater {
                model: 3
                Rectangle {
                    width: 10; height: 10; radius: 5
                    color: addChallengeInfo.currentIndex === index ? "#88ffffff" : "#88000000"
                    border { width: 2; color: addChallengeInfo.currentIndex === index ? "#33000000" : "#11000000" }
                }
            }
        }
    }
    FloatingActionButton{
        id:addChallengeToAdventure
        color:"green"
        iconSource: "../../svg/done.svg"
        iconHeight:40*dp
        iconWidth:40*dp
        visible:false
        anchors {
            bottom:addChallengeInfoCard.bottom
            horizontalCenter: addChallengeInfoCard.horizontalCenter
            bottomMargin: 40*dp
        }
        onClicked: { //ADD EACH ITEM IN AS WE CREATE INPUT
            addChallengeInfo.currentItem.validateForm() //validates form
            if(validated)
            {
                var createdChallengeType = mymodel.get(addChallengeInfo.currentIndex)
                var challenge={}
                var challengeLocation=challengeTempLocation

                challenge.location=challengeLocation
                challenge.type =createdChallengeType.type
                challenge.clue = createdChallengeType.locationClue
                challenge.name = createdChallengeType.locationName
                challenge.arrival = createdChallengeType.arrival
                challenge.icon = createdChallengeType.iconSrc

                if(addChallengeInfo.currentIndex === 0)
                {

                }
                else if(addChallengeInfo.currentIndex === 1)
                {

                }
                else if(addChallengeInfo.currentIndex === 2)
                {
                    challenge.trivia = {}
                    challenge.trivia.question = createdChallengeType.arrival
                    challenge.trivia.answers =[createdChallengeType.prompt1,createdChallengeType.prompt2,createdChallengeType.prompt3,createdChallengeType.prompt4]

                    challenge.trivia.correctAnswer = createdChallengeType.prompt1
                }
//console.log(JSON.stringify(challenge))
                challenges.append(challenge)
                huntCreateRoot.state = ""
                mapItem.map.removeMapItem(challengeTempMarker)
            }
        }


    }

    IconButton{
        id:back
        iconSource: "../../svg/left.svg"
        anchors{verticalCenter: addChallengeInfoCard.verticalCenter;right:addChallengeInfoCard.left;}
        onClicked: addChallengeInfo.decrementCurrentIndex()
        visible:false

    }
    IconButton{
        id:next
        iconSource: "../../svg/right.svg"
        anchors{verticalCenter: addChallengeInfoCard.verticalCenter;left:addChallengeInfoCard.right;}
        onClicked: addChallengeInfo.incrementCurrentIndex()
        visible:false
    }

    ListView {
        id: challengeListView
        height: 100*dp
        width: parent.width
        anchors{
            bottom: parent.bottom
        }

        // highlightRangeMode: ListView.StrictlyEnforceRange
        orientation:Qt.Horizontal

        snapMode: ListView.SnapToItem
        layoutDirection:Qt.LeftToRight
        cacheBuffer: width*20

        delegate:
            Item {
            height: 100*dp
            width: huntCreateRoot.width
            MouseArea{
                anchors.fill:reccc
                onClicked: {
                    challengeListView.currentIndex = index
                    mapItem.map.center = QtPositioning.coordinate(location.latitude,location.longitude)
                    mapItem.map.zoomLevel = mapItem.map.maximumZoomLevel
                }
            }

            Rectangle {
                id:reccc
                anchors.fill: parent
                color: Qt.rgba( Math.random(), Math.random(), Math.random(), 0.6);
                Text {
                    id:completeTitle

                    text: type + " challenge at " + name
                    anchors.top: parent.top

                    anchors.margins: 5*dp
                    font.bold: true
                }
                Text {
                    id:completeClue
                    anchors.top: completeTitle.bottom
                    anchors.left:completeTitle.left
                    text: "Clue: " + clue
                    //anchors.verticalCenter: parent.verticalCenter
                    font.bold: true
                }
                Text {
                    id:coordinateTest
                    anchors.top: completeClue.bottom
                    anchors.left:completeClue.left
                    text: "lat: " + location.latitude + "  long:" + location.longitude
                    //anchors.verticalCenter: parent.verticalCenter
                    font.bold: true
                }
                FloatingActionButton{
                    id:removeChallengeButton
                    anchors.top: parent.top
                    anchors.right: parent.right
                    iconSource: "../../svg/cancel.svg"
                    color: "red"
                    onClicked:
                    {
                        challenges.remove(challengeListView.currentIndex)
                        mapItem.map.removeMapItem(challengeMarker)
                    }
                }

                //                Image {
                //                    id: challengeIcon
                //                    source: icon
                //                    fillMode: Image.PreserveAspectFit
                //                    anchors.right:completeTitle.left
                //                    anchors.top:completeTitle.top
                //                    anchors.left:parent.left
                //                    width: 100*dp
                //                    height: 100*dp
                //                }

                MapQuickItem{ //this is the marker that appear when we scroll throught the list of challenges
                    id:challengeMarker
                    anchorPoint.x: challengeMarkerImage.width/4
                    anchorPoint.y: challengeMarkerImage.height
                    sourceItem:
                        Image {
                        id: challengeMarkerImage
                        source: icon //Change Icon Source depending on type
                        fillMode: Image.PreserveAspectFit
                        width: 35*dp
                        height: 35*dp
                    }


                    coordinate:  QtPositioning.coordinate(location.latitude,location.longitude)

                    Component.onCompleted: {
                        mapItem.map.addMapItem(challengeMarker)

                    }
                    MouseArea{
                        id:challengeClick
                        anchors.fill:parent
                        onClicked: {
                            mapItem.map.center = QtPositioning.coordinate(location.latitude,location.longitude)
                            mapItem.map.zoomLevel = mapItem.map.maximumZoomLevel

                            mapItem.map.positionViewAtIndex(index,ListView.Contain )

                        }
                    }


                }


            }

        }
        model: ListModel {
            id:challenges
        }

    }




    states: [
        State {
            name: "enterChallengeInfo"


            PropertyChanges{
                target:next
                visible:true
            }
            PropertyChanges{
                target:back
                visible:true
            }
            PropertyChanges{
                target:addChallengeToAdventure
                visible:true
            }

            PropertyChanges{
                target:addChallengeInfoCard
                visible:true
            }
            PropertyChanges{
                target:addChallengeInfo
                visible:true
            }
            PropertyChanges{
                target:addChallengeInfoCardShadow
                visible:true
            }
            PropertyChanges{
                target: challengeListView
                visible: false
            }


        }


    ]

}

