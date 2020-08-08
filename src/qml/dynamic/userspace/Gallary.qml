import QtQuick 2.0

Rectangle {
    width: 100
    height: 62
}
/*        Rectangle{
                    id:photoShow
                    clip:true
                    color: "white"
                    radius:10*dp
                    x: parent.width*0.2
                    y: 10*dp
                    visible: playingRec.photoView
                    height:parent.height -15*dp
                    width:parent.width*0.8 - 20*dp
                    ListView{
                        id:photoList
                        anchors.fill: parent
                        orientation: Qt.Horizontal
                        // model: cloud.pictureModel
                        model:cloud.imagesModel

                        delegate:Image{
                            id:image
                            height:parent.height
                            sourceSize.height: height
                            fillMode: Image.PreserveAspectFit
                            Component.onCompleted: {
                                var data = { "id": file.id}
                                var reply = cloud.client.downloadUrl(data)
                                reply.finished.connect(function() {
                                    if(!reply.isError)
                                    {
                                        var data = reply.data.expiringUrl
                                        if (image && data) // It may be deleted as it is delegate
                                            image.source = data
                                    }
                                    else
                                    {
                                        console.log(reply.errorString)
                                    }
                                })
                            }

                        }

                    }
                }
                */
