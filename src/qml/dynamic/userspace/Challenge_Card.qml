import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import "../../helpers"

StackView {
    id:challengeView
    anchors.fill: parent
    property var challenge

    property int timeLimit : 25

    signal challengeCompleted(var finishedChallenge)
    signal backToAdventure(var location)

    Component.onCompleted: {
        var holdtrivia = JSON.parse(challenge.trivia)
        delete challenge["trivia"]

        cr1.text= challenge.type+" Challenge"
        if(challenge.type === "Trivia")
        {
            challenge.trivia=holdtrivia
            for(var i=0;i< holdtrivia.answers.length;i++)
            {
                triviaAnswers.append({answer: holdtrivia.answers[i]})
            }

            questionText.text=holdtrivia.question
            trivia.visible = true
            timeLimit = 25
            visualTimer.start()

        }
        else if(challenge.type === "Photo")
        {
            photo.visible= true
        }


    }


    onChallengeCompleted: {
        push(congratsScreen)

    }

    function getCameraImage(path)
    {
        var hold={
            name:challenge.name,
            type:challenge.type,
            points : 15,
            result:"image:"+path.split("/")[path.split("/").length-1],
            location:[challenge.location.latitude,challenge.location.longitude]
        }
        challenge.points=15//for congrats view
        var info ={
            location : hold.location,

            challengeName: challenge.name,
            username: cloud.username,

            huntname: gamePlayRoot.activeHunt.name
        }

        cloud.uploadFile(path,"challengepic",info)
        name.text=challenge.type+" Challenge Completed: "+challenge.points+"  points"
        challengeCompleted(hold)
        camera.imageAccepted.disconnect(getCameraImage)
    }

    initialItem: challengeToComplete


    Rectangle{
        id:challengeToComplete
        color:"#8d8d8d"
        visible: false
        Column
        {
            id:title
            anchors.top: parent.top
            anchors.topMargin: 30*dp
            spacing: 15*dp
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                id:cr
                text: qsTr("CHALLENGE REACHED")

                textFormat: Text.PlainText
                font.pixelSize: 16*dp
                color: "white"
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter

            }
            Text {
                id:cr1
                textFormat: Text.PlainText
                font.pixelSize: 16*dp
                color: "white"
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter

            }
        }
        FloatingActionButton{
            id:photo
            visible: false
            iconWidth: 50*dp
            iconHeight: 50*dp
            color:actionBar.color
            opacity:0.6
            iconSource:"../../svg/camera.svg"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            onClicked: {
                root.cameraStart()
                camera.imageAccepted.connect(challengeView.getCameraImage)
            }
        }

        Rectangle{
            id:trivia
            anchors.top:title.bottom
            anchors.bottom: parent.bottom
            anchors.topMargin: 50*dp
            visible: false
            anchors.horizontalCenter: parent.horizontalCenter
            Timer {
                id:visualTimer
                interval: 1000; running: false; repeat: true
                onTriggered: {
                    timeLimit = timeLimit - 1
                    if(timeLimit === 0){
                        var hold={
                            name:challenge.name,
                            type:challenge.type,
                            points : 10,
                            result:"wrong",
                            location:[challenge.location.latitude,challenge.location.longitude],
                        }
                        challenge.points=10
                        name.text=challenge.type+" Challenge Completed: "+challenge.points+"  points"
                        challengeCompleted(hold)
                        visualTimer.stop()
                    }
                }
            }

            Rectangle{
                id:questionTag
                height: 150*dp
                width: 450*dp
                clip:true
                color: "white"
                radius: 10*dp
                anchors.horizontalCenter: parent.horizontalCenter
                Text{
                    id:questionText

                    //anchors.fill:questionTag
                    anchors.centerIn: parent
                    verticalAlignment: Text.AlignVCenter
                    clip:true
                }
            }
            ListView{
                id:answersView
                width: 450*dp
                height:300*dp
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: questionTag.bottom
                anchors.topMargin: 50*dp
                spacing: 10*dp

                model: ListModel{
                    id:triviaAnswers
                }

                delegate:
                    RaisedButton{

                    color: "white"
                    radius: 10*dp
                    height:50*dp
                    width:answersView.width
                    text:answer
                    rippleColor: (answer === challenge.trivia.correctAnswer)? "green":"red"


                    onClicked:{
                        visualTimer.stop()
                        var hold={}

                        hold.name=challenge.name
                        hold.type=challenge.type
 hold.location=[challenge.location.latitude,challenge.location.longitude]
                        if(answer === challenge.trivia.correctAnswer)
                        {
                            challenge.points=15
                            hold.points = 15
                            hold.result="correct"
                            challengeCompleted(hold)
                            name.text=challenge.type+" Challenge Completed: "+challenge.points+"  points"
                        }
                        else
                        {
                            challenge.points=10
                            hold.points = 10
                            hold.result="wrong"
                            challengeCompleted(hold)
                            name.text=challenge.type+" Challenge Completed: "+challenge.points+"  points"
                        }


                    }
                }
            }
            ProgressBar{
                width: challengeToComplete.width
                height:50*dp
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                maximumValue: 25
                value: timeLimit
                style: ProgressBarStyle {
                    background: Rectangle {
                        radius: 2
                        color: "lightgray"
                        border.color: "gray"
                        border.width: 1
                        implicitWidth: 200*dp
                        implicitHeight: 24*dp
                    }
                    progress: Rectangle {
                        color: "#04d204"
                        border.color: "#054305"
                    }
                }


                Text {
                    text: timeLimit
                    color:"white"
                    font.bold: true
                    font.pixelSize: 15*dp
                    anchors.centerIn: parent
                }

            }
        }
    }

    Rectangle{
        id:congratsScreen
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
            width: 200*dp
            height: 50*dp
            color: "#FFD700"
            text: "Back to Adventure"
            onClicked: {
                backToAdventure(challenge.location)

            }
        }
    }
}
