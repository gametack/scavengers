import QtQuick 2.4
import QtQuick.Controls 1.3
import QtLocation 5.3
import QtPositioning 5.3
import QtGraphicalEffects 1.0

import "helpers"

Item{
    id:mapRoot
    width: parent.width
    height: parent.height
    signal mapMarkerClicked(var coordinate)
    signal mapMarkerPressandHold(var coordinate)
    signal mapClicked(var mouseX,var mouseY)
    signal mapPressandHold(var coordinate)
    signal addMapMarkerToGame(var coordinate,var name)
    signal mapSearch()
    signal userMoved()

    property bool searchShown: false //search shown

    property bool streetMap : true
    property string searchType: "place"

    property alias map: map
    //property alias searchResults:searchResults
    property alias positionSource: positionSource
    property alias userLocation:userLocation

    function addMarkertoMap(coordinate, clearMap,animate)//array coordinates
    {
        if(clearMap)
        {
            mapMarkersModel.clear()
            map.clearMapItems()
        }
        if(animate)
        {
            mapMarkersModel.append(coordinate)
        }
        else{
            mapMarkersModel.append(coordinate)
        }
    }
    function addMarkerstoMap(coordinates, clearMap,animate)//array coordinates
    {
        if(clearMap)
        {
            mapMarkersModel.clear()
            map.clearMapItems()
        }
        if(animate)
        {
            mapMarkersModel.append(coordinate)
        }
        else{
            for(var i=0;i<coordinates.length;i++)
            {
                mapMarkersModel.append(coordinates[i])
            }
        }
    }

    function clearMapItems()
    {
        mapMarkersModel.clear()
        map.clearMapItems()
    }



    Map {
        id:map
        width: parent.width+80
        height: parent.height+80
        anchors.centerIn: parent
        center: QtPositioning.coordinate(40.79629640928221,-77.86260053292912)
        zoomLevel: maximumZoomLevel
        plugin :     Plugin {
            id:plugin
            name : "osm"
        }
        activeMapType: streetMap ? map.supportedMapTypes[0] : map.supportedMapTypes[1]

        Component.onCompleted: {
            map.addMapItem(userLocation)
        }

        MouseArea{
            anchors.fill: parent
            onClicked: {
                var coordinate = map.toCoordinate(Qt.point(mouseX,mouseY))
                mapClicked(mouseX,mouseY)
                //searchResults.state = "backToMap"
                userLocation.coordinate=coordinate
            }
            onPressAndHold: {
                var coordinate = map.toCoordinate(Qt.point(mouseX,mouseY))
                mapPressandHold(coordinate)
                //map.removeMapItem(resultMarker)
                //addMarkertoMap("",true)//deleteMap
            }
            onDoubleClicked: {
                //location.coordinate = coordinate
                //addressSearchText.text=location.a
                //ddress.text
                //searchResults.state = "addressSearchResult"
            }
        }
        MouseArea{
            id:cancelSearchMouseArea
            anchors.fill:parent

            enabled: searchShown ? true:false
            onClicked: {
                searchShown = !searchShown
                searchButton.depth = searchShown? 0:2
                placeSearch.detailShown = false
                // addMarkertoMap("",true)//clear map

            }
        }

    }

    //    Rectangle{
    //        width: 200
    //        height: 200
    //        anchors.bottom: parent.bottom
    //        anchors.right: parent.right
    //        color: "black"
    //        opacity: 0.3
    //        Image {
    //            id: name
    //            source: "icon_back.svg"
    //            width: 50
    //            height: 50
    //            anchors.top:parent.top
    //            anchors.horizontalCenter: parent.horizontalCenter
    //            transform: Rotation {angle: 90 }
    //            MouseArea{
    //                anchors.fill: parent
    //                onClicked: {
    //                    userLocation.coordinate.latitude+=0.0005

    //                }
    //            }

    //        }

    //        Image {
    //            id: name1
    //            source: "icon_back.svg"
    //            width: 50
    //            height: 50
    //            anchors.centerIn: parent
    //            transform: Rotation {angle: 270 }
    //            MouseArea{
    //                anchors.fill: parent
    //                onClicked: {
    //                    userLocation.coordinate.latitude-=0.0005

    //                }
    //            }
    //        }
    //        Image {
    //            id: name2
    //            source: "icon_back.svg"
    //            width: 50
    //            height: 50
    //            anchors.left:parent.left
    //            anchors.verticalCenter: parent.verticalCenter
    //            MouseArea{
    //                anchors.fill: parent
    //                onClicked: {
    //                    userLocation.coordinate.longitude-=0.0005

    //                }
    //            }
    //        }
    //        Image {
    //            id: name3
    //            source: "icon_back.svg"
    //            width: 50
    //            height: 50
    //            anchors.right:parent.right
    //            anchors.verticalCenter: parent.verticalCenter
    //            transform: Rotation { angle: 180 }
    //            MouseArea{
    //                anchors.fill: parent
    //                onClicked: {
    //                    //locAnim.start()
    //                    userLocation.coordinate.longitude+=0.00005

    //                }
    //            }
    //        }
    //    }
    MapQuickItem{
        id:userLocation
        property double currLocation
        Behavior on coordinate { CoordinateAnimation { duration:1000;easing.type:Easing.InOutQuad } }
        //coordinate:map.center
        // CoordinateAnimation {id:locAnim; properties: "coordinate"; easing.type:Easing.InOutQuad; duration: 10000; }
        function indicate(width,speed)
        {
            indicator.width = width
            xAnim.speed = speed
            xAnim.restart()
        }
        function stopIndicate()
        {
            indicator.width = 50*dp
            indicator.border.width = 0
            xAnim.stop()
        }
        Component.onCompleted: {
            map.addMapItem(userLocation)
        }
        coordinate:map.center
        sourceItem:
            Rectangle
        {
        Rectangle{
            anchors.centerIn: parent
            Rectangle
            {

                id:indicator
                anchors.centerIn: marker
                color: "#405ede"
                radius: width/2
                border.width: 0
                border.color: "red"
                clip: false
                opacity: 0.25
                width: 30*dp
                height: width
                SequentialAnimation on border.width  {
                    id: xAnim
                    property int speed: 1000
                    // Animations on properties start running by default
                    running: false
                    loops: Animation.Infinite // The animation is set to loop indefinitely
                    NumberAnimation{from: 2*dp; to: 15*dp; duration: xAnim.speed; }
                    NumberAnimation{from: 15*dp; to: 2*dp; duration: xAnim.speed; }
                }


            }

            RectangularGlow {
                anchors.fill: marker
                color: "#405ede"
                cornerRadius: 15*dp
                cached: true
                spread: 0.2
                glowRadius: 15*dp
            }


            Rectangle{
                id:marker
                color: "#405ede"
                radius: 15*dp
                border.color: "#f3f1f1"
                border.width: 2*dp
                anchors.centerIn: parent
                width:12*dp
                height:12*dp

            }
        }
    }
}


ListView{
    id: mapMarkers
    model:ListModel{
        id:mapMarkersModel
    }
    delegate: Item    {
        MapQuickItem{
            id: mapMarker
            anchorPoint.x: mapMarkersImage.width/4
            anchorPoint.y: mapMarkersImage.height
            coordinate: QtPositioning.coordinate(latitude, longitude)
            sourceItem:
                Image {
                id: mapMarkersImage
                source: "..images/marker.png"
                fillMode: Image.PreserveAspectFit
                width: 35*dp
                height: 35*dp

            }
            MouseArea{
                anchors.fill: parent
                onClicked: mapMarkerClicked(coordinate)
                onPressAndHold: mapMarkerPressandHold(coordinate)
            }
            Component.onCompleted: {

                map.addMapItem(mapMarker)

            }
        }
    }
}

PositionSource{
    id: positionSource
    updateInterval: 1000
    active:true
    onPositionChanged: {
        userMoved()
    }
    Component.onCompleted: {
        // console.log("suported"+supportedPositioningMethods)
        ///console.log("prefered"+preferredPositioningMethods)
        //  console.log("error"+sourceError)
        if(valid){
            map.center = position.coordinate
        }
        else
        {
            //map.center = QtPositioning.coordinate(40.79676988896458,-77.86892303519943)
        }
    }
}

Plugin{
    id: myPlugin
    name: "nokia"
    PluginParameter { name: "here.app_id"; value: "KFcjLIC54DiDT3ek9sRh" }
    PluginParameter { name: "here.token"; value: "EM1i74NYbnORceI0wVDnCQ" }
}


GeocodeModel{
    id:geocodeModel
    plugin:map.plugin
    onLocationsChanged: {
        //map.center = get(0).coordinate

    }
}
PlaceSearchModel {
    id: searchModel
    plugin: myPlugin

    //lookhere only use location
    searchArea:positionSource.valid? QtPositioning.circle(positionSource.position.coordinate):QtPositioning.circle(QtPositioning.coordinate(40.8005965,-77.8864551))
    //searchArea:QtPositioning.circle(QtPositioning.coordinate(40.8005965,-77.8864551))
}

PlaceSearchSuggestionModel{
    id: searchSuggestionModel
    plugin: myPlugin
    //lookhere only use location
    searchArea:positionSource.valid? QtPositioning.circle(positionSource.position.coordinate):QtPositioning.circle(QtPositioning.coordinate(40.8005965,-77.8864551))
    //searchArea:QtPositioning.circle(QtPositioning.coordinate( 40.8005965,-77.8864551))
    onStatusChanged: {
        if(status === PlaceSearchSuggestionModel.Ready)
        {
            if(suggestions.length === 0)
            {
                searchType = "geo"
                geocodeModel.query = searchField.text
                geocodeModel.update()
            }
            else
            {
                searchType = "place"
            }
        }
    }
}



TextField{
    id: searchField
    width:parent.width-80
    height:35*dp
    anchors.right: searchButton.horizontalCenter
    anchors.top:searchButton.top
    visible: searchShown? true:false
    placeholderText: qsTr("Location Search")
    NumberAnimation { target: searchField; property: "opacity"; duration: 300}
    /*Image{
            source: "search.svg"
            anchors.right: parent.right
            height: searchField.height
            opacity: 0
            MouseArea{
                anchors.fill:parent
                onClicked: {
                    if(searchField.text === "")
                    {
                        searchField.forceActiveFocus()
                    }
                    else
                    {
                        searchField.accepted()
                    }
                }
            }
        }*/

    onTextChanged: { //for autosearch
        if(text!=="")
        {
            placeSearch.detailShown = false
            searchSuggestionModel.searchTerm = text
            searchSuggestionModel.update()
            // searchButton.iconSource = "ic_chevron_right_24px.svg"

        }
        else{
            //  searchButton.iconSource = "search.svg"
        }

    }
    onActiveFocusChanged: {
        if(focus)
        {
            //  searchResults.visible = true
        }
    }
    onAccepted: {
        if(text!=="")
        {
            searchModel.searchTerm = text
            searchModel.update()
            placeSearch.detailShown = true
        }
    }
}


FloatingActionButton{
    id:searchButton
    color:"white"
    iconSource: "svg/search.svg"
    visible: true
    anchors {
        right: parent.right
        top: parent.top
        margins: 7 * dp
    }
    iconWidth: 35*dp
    iconHeight: 35*dp
    onClicked: {
        mapSearch()
        searchShown = !searchShown
        searchButton.depth = searchShown? 0:2
        placeSearch.detailShown = false
    }
}


Rectangle{
    id:placeSearch
    width: searchField.width
    height: 155*dp
    anchors.left:searchField.left
    anchors.top:searchField.bottom
    anchors.right: searchField.right
    anchors.leftMargin: 12*dp
    anchors.rightMargin: 12*dp
    color: "transparent"
    visible: searchShown?1:0
    property bool detailShown:false
    clip:true
    enabled: searchShown ? true:false

    ListView {
        id:suggestionList
        anchors.fill: parent
        model: searchType === "place" ? searchSuggestionModel :geocodeModel
        visible: placeSearch.detailShown ? false:true
        delegate: Item{
            width: parent.width
            height:25*dp
            Rectangle{
                id:resultRec
                anchors.fill:parent
                anchors.margins: 1*dp
                color:"white"
                clip:true
            }

            Text {
                id: suggestiontext
                text: searchType === "place" ? suggestion : locationData.address.text
                anchors.fill: resultRec
                horizontalAlignment:Text.AlignLeft
                verticalAlignment: Text.AlignHCenter
                anchors.leftMargin: 5*dp
            }
            MouseArea{
                anchors.fill: resultRec
                onClicked: {
                    if(searchType === "place")
                    {
                        placeSearch.detailShown = !placeSearch.detailShown
                        searchModel.searchTerm = suggestion
                        searchModel.update()

                    }
                    else
                    {
                        //addressSearchText.text=locationData.address.text
                        //  searchResults.state = "addressSearchResult"
                    }
                }
            }

        }
    }
    ListView {
        id:placeSearchDetail
        visible: placeSearch.detailShown ? true:false
        anchors.fill: parent
        model: searchModel
        snapMode:ListView.SnapToItem
        delegate: Item{
            width: parent.width
            height:75*dp
            Rectangle{
                id:resultRec2
                anchors.fill:parent
                anchors.margins: 5*dp
                anchors.bottomMargin: 0
                color:"white"
                clip:true
            }
            PaperShadow{
                anchors.fill:resultRec2
                source: resultRec2
                depth: result2mouse.pressed ? 4:2
            }

            Row{
                //anchors.fill: resultRec2
                anchors.verticalCenter: resultRec2.verticalCenter
                anchors.leftMargin: 6*dp
                anchors.left:resultRec2.left
                //anchors.topMargin: 5*dp
                spacing: 6*dp
                Image{
                    source:place.icon.url(Qt.size(35*dp,35*dp))
                    width: 35*dp
                    height:35*dp
                }

                Column
                {
                    Text {
                        text: place.name
                        font.bold: true
                    }
                    Text {
                        text: place.location.address.text }
                    Text {
                        text: (distance*0.00062137).toFixed(2) +  " miles"

                    }
                }
            }

            MapQuickItem{
                id:resultMarker
                anchorPoint.x: resultMarkerImage.width/4
                anchorPoint.y: resultMarkerImage.height
                coordinate:place.location.coordinate
                sourceItem:
                    Image {
                    id: resultMarkerImage
                    source: "mages/marker.png"
                    fillMode: Image.PreserveAspectFit
                    width: 30*dp
                    height: 30*dp
                }
                Component.onCompleted: map.addMapItem(resultMarker)
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        //addressCoordinate.coordinate = place.location.coordinate
                        mapMarkerClicked(place.location.coordinate)
                        map.center = place.location.coordinate
                        map.zoomLevel = map.maximumZoomLevel-1
                        //  addressSearchText.text =place.location.address.text
                        //  addressSearchmiles.text = (distance*0.00062137).toFixed(2) +  " miles"
                        //  searchResults.state = "addressSearchResult"
                    }
                    onPressAndHold:
                    {
                        //addressCoordinate.coordinate = place.location.coordinate
                        mapMarkerPressandHold(place.location.coordinate)
                    }
                }
            }
            MouseArea{
                id:result2mouse
                anchors.fill: resultRec2
                onClicked: {
                    //addressCoordinate.coordinate = place.location.coordinate
                    map.center = place.location.coordinate
                    map.zoomLevel = map.maximumZoomLevel-1
                    map.pan(0,-140)
                    //searchResults.state = "addressSearchResult"
                }
            }
            FloatingActionButton {
                id: addButton

                visible: mapRoot.state==="creategame"?true: false
                anchors {
                    right: resultRec2.right
                    margins: 6 * dp
                    verticalCenter: resultRec2.verticalCenter
                }
                width: 35*dp
                height: 35*dp

                color: "#ff5177"
                iconSource: "../icon_add.svg"

                onClicked: {
                    //addMarkertoMap("",true)//clear map
                    addMapMarkerToGame(place.location.coordinate,place.name)
                    searchShown = !searchShown
                    map.removeMapItem(resultMarker)

                }
            }
        }

    }

}

states: [
State {
    name: "gameplay"
    PropertyChanges {

    }
},

State {
    name: "creategame"
//    PropertyChanges {
//        target:object
//    }
},
State {
    name: "explorer"
    PropertyChanges {
        target: object

    }
},
State {
    name: "profile"
    PropertyChanges {
        target: object

    }
}
]

}
