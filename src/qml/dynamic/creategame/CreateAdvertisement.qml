import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import QtLocation 5.3
import QtPositioning 5.2
import QtGraphicalEffects 1.0
import "../../helpers"

Rectangle{
    id:advertisementRoot
    anchors.fill: parent
    property var addAdvertisementInstanceCoordinate
    //property alias finishHunt:finish1
    property real adPrise: 0

    function addAdvertisement(coordinate,name)
    {
        addAdvertisementInstanceCoordinate = coordinate
        advertisementRoot.state = "enterLocationInfo"
        mapItem.oneFreeMarker.coordinate = coordinate
        mapItem.oneFreeMarker.image.source = "../svg/ic_radio_button_on_24px.svg"
        mapItem.oneFreeMarker.image.width = 50*dp
        mapItem.oneFreeMarker.image.height = 50*dp
        mapItem.map.addMapItem(mapItem.map.oneFreeMarker)
        mapItem.map.center = coordinate
        mapItem.map.zoomLevel = mapItem.map.maximumZoomLevel
        mapItem.map.pan(0,170)
        checkLocation.calculatePrice(coordinate)
    }



    Rectangle {
        id: actionBar
        color: "#405ede"
        z: 2
        Behavior on color {ColorAnimation{ duration: 200 }}


        Text{
            id:huntName
            text: "Create Advertisement"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            verticalAlignment:Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 20*dp
            color:"white"

            height:actionBar.height - 20*dp
        }
        FloatingActionButton {
            id: backButton
            anchors.left: parent.left
            anchors.leftMargin: 16 * dp
            anchors.verticalCenter: parent.verticalCenter
            iconSource: "../svg/icon_back.svg"
            color:"transparent"
            onClicked:{
                root.cancelAdvertisement()
                actionBar.color = "#405ede"
            }
            visible: true
        }
    }
    ListModel{
        id: checkLocation
        function calculatePrice(adCoordinate){
            advertisementRoot.adPrise=0
            for(var i=0;i<count;i++)
            {   //console.log(checkLocation.get(i).latitude)
                var dist = QtPositioning.coordinate(checkLocation.get(i).latitude,get(i).longitude).distanceTo(adCoordinate)
                //console.log(dist);
                if(dist < 50){
                    advertisementRoot.adPrise = advertisementRoot.adPrise + 4
                }
                else if(dist < 500){
                    advertisementRoot.adPrise = advertisementRoot.adPrise + 2
                }
                else if(dist< 1000){
                    advertisementRoot.adPrise = advertisementRoot.adPrise + 0.1
                }
                else if(dist< 2000){
                    advertisementRoot.adPrise = advertisementRoot.adPrise + 0.05
                }

            }

        }
    }

    ListView{
        id:visitedLocation
        model:cloud.placesListModel
        delegate:  Item{
            MapQuickItem{
                id:spot
                coordinate: QtPositioning.coordinate(latitude, longitude)
                //zoomLevel: mapItem.map.zoomLevel

                sourceItem: Image{
                    source:"../images/circle-512.png"
                    width: 70*dp
                    height:70*dp
                    opacity: .15
                }

                Component.onCompleted: {
                    mapItem.map.addMapItem(spot)
                    checkLocation.append({"latitude":latitude,"longitude": longitude})
                }
            }
        }
    }

//    MapItem{
//        id:mapItem
//        width: parent.width
//        height: parent.height - actionBar.height
//        anchors.top: actionBar.bottom
//        onAddMapMarkerToHunt: {
//            advertisementRoot.addAdvertisement(coordinate,"")
//        }
//        onMapPressandHold: {
//            ///var reply  = cloud.client.query({"objectType":"objects.places","query":{"geoloc":{"$near":[coordinate.latitude,coordinate.longitude],"$maxDistance": 100}}})

//            var search = {
//                "phrase":"",
//                "properties":["geoloc"],
//                "near":{"location": [coordinate.latitude,coordinate.longitude], "distance": "2km"}
//            }
//            var query = {"objectTypes":["objects.places"],"search":search}

//            var reply  = cloud.client.fullTextSearch(query)
//            reply.finished.connect(function(){
//                if(!reply.isError)
//                {
//                    var data = reply.data.results
//                    //console.log(data.length)
//                }
//                else
//                {
//                    var rasd = reply.data
//                   // console.log(reply.errorString)
//                }
//            })
//            advertisementRoot.addAdvertisement(coordinate,"")
//        }
//        onMapClicked: {
//            advertisementRoot.state = ""

//        }
//        onMapSearch:{
//            advertisementRoot.state = ""

//        }
//    }

    Rectangle{
        id:addLocationInfoCard
        //height: addLocationInfo.currentIndex == 2 ? 450*dp:300*dp
        height:300*dp
        width: advertisementRoot.width * 0.7
        visible:false
        color: "white"
        anchors.horizontalCenter: parent.horizontalCenter
        y:advertisementRoot.height/2 - 100

    }

    PaperShadow{
        id:addLocationInfoCardShadow
        source: addLocationInfoCard
        visible:false
        anchors.fill: addLocationInfoCard
        width:addLocationInfoCard.width + 4
        height:addLocationInfoCard.height
        depth: 3
    }
    Rectangle{
        id:addLocationInfo
        anchors.fill:addLocationInfoCard
        //anchors.margins:10*dp
        clip: true
        visible:false
        //color:"yellow"
        TextField{
            id:companyName
            height: 50*dp
            width:parent.width -20*dp
            // verticalAlignment:TextInput.AlignVCenter
            anchors.top:parent.top
            anchors.topMargin: 10*dp
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: TextInput.AlignLeft
            placeholderText: "Company Name"

        }
        TextField{
            id:message
            height: 100*dp
            // width:parent.width - 120*dp
            anchors.top: companyName.bottom
            anchors.topMargin: 10*dp

            anchors.left: parent.left
            anchors.leftMargin: 10*dp
            anchors.right: addPhoto.left
            anchors.rightMargin:10*dp
            verticalAlignment:TextInput.AlignVCenter
            horizontalAlignment: TextInput.AlignLeft
            placeholderText: "Enter Your Message"
        }
        FloatingActionButton{
            id: addPhoto
            anchors.verticalCenter: message.verticalCenter
            anchors.verticalCenterOffset: -6 *dp
            anchors.rightMargin:10*dp
            anchors.right:parent.right
            iconHeight: 80*dp
            iconWidth: 80*dp
            color:"grey"
            iconSource: "../svg/icon_add.svg"
            onClicked: {

            }
        }
        Text{
            id:addPhotoText
            anchors.top:addPhoto.bottom
            anchors.topMargin: 4*dp
            anchors.horizontalCenter: addPhoto.horizontalCenter
            text: "Add Photo"
            font.pixelSize: 12*dp

        }

        RaisedButton{
            height:80*dp
            width:parent.width
            anchors.bottom:parent.bottom
            rippleColor: "yellow"
            text: "Buy Advertisement for: $" + adPrise.toPrecision(4)
            color:"green"
            onClicked: {

                root.finishAdvertisement()

            }

        }



    }

    states: [
        State {
            name: "enterLocationInfo"
            PropertyChanges{
                target:addLocationInfoCard
                visible:true
            }
            PropertyChanges{
                target:addLocationInfo
                visible:true
            }

            PropertyChanges{
                target:addLocationInfoCardShadow
                visible:true
            }

        }
    ]






}
