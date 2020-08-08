import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.3
import QtGraphicalEffects 1.0
import "../helpers"

Item {
    id:loginSignup
    anchors.fill: parent

    property string profilePicPath:"default"

    property alias loginButton:loginButton
    property alias signupButton:signupButton
    property alias username: username
    property alias password: password
    property alias email:email
    //property alias button3:raisedButton3
    function getCameraImage(path)
    {

        profilePicPath = path
        uimage.source = "file:///" + path
        //console.log(path)
        camera.imageAccepted.disconnect(getCameraImage)
        uimageItem.visible = true
    }

    FloatingActionButton {
        id: backButton
        anchors.left: loginSignup.left
        anchors.leftMargin: 10 * dp
        anchors.top: parent.top
        anchors.topMargin: 10*dp
        iconSource: "../svg/icon_back.svg"
        MouseArea{
            id:temp
            anchors.fill: parent
            onClicked: {
                backButton.visible=false
                loginForm.visible=false
                loginButton.visible=true
                loginButton.height=60*dp
                loginButton.color="white"
                signupButton.visible=true
                signupButton.height = 60*dp;
                signupButton.color="white"
                welcome.visible=true
            }
        }
        visible: false

    }
    Item {
        id:welcome
        anchors.centerIn: parent
        //anchors.topMargin: 100*dp
        visible: true
        Image {
            id: welcomeImage
            anchors.centerIn: parent
            height: 90*dp
            width: 90*dp
            sourceSize.height: 90*dp
            sourceSize.width: 90*dp
            source: "../svg/icon.svg"
        }
        Text {
            anchors.top:welcomeImage.bottom
            text:"AdventurUs"
            font.pointSize: 15*dp
            anchors.horizontalCenter: welcomeImage.horizontalCenter
        }
    }
    Rectangle
    {
        id:loginForm
        anchors.centerIn: parent
        width: parent.width
        height: 300*dp
        color: "transparent"
        Rectangle
        {
            id:usernameBox
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -200*dp
            anchors.horizontalCenter: parent.horizontalCenter
            height: 50*dp
            width: 0.7 * parent.width
            visible: false
            TextField{
                id: username
                placeholderText: qsTr("username")
                anchors.fill: parent
//                Image {
//                    id: uValid
//                    anchors.right: username.right
//                    anchors.verticalCenter: parent.verticalCenter
//                    visible: (username.text===""||email.visible)?false:true
//                    source: username.acceptableInput?"../images/check.png":"../images/invalid.png"
//                }
            }
            Text {
                id: usernameError
                visible: false
                anchors.top:username.bottom
                anchors.topMargin: 5*dp
            }
        }
        Rectangle
        {
            id:passwordBox
            anchors.top: usernameBox.bottom
            anchors.left: usernameBox.left
            height: 50*dp
            width: 0.7 * parent.width
            anchors.topMargin: 6*dp
            visible: false
            TextField{
                id: password
                anchors.fill: parent
                echoMode: TextInput.Password
                placeholderText: qsTr("password")
                validator: RegExpValidator{
                    regExp: /^[a-zA-Z]{8,}$/
                }
                Image {
                    id:pValid
                    anchors.right: password.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 5*dp
                    width: 20*dp
                    height:20*dp
                    sourceSize.width: 20*dp
                    sourceSize.height: 20*dp

                    visible: (password.text===""||!email.visible)?false:true
                    source: password.acceptableInput?"../images/check.png":"../images/invalid.png"
                }
            }
            Text {
                id: passwordError
                visible: false
                anchors.top:password.bottom
                anchors.topMargin: 5*dp
            }

        }
        Rectangle
        {
            id:emailBox
            anchors.top: passwordBox.bottom
            anchors.left: passwordBox.left
            height: 50*dp
            width: 0.7 * parent.width
            anchors.topMargin: 6*dp
            visible: false
            TextField{
                id: email
                anchors.fill: parent
                placeholderText: qsTr("email")
                validator: RegExpValidator{
                    regExp: /.*@.*[.].{3}/
                }

                Image {
                    id:eValid
                    anchors.right: email.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 5*dp
                    width: 20*dp
                    height:20*dp
                    sourceSize.width: 20*dp
                    sourceSize.height: 20*dp
                    visible: email.text===""?false:true
                    source: email.acceptableInput?"../images/check.png":"../images/invalid.png"
                }
            }
            Text {
                id: emailError
                visible: false
                anchors.top:email.bottom
                anchors.topMargin: 5*dp
            }

        }

//        FloatingActionButton{
//            id:addPhotoButton
//            anchors.top:emailBox.bottom
//            anchors.topMargin: 30*dp
//            anchors.horizontalCenter: usernameBox.horizontalCenter
//            visible:false
//            iconSource: "../images/male.png"
//            color: "#C4CDE0"
//            width: 150*dp
//            height:150*dp
//            onClicked:  {
//                camera.visible = true
//                camera.imageAccepted.connect(loginSignup.getCameraImage)
//            }
//        }

        Item{
            id:uimageItem
            width: 150*dp
            height:150*dp
            anchors.top:emailBox.bottom
            anchors.topMargin: 30*dp
            anchors.horizontalCenter: usernameBox.horizontalCenter
            visible: false
            Image{
                id: uimage
                source: "../images/male.png"
                fillMode: Image.PreserveAspectFit
                height: 150*dp
                width: 150*dp
                sourceSize.width: 150*dp
                sourceSize.height: 150*dp
                visible: false
            }

            Image {
                id:maskk
                source: "../images/black_circle.png"
                sourceSize.width: 150*dp
                sourceSize.height: 150*dp
                smooth: true
                visible: false
            }
            OpacityMask {
                id:t
                anchors.fill: uimage
                source: uimage
                maskSource: maskk
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    camera.visible = true
                    camera.imageAccepted.connect(loginSignup.getCameraImage)
                }
            }
        }

        Rectangle{
            id:loginMessage
            width: 150*dp
            height: 150*dp
            visible: false

            Text {
                id: loginMessageText
                anchors.fill : parent
                text: qsTr("Log in error. Try again!!")
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
            }
        }


    }
    RaisedButton {

        id: loginButton
        text: qsTr("LOG IN")
        width: parent.width
        rippleColor: "yellow"
        height: 60*dp
        anchors.bottom: signupButton.top
        onClicked: {
            if(usernameBox.visible)
            {
                cloud.con.loginType=0
                cloud.login(username.text,password.text)
            }
            else
            {
                welcome.visible=false
                loginForm.visible=true
                signupButton.height = 0;
                signupButton.visible = false;
                usernameBox.visible  = true;
                uimageItem.visible = false
                passwordBox.visible = true;
                emailBox.visible = false
                backButton.visible=true
                backButton.color="orange"
            }            color = "orange"

        }


    }


    RaisedButton {
        id: signupButton
        text: qsTr("SIGN UP")
        rippleColor: "green"
        width: parent.width
        height: 60*dp
        anchors.bottom: parent.bottom
        onClicked: {
            if(usernameBox.visible)
            {

                var userinfo = {}
                userinfo.username = username.text
                userinfo.password = password.text
                userinfo.email = email.text
                userinfo.firstName = ""
                userinfo.lastName = ""
                userinfo.objectType = "users"
                var hold =profilePicPath.toString()
                cloud.con.loginType=1
                cloud.registerAndLogin(userinfo,hold)

            }
            else
            {
                welcome.visible=false
                backButton.visible=true
                loginForm.visible=true
                loginButton.height = 0;
                loginButton.visible = false;
                usernameBox.visible  = true;
                uimageItem.visible = true;
                passwordBox.visible = true;
                emailBox.visible = true;
                backButton.color="purple"
                color = "purple"
            }
        }

    }
    Camera
    {
        id: camera
        visible:false
        onImageAccepted: {
            visible=false
            loginSignup.getCameraImage
        }
    }


}

