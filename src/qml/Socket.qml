import QtQuick 2.0
import QtWebSockets 1.0
//WebSocketManager to establish comminucation between users who are active within gameplay
Item{

    //emit signal when user sends a message over socket
   // signal messageReceived(var message)

    /*
     * getSocketUri
     *
     * creates a socket for the session user is active
     *
     * @param list tags : creates the socket with these tags. User will only receive messages from other who specify one of these tags when sending messages
     *
     *
     *  On socket creation success, the server returns an authenticated uri that the user will use for sommunicatin over socket
     */
    function getSocketUri(tags)
    {
        //webSocket.url="ws://mar-eu-1-imihdb49.qtcloudapp.com"

        var socketRequest = new XMLHttpRequest()
        socketRequest.open("POST","https://mar-eu-1-imihdb49.qtcloudapp.com/v1/sockets",true)
        socketRequest.onreadystatechange = function(){
            if(socketRequest.readyState === 4)
            {
                if(socketRequest.status === 201 || socketRequest.status === 200)
                {

                    var jsonObject = JSON.parse(socketRequest.responseText)
                    var url=jsonObject.uri.slice(0, 2)+jsonObject.uri.slice(11);
                    //url=url.replace("com","com:5000")
                    //var url=jsonObject.uri
                    webSocket.url =  "wss://echo.websocket.org/"
                    console.log(url)
                    delete socketRequest
                }
                else{
                    console.log("here "+socketRequest.responseText)
                }
            }
        }
        socketRequest.setRequestHeader("ContentTypeHeader","application/json")
        socketRequest.setRequestHeader("Accept","application/json")
        socketRequest.setRequestHeader("Authorization","Bearer 6uQJHlapqH7osL5N6ns60fg23Q6xrXxB")

        socketRequest.send(JSON.stringify({tags: [tags]}))
    }

    /*
     * sendMessagetoSocket
     *
     * sends a message over socket to users with specified tags
     *
     * @param string message, list tags : only users with any of the specified tags will receive the message
     *
     *
     */
    function sendMessagetoSocket(message,tags)
    {
        var socketRequest = new XMLHttpRequest()
        socketRequest.open("POST","https://mar-eu-1-imihdb49.qtcloudapp.com/v1/messages",true)
        socketRequest.onreadystatechange = function(){
            if(socketRequest.readyState === 4)
            {//error checking here for message not received
                if(socketRequest.status === 201)
                {
                    console.log("message sent");
                    delete socketRequest
                }
                else
                {
                    console.log("message fail "+socketRequest.responseText)
                }
            }
        }
        socketRequest.setRequestHeader("ContentTypeHeader","application/json")
        socketRequest.setRequestHeader("Accept","application/json")
        socketRequest.setRequestHeader("Authorization","Bearer 6uQJHlapqH7osL5N6ns60fg23Q6xrXxB")

        //socketRequest.send("{\"data\":\""+messageString+"\",\"receivers\": {\"tags\": ["+messageTags+"],\"sockets\": null}}")
        socketRequest.send(JSON.stringify({data:message,receivers: {tags: tags,sockets: null}}))
    }

    /*instantiates a websocket object
     *
     *signals:
     *      onTextMessageReceived: emitted when the user receives a message over the socket
     *      onStatusChanged: emitted when the status of the websocket changes; error establishing socket, successfully opened a socket with a correct uri, or successfully cloased an opened socket
     *
     */
    WebSocket{
        id: webSocket
        //active: true
        //onActiveChanged: console.log("Asdfsf")
        onTextMessageReceived: {
            console.log("message received")
            var messageObject=JSON.parse(message)
//cloud.noticeModel.addNoticelocal([messageObject])
          //  messageReceived(messageObject)
        }

        onStatusChanged: {
            if(webSocket.status == WebSocket.Error){
                console.log("web socket error "+webSocket.errorString)
            }
            else if(webSocket.status == WebSocket.Open){
                console.log("web socket connected")
            }
            else if(webSocket.status == WebSocket.Closed){
                console.log("web socket disconnected")
            }
            else if(webSocket.status == WebSocket.Connecting){
                console.log("web socket connecting")
            }
        }


    }

}




