import QtQuick 2.4
import QtQuick.Controls 1.3
import QtLocation 5.3
import QtPositioning 5.3
import cppFileIO 1.0

ApplicationWindow {
    title: qsTr("HEATMAP")
    width: 640
    height: 480
    visible: true


    Map {
        id:map

        anchors.fill: parent

        center {
            latitude: 40.8005965
            longitude: -77.8864551
        }

        zoomLevel: 10
        plugin :     Plugin {
            id:plugin
            name : "osm"
        }

        MouseArea{
            anchors.fill: parent
            onClicked: {

            }
            onPressAndHold: {
                map.clearMapItems()
                heatdotsdb.clear()
            }
            onDoubleClicked: {
                var coordinate = map.toCoordinate(Qt.point(mouseX,mouseY))
                heatdotsdb.append({"name":"dot" + heatdotsdb.count, "coordinatez": coordinate,
                                      "longitude": coordinate.longitude, "latitude": coordinate.latitude})

                console.log("coordinate{ longitude: " + heatdotsdb.get(heatdotsdb.count - 1).longitude
                            + ", latitude: " + heatdotsdb.get(heatdotsdb.count - 1).latitude + " }")
            }
        }
    }

    FileOperations{
        id: fileops
    }

    ListView{
        model:heatdotsdb
        delegate: Item{
            MapQuickItem{
                id:spot
                coordinate: QtPositioning.coordinate(latitude, longitude)
                zoomLevel: map.zoomLevel

                sourceItem: Image{
                    source:"qrc:/circle-512.png"
                    width: Math.sqrt(Math.pow(map.width / 10, 2) + Math.pow(map.height / 10, 2))
                    height: Math.sqrt(Math.pow(map.width / 10, 2) + Math.pow(map.height / 10, 2))
                    opacity: .15
                }

                Component.onCompleted: {
                    map.addMapItem(spot)
                }
            }
        }
    }

    ListModel {
        id: heatdotsdb
    }
}
