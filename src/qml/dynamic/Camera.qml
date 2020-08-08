import QtQuick 2.0
import QtMultimedia 5.4
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.2
import "."

Item {
    id:camView
    property string imagePath: imagePath
    signal imageAccepted(var path)
    onImageAccepted: {
        photoPreview.visible = false
        buttonAccept.visible = false
    }

    state: "default"
    anchors.fill: parent


    onVisibleChanged: {
        if(visible === true){
            camera.start()
        }
        else{
            camera.stop()
        }
    }

    Camera {
        id: camera
        function flashOption(option){
            switch(option)
            {
            case 0:
                flash.mode=Camera.FlashOff
                break
            case 1:
                flash.mode=Camera.FlashOn
                break
            case 2:
                flash.mode=Camera.FlashAuto
                break
            }
        }
        exposure{
            exposureCompensation:  -1.0
            exposureMode: Camera.ExposureAuto
        }
        flash.mode:Camera.FlashOff
        position: switchView.cameraDefaultPosition ? Camera.BackFace:Camera.FrontFace

        imageCapture{

            onImageCaptured: {
                //console.log(QtMultimedia.availableCameras.length)
                //captureToLocation("")
                //console.log(preview)
                photoPreview.source = preview

            }

            onImageSaved: {

                imagePath = path.toString()
            }
        }
    }
    Rectangle{
        id:cameraView
        width: parent.width
        anchors.bottom: captureButBac.top
        anchors.top:parent.top
        VideoOutput {
            id: videoOut
            source: camera
            anchors.fill: parent
            fillMode: VideoOutput.PreserveAspectCrop
            focus: visible
            autoOrientation:true
            MouseArea{
                anchors.fill: parent

                onClicked: {
                    optionsBac.optionsViewType=0
                    camera.searchAndLock()
                }
            }
        }
        //    Rectangle{

        Image {
            id: photoPreview
            visible: false
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop

        }
    }
    Rectangle{
        id:tag
        property int tagViewType: 0 // 0; icon view 1: info form view
        visible: false
        width: 200*dp
        height: 200*dp
        color:"#191919"
        opacity: tag.tagViewType===0?0:0.5
        anchors.top: parent.top
        anchors.topMargin: 20*dp
        anchors.right: parent.right
        anchors.rightMargin: 20*dp

    }
    Image {
        id: tagIcon
        source: "../svg/icon.svg"
        visible: tag.visible
        width: 50*dp
        height: 50*dp
        sourceSize.width:50
        sourceSize.height:50
        anchors.top: tag.tagViewType===0?tag.top:undefined
        anchors.right: tag.tagViewType===0?tag.right:undefined
        anchors.horizontalCenter: tag.tagViewType===0?undefined:tag.horizontalCenter
        anchors.bottom: tag.tagViewType===0?undefined:tag.bottom
        anchors.bottomMargin: tag.tagViewType===0?0:20*dp
        MouseArea
        {
            anchors.fill: parent
            //enabled: tag.tagViewType===0?true:false
            onClicked:{
                if(tag.tagViewType===1)
                {
                    tag.tagViewType= 0
                    //save location info
                }
                else
                {
                    tag.tagViewType= 1
                }
            }
        }
    }

    Rectangle{
        id:tagInfo
        visible: tag.tagViewType===0?false:true

        color: "transparent"
        width: 200*dp
        height: 200*dp
        anchors.centerIn: tag
        TextField{
            id:tagTitle
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width-10
            height: 50*dp
            placeholderText: "Enter a Title..."
            anchors.topMargin: 5*dp
            textColor: "white"
        }
        TextField{
            id:tagDescription
            anchors.top: tagTitle.bottom
            anchors.topMargin: 10*dp
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width-10
            height: 50*dp
            placeholderText: "Enter a Description..."
            textColor: "white"
        }

    }
    Rectangle
    {//camera options. including flash options
        id:optionsBac
        property int optionsViewType: 0 // 0: no options view 1: options view
        width: optionsViewType===0?50*dp:100*dp
        height:optionsViewType===0?30*dp:50*dp
        radius: 15*dp
        color: "#191919"
        opacity: 0.5

        anchors.right:parent.right
        anchors.rightMargin: optionsViewType===0?10*dp:0
        anchors.bottom: captureButBac.top
        anchors.bottomMargin: optionsViewType===0?10*dp:0
        MouseArea{
            anchors.fill: parent
            //enabled: optionsBac.optionsViewType===0?true:false
            onClicked: {
                optionsBac.optionsViewType=1
            }
        }
    }
    Image {
        id: dots
        source: "../svg/dots.svg"
        width: 35*dp
        height: 35*dp
        sourceSize.width:50
        sourceSize.height:50
        anchors.centerIn: optionsBac
        visible: optionsBac.optionsViewType===0?true:false
    }
    ColorOverlay {
        anchors.fill: dots
        source: dots
        visible:dots.visible
        color: "#ffffff"
    }
    Rectangle
    {//bottom section which includes capture and acceptance buttons
        id:captureButBac
        width: parent.width
        height:100*dp
        anchors.bottom: parent.bottom
        color:"#191919"

    }
    Item{
        id:options
        anchors.fill: optionsBac
        visible: optionsBac.optionsViewType===0?false:true

        Image{
            id:flashView
            property int option:0
            source:"../svg/flash_off.svg"
            width: 30*dp
            height: 30*dp
            sourceSize.width:50
            sourceSize.height:50
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10*dp
            //enabled: camera.position===Camera.BackFace?true:false
            MouseArea
            {
                anchors.fill: parent

                onClicked: {
                    flashView.option++
                    switch(flashView.option)
                    {
                    case 0:
                        flashView.source="flash_off.svg"
                        camera.flashOption(0)
                        break
                    case 1:
                        flashView.source="flash_on.svg"
                        camera.flashOption(1)
                        break
                    case 2:
                        flashView.source="flash_auto.svg"
                        camera.flashOption(2)
                        flashView.option=-1
                        break
                    }
                }
            }
        }
        ColorOverlay {
            anchors.fill: flashView
            source: flashView
            color: "#ffffff"
            visible: flashView.visible
        }

        Image{
            id:switchView
            property bool cameraDefaultPosition: true
            width: 50*dp
            height: 50*dp
            sourceSize.width:50
            sourceSize.height:50
            source: "../svg/rotateCamera.svg"

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: flashView.right
            anchors.leftMargin: 10*dp
            MouseArea
            {
                anchors.fill: parent
                onClicked: {
                    switchView.cameraDefaultPosition = !switchView.cameraDefaultPosition
                }

            }

        }
        ColorOverlay {
            visible: switchView.visible
            anchors.fill: switchView
            source: switchView
            color: "#ffffff"
        }

    }


    Image {
        id: buttonCapture
        width: 50*dp
        height: 50*dp
        sourceSize.width:50
        sourceSize.height:50
        opacity: 0.8
        source: "../svg/camera.svg"

        anchors.centerIn: captureButBac
        MouseArea{
            anchors.fill: parent
            onClicked: {
                camView.state="imageTaken" //need to use C++ to do this
                camera.imageCapture.captureToLocation("")
            }
            onPressAndHold: {
                camera.searchAndLock()
            }
        }
    }
    ColorOverlay {
        anchors.fill: buttonCapture
        source: buttonCapture
        color: "#ffffff"
        visible: buttonCapture.visible
    }


    Image{
        id: buttonClear
        source: "../svg/cancel.svg"
        width: 40*dp
        height: 40*dp
        sourceSize.width:50
        sourceSize.height:50
        anchors.verticalCenter: captureButBac.verticalCenter
        anchors.right: buttonCapture.left
        anchors.rightMargin: 70*dp
        visible: false
        MouseArea{
            anchors.fill: parent
            onClicked: {

                //camera actions
                net.removeFile(imagePath)
                camera.imageCapture.cancelCapture()
                camView.state="default"
                //tag.tagViewType= 0
            }

        }

    }
    ColorOverlay {
        anchors.fill: buttonClear
        source: buttonClear
        color: "#ffffff"
        visible: buttonClear.visible
    }
    Image{
        id: buttonAccept
        source: "../svg/check.svg"
        width: 50*dp
        height: 50*dp
        sourceSize.width:50
        sourceSize.height:50
        anchors.verticalCenter: captureButBac.verticalCenter
        anchors.left: buttonCapture.right
        anchors.leftMargin: 70*dp
        visible: false
        MouseArea{
            anchors.fill: parent
            onClicked: {
                //stops current hardware devices upon image upload

                //camera.imageCapture.cancelCapture()
                //camera.stop()
camView.state="default"
                imageAccepted(imagePath)
            }

        }
    }
    ColorOverlay {
        anchors.fill: buttonAccept
        source: buttonAccept
        color: "#ffffff"
        visible: buttonAccept.visible
    }


    //CAMERA STATES
    states: [
        State {

            name: "default"
            PropertyChanges {target: cameraView; visible:true}
            PropertyChanges {target: photoPreview; visible:false}
            PropertyChanges {target: tag;tagViewType:0}//}
            AnchorChanges{target: tagIcon; anchors.bottom:undefined;anchors.horizontalCenter:undefined}
            // AnchorChanges {target: tagIcon;anchors.bottom: undefined}
            PropertyChanges {target: optionsBac; optionsViewType:0}
            //PropertyChanges {target: captureButBac; visible:true}
            //PropertyChanges {target: options; visible:false}
            PropertyChanges {target: buttonCapture; visible:true}
            PropertyChanges {target: buttonClear; visible:false}
            PropertyChanges {target: buttonAccept; visible:false}
        },
        State {
            name: "imageTaken"
            PropertyChanges {target: cameraView; visible:true}
            PropertyChanges {target: photoPreview; visible:true}
            PropertyChanges {target: tag; visible:true;tagViewType:0 }
            PropertyChanges {target: optionsBac; visible:true}
            //PropertyChanges {target: captureButBac; visible:true}
            //PropertyChanges {target: options; visible:false}
            PropertyChanges {target: buttonCapture; visible:false}
            PropertyChanges {target: buttonClear; visible:true}
            PropertyChanges {target: buttonAccept; visible:true}
        }
    ]
}

