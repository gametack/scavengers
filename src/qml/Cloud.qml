import QtQuick 2.4
import Enginio 1.0
import QtQuick.LocalStorage 2.0
import "objectCreation.js" as ObjectCreation

Item{

    property string username:""
    property var db //localdatabase

    property string loadingStatus: "init"

    property alias client: client
    property var date: new Date()

    property alias activeGamesListModel: activeGamesListModel
    property alias usersListModel: usersListModel
    property alias myInfoModel: myInfoModel
    property alias friendListModel: friendListModel
    property alias placesListModel: placesListModel
    property alias gamesListModel: gamesListModel
    property alias messagesModel: messagesModel
    property alias noticeModel: noticeModel
    property alias imagesModel: imagesModel
    property alias identity:identity



    //Temporary untill get function applied to EnginioModel
    ListView{
        id: populateFriendList
        model:friendListModel
        delegate: Item{
            Component.onCompleted: {
                //friends.push(friend)

            }
        }
    }


    //instantiates object used to authenticate user logins
    EnginioOAuth2Authentication
    {
        id:identity
    }

    //instantiates a client object to communicate with cloud database
    EnginioClient
    {
        id: client
        backendId: "548a78545a3d8b0ce1002df6"
        onError: {
            console.log("Enginio error: " + reply.errorCode + ": " + reply.errorString)
        }
    }



    //instantiates a model to retrieve queried user information from database
    EnginioModel{
        id: usersListModel
        client: client

        function loadUser(name)
        {
            query={"objectType":"objects.userMap","query":{"username":name}}
        }
        function load()
        {
            query={"objectType":"objects.userMap"}

        }


        function unLoad()
        {
            query={}
        }
    }
    ListModel{
        id: myInfoModel

        function load()
        {
            db.readTransaction(
                        function(tx) {
                            var getInfo=tx.executeSql('SELECT * FROM UserInfo ')
                            if(getInfo.rows.length!==0)
                                myInfoModel.append(getInfo.rows.item(0))
                        }
                        )
        }

        function updateMyInfo(type,value)
        {
            setProperty(0,type,value)
        }


        function unLoad()
        {
            myInfoModel.clear()
        }

    }


    EnginioModel{
        id: imagesModel
        client:client
        function load(type,user)
        {
            query= {"objectType":"objects.images","query":{"type":type,"username":user,"file": { "$ne": null }}}
        }

        function unLoad()
        {
            query={}
        }
    }

    EnginioModel{
        id: friendListModel

        client: client
        function load(user)
        {
            query={"objectType":"objects.friends", "query":{"username":user}}
        }
        function unLoad()
        {
            query={}
        }
    }
    ListModel{
        id: noticeModel
        property int unreadCount: 0
        function syncRemote(){
            var reply=cloud.client.query({"objectType":"objects.notice",query:{"players":cloud.username}})
            reply.finished.connect(function(){
                var results=reply.data.results
                    db.transaction(
                                function(tx) {
                                    var hold=[]
                                    for(var i=0;i<results.length;i++)
                                        hold.push("\""+results[i].id+"\"")

                                    var checkRet=tx.executeSql('DELETE FROM Notice WHERE remote_id NOT IN ('+hold.join(",")+')')
                                    console.log(checkRet.rowsAffected)

                                    for(i=0;i<results.length;i++)
                                    {
                                        var notice=results[i]
                                        if(notice.type==='message')
                                        {
                                            db.transaction(
                                                        function(tx) {
                                                            tx.executeSql('UPDATE Notification SET read=0 WHERE remote_id='+JSON.stringify(notice.message.remote_id))
                                                        })
                                            if(notice.players.length>1){
                                                notice.players.splice(notice.players.indexOf(cloud.username),1)
                                                cloud.client.update(notice)
                                            }
                                            else{
                                                cloud.client.remove(notice)
                                            }
                                        }
                                        else
                                        {
                                            var ret=tx.executeSql('INSERT OR IGNORE INTO Notice(message ,players, type, read,remote_id) VALUES(?,?,?,?,?)', [ JSON.stringify(notice.message),notice.players.toString(), notice.type, 0,notice.id]);
                                        }
                                    }
                                })
            })
        }
        function load()
        {
            db.readTransaction(
                        function(tx) {
                            var getNotif=tx.executeSql('SELECT * FROM Notice ORDER BY notice_id DESC')
                            for(var i =0;i<getNotif.rows.length;i++)
                            {
                                var notice ={}
                                var obj1=getNotif.rows.item(i)
                                var obj2 =JSON.parse(obj1.message)
                                delete obj1['message']
                                for(var key in obj1) notice[key ]=obj1[key];
                                for(var key in obj2) notice[key ]=obj2[key];
                                if(notice.read===0)
                                    unreadCount++
                                noticeModel.append(notice)
                            }
                        }
                        )
        }

        function loadNotice(noticeId)
        {
            console("jhjhgjg")
            db.readTransaction(
                        function(tx) {
                            var getNotif=tx.executeSql('SELECT * FROM Notice ORDER WHERE notice_id='+noticeId)
                            for(var i =0;i<getNotif.rows.length;i++)
                            {
                                var notice ={}
                                var obj1=getNotif.rows.item(i)
                                var obj2 =JSON.parse(obj1.message)
                                delete obj1['message']
                                for(var key in obj1) notice[key ]=obj1[key];
                                for(var key in obj2) notice[key ]=obj2[key];
                                console.log(JSON.stringify(notice))
                                if(notice.read===0)
                                    unreadCount++
                                noticeModel.append(notice)
                            }
                        }
                        )
        }

        function sendNotice(noticeObject)
        {
            //use this to only send necessary items
            var actualObject={
                message:noticeObject.message,
                type:noticeObject.type,
                players:noticeObject.players
            }

            createObject(actualObject,"notice",function(reply){
                actualObject.id=reply.data.id
                socket.sendMessagetoSocket(JSON.stringify(actualObject),actualObject.players)
            })

        }
        function setNoticeRead(index){
            var hold=get(index).notice_id
            db.transaction(
                        function(tx) {
                            tx.executeSql('UPDATE Notice SET read=1 WHERE notice_id='+hold)
                            setProperty(index,"read",1)
                            unreadCount--
                        })
        }

        function addNoticelocal(noticeArray)
        {//addToMessageModel means we didnt get message from cloud archive, but are adding from notice received
            db.transaction(
                        function(tx) {
                            for(var i=0;i<noticeArray.length;i++)
                            {
                                var notice=noticeArray[i]
                                console.log(JSON.stringify(notice.type))
                                if(notice.type==="message")
                                {
                                    var messageObject=JSON.parse(JSON.stringify(notice))

                                    messageObject.id=notice.message.remote_id
                                    messageObject.read=0
                                    messageObject.notification_id=0//

                                    //set up player list
                                    messageObject.players.splice(username,1)
                                    messageObject.players.push(messageObject.message.player)
                                    messageObject.players.sort()

                                    db.transaction(function(tx){
                                        var ret=tx.executeSql('SELECT * FROM Notification WHERE remote_id='+JSON.stringify(messageObject.id))
                                        messageObject.notification_id=0
                                        if(ret.rows.length!==0)
                                        {
                                            messageObject.notification_id=ret.rows.item(0).notification_id
                                        }
                                    })

                                    messagesModel.addMessageLocal(messageObject)
                                    notice.objectType="objects.notice"
                                    if(notice.players.length>1){
                                        notice.players.splice(notice.players.indexOf(cloud.username),1)
                                        cloud.client.update(notice)
                                    }
                                    else{
                                        cloud.client.remove(notice)
                                    }
                                }
                                else
                                {
                                    var ret=tx.executeSql('INSERT OR IGNORE INTO Notice(message ,players, type, read,remote_id) VALUES(?,?,?,?,?)', [ JSON.stringify(notice.message),notice.players.toString(), notice.type, 0,notice.id]);
                                    loadNotice(ret.insertId)
                                }
                            }

                        })
        }

        function removeNotice(index)
        {
            var hold=get(index).players.split(",")
            var noticeUpdateObject={
                id:get(index).remote_id,
                objectType:"objects.notice"
            }


            if(hold.length>1)
            {
                hold.splice(hold.indexOf(username),1)
                noticeUpdateObject.players=hold
                client.update(noticeUpdateObject)
            }
            else
            {
                console.log(JSON.stringify(noticeUpdateObject))
                client.remove(noticeUpdateObject)
            }

            db.transaction(
                        function(tx) {
                            var getNotif=tx.executeSql('DELETE FROM Notice WHERE notice_id='+get(index).notice_id)
                        })
            remove(index)
            unreadCount--
        }

        function unLoad()
        {
            noticeModel.clear()
        }

    }

    ListModel{
        id: messagesModel
        property int unreadCount: 0

        function load()
        {
            db.readTransaction(
                        function(tx) {
                            var getNotif=tx.executeSql('SELECT * FROM Notification ORDER BY notification_id DESC')
                            for(var i =0;i<getNotif.rows.length;i++)
                            {
                                var hold =getNotif.rows.item(i)
                                var getMsg=tx.executeSql('SELECT * FROM Messages WHERE notification_id = '+hold.notification_id+' ORDER BY message_id DESC LIMIT 1 ')
                                //console.log(getMsg.rows.length)
                                if(getMsg.rows.length!==0)
                                {
                                    hold.message=getMsg.rows.item(0)
                                    if(hold.read===0)
                                        unreadCount++
                                    messagesModel.append(hold)
                                }
                            }
                        }
                        )
        }
        function loadMessage(notification_id,update)//if to update current message of notification or load one not in model
        {
            db.readTransaction(
                        function(tx) {
                            var getMsg=tx.executeSql('SELECT * FROM Messages WHERE notification_id = '+notification_id+' ORDER BY message_id DESC LIMIT 1 ')
                            var message=getMsg.rows.item(0)
                            if(update)
                            {
                                //notification is backwards in interms of created sort and index start with 0
                                //so if we take the total count - the notification id, we get the one to update
                                //ex: 0 1 2 3 4 5 6
                                //    7 6 5 4 3 2 1
                                //need better implementation if messages are sorted by update time
                                var index=count-notification_id
                                messagesModel.setProperty(index,"message",message)
                                userSpace.notification.userMessageList.addMessageToList(message,index)
                            }
                            else
                            {

                                var getNotif=tx.executeSql('SELECT * FROM Notification WHERE notification_id ='+notification_id)
                                var hold =getNotif.rows.item(0)
                                if(getMsg.rows.length!==0)
                                {
                                    hold.message=message
                                    if(hold.read===0)
                                        unreadCount++
                                    messagesModel.append(hold)
                                    messagesModel.move(messagesModel.count-1,0,1)
                                }
                            }
                        }
                        )
        }

        function unLoad()
        {
            messagesModel.clear()
        }
        function setMessageRead(index){
            var hold=get(index).notification_id
            db.transaction(
                        function(tx) {
                            tx.executeSql('UPDATE Notification SET read=1 WHERE notification_id='+hold)
                            setProperty(index,"read",1)
                            unreadCount--
                        })
        }
        function setMessageUnread(index){
            var hold=get(index).notification_id
            db.transaction(
                        function(tx) {
                            tx.executeSql('UPDATE Notification SET read=0 WHERE notification_id='+hold)
                            setProperty(index,"read",0)
                            unreadCount++
                        })
        }

        function addMessageLocal(messageObject)
        {
            db.transaction(
                        function(tx) {
var toUpdate=Boolean(messageObject.notification_id)
                            if(messageObject.notification_id===0)
                            {
                                var ret=tx.executeSql('INSERT OR IGNORE INTO Notification(players , read,remote_id) VALUES(?, ?,?)', [ messageObject.players.toString(), messageObject.read,messageObject.id]);
                                messageObject.notification_id=ret.insertId
                            }

                            var msg=messageObject.message
                            tx.executeSql('INSERT INTO Messages(message, player,createdAt,notification_id) VALUES(?,?,?,?)', [msg.message, msg.player,msg.createdAt,messageObject.notification_id]);
                            loadMessage(messageObject.notification_id,toUpdate)
                        })
        }

        function addNewMessage(messageObject)
        {
            var messageObjectForRemote=JSON.parse(JSON.stringify(messageObject))
            messageObjectForRemote.players.push(cloud.username)
            messageObjectForRemote.messages=[messageObjectForRemote.message]
            delete messageObjectForRemote["message"]
            var callBack=function(reply){//create in local dB message item


                messageObject.message.remote_id=reply.data.id
                noticeModel.sendNotice(JSON.parse(JSON.stringify(messageObject)))

                messageObject.id=reply.data.id
                messageObject.read=1
                addMessageLocal(messageObject)


            }

            //create in remote dB message item
            createObject(messageObjectForRemote,"messages",callBack)
        }
        function updateMessage(messageObject,index)
        {

            var data = {
                "$push": {
                    "messages": messageObject.message
                }
            }
            var callback=function(returnId){

                messageObject.message.remote_id=returnId
                noticeModel.sendNotice(JSON.parse(JSON.stringify(messageObject)))

                messageObject.id=returnId
                addMessageLocal(messageObject)
            }
            atomicUpdate(get(index).remote_id,"messages",data,callback)
        }
    }


    //instantiates a model to retrieve queried games from database
    EnginioModel{
        id: gamesListModel
        client:client
        function load(type)
        {
            query= {"objectType":"objects.games"}
        }
        function unLoad()
        {
            query={}
        }
    }

    //instantiates a model to retrieve queried active games from database
    ListModel{
        id: activeGamesListModel
        property int activeIndex:0

        function addGameLocal(gameObject)//takes an array of games
        {
            db.transaction(
                        function(tx) {
                            var challenges=gameObject.challenges
                            var completedChallenges=gameObject.completedChallenges
                            var ret=tx.executeSql('INSERT OR IGNORE INTO Activegames(name ,players, points , progress , type, remote_id ) VALUES(?,?, ?, ?,?,?)', [gameObject.name,gameObject.players.toString(), gameObject.points,gameObject.progress,gameObject.type,gameObject.id]);

                            //update completed challenges
                            for(var j=0;j<completedChallenges.length;j++)
                            {
                                var challenge=completedChallenges[j]
                                tx.executeSql('INSERT INTO CompletedChallenges(name, points, type, location, result,activegame_id) VALUES(?, ?, ?,?,?,?)', [challenge.name,challenge.points,challenge.type,JSON.stringify(challenge.location),challenge.result,ret.insertId]);
                            }

                            //update active challenges
                            if(gameObject.type==="scavanger hunt")
                            {
                                for(j=0;j<challenges.length;j++)
                                {
                                    challenge=challenges[j]
                                    var values=[ challenge.name,challenge.type,challenge.clue,challenge.arrival,JSON.stringify(challenge.location)]
                                    if(challenge.type==="Trivia")
                                        values.push(JSON.stringify(challenge.trivia))
                                    else
                                        values.push("none")

                                    values.push(ret.insertId)
                                    tx.executeSql('INSERT INTO Challenges(name, type, clue,arrival,location, trivia,activegame_id ) VALUES(?, ?, ?,?,?,?,?)', values);
                                }

                            }
                            else if (gameObject.type==="tag")
                            {

                            }
                            else if (gameObject.type==="tour")
                            {

                            }
                            loadGame(ret.insertId)
                        })
        }

        function addGame(gameObject,messageObject,playType)
        {
            var callback = function(reply)
            {
                gameObject.id=reply.data.id
                addGameLocal(gameObject)
                if(playType==="multi")
                {
                    messageObject.message.remote_id=reply.data.id
                    noticeModel.sendNotice(messageObject)
                }
            }

            createObject(JSON.parse(JSON.stringify(gameObject)),"activeGames",callback)

        }

        function load()
        {
            db.readTransaction(
                        function(tx) {
                            var getNotif=tx.executeSql('SELECT * FROM Activegames ORDER BY activegame_id DESC')
                            for(var i =0;i<getNotif.rows.length;i++)
                            {
                                activeGamesListModel.append(getNotif.rows.item(i))

                            }
                        }
                        )
        }
        function loadGame(gameId)
        {
            db.readTransaction(
                        function(tx) {
                            var getNotif=tx.executeSql('SELECT * FROM Activegames WHERE activegame_id='+gameId)
                            activeGamesListModel.append(getNotif.rows.item(0))
                        }
                        )
        }

        function updateActiveGame(gameUpdate,localUpdateInfo)
        {
            set(activeIndex,gameUpdate)
            var hold={
                points:gameUpdate.points,
                progress:gameUpdate.progress,
                challenges:gameUpdate.challenges,
                completedChallenges:gameUpdate.completedChallenges,
                objectType:"objects.activeGames",
                id:gameUpdate.remote_id
            }


            var reply=client.update(hold)
            reply.finished.connect(function(){
                if(reply.isError)
                {

                }
            })
            db.transaction(
                        function(tx) {
                            tx.executeSql('UPDATE Activegames SET points='+gameUpdate.points+', progress='+gameUpdate.progress+' WHERE activegame_id='+gameUpdate.activegame_id)

                            tx.executeSql('DELETE from Challenges where challenge_id='+localUpdateInfo.challenge_id)

                            var hold=localUpdateInfo.finishedChallenge
                            tx.executeSql('INSERT INTO CompletedChallenges(name, points, type, location, result,activegame_id) VALUES(?, ?, ?,?,?,?)', [hold.name,hold.points,hold.type,JSON.stringify(hold.location),hold.result,gameUpdate.activegame_id])
                        })
            if(JSON.parse(gameUpdate.players).length>1)
            {
                var noticeObject={
                    players:JSON.parse(gameUpdate.players),
                    messages:[]
                }
                noticeObject.players.splice(noticeObject.players.indexOf(username),1)
                if(gameUpdate.progress===1)
                {
                    noticeObject.message={message:username+" completed "+gameUpdate.name+" game!",player:username,createdAt:getDate()}
                    noticeObject.type="gamecompleted"
                }
                else
                {
                    noticeObject.message={message:username+" completed "+localUpdateInfo.finishedChallenge.name+" challenge!",player:username,createdAt:getDate()}
                    noticeObject.type="chalcompleted"
                }
                noticeModel.sendNotice(noticeObject)
            }
        }

        function unLoad()
        {
            activeGamesListModel.clear()
        }
    }

    EnginioModel{
        id: placesListModel
        client:client

        function load()
        {
            query= {"objectType":"objects.places"}
        }
        function unLoad()
        {
            query={}
        }
    }





    //FUNCTIONS
    //--------------------------------------------------------------------------------------//
    //--------------------------------------------------------------------------------------//

    function reloadModels(){
        //placesListModel.load()
        //friendListModel.load()
        //imagesModel.load()
        gamesListModel.load()
        //usersListModel.load()
        //from localDB
        myInfoModel.load()
        //noticeModel.load()  commented out for a reason, see getDb
        messagesModel.load()
        activeGamesListModel.load()

    }

    function login(user,password)
    {
        username = user.toLowerCase()
        net.saveInfo(username,password)
        identity.user = username
        identity.password = password
        client.identity = identity
    }

    function registerAndLogin(userinfo,profilePicPath)
    {
        var reply = client.create(userinfo)
        reply.finished.connect(function()
        {
            if(!reply.isError)
            {
                var userId=reply.data.id
                con.registerInfo={
                    userId:userId,
                    user:userinfo.username,
                    profilePicPath:profilePicPath
                }

                login(userinfo.username,userinfo.password)
            }
            else
            {
                console.log(reply.errorString)
            }
        })

    }

    function getDate()
    {
        return date.toLocaleString(Qt.locale(),"M/d/yy h:mm a")
    }

    function addUserToAllUsersGroup(userId,username,profilePicPath) {

        var groupQuery = client.query({ "query": { "name" : "allUsers" } }, Enginio.UsergroupOperation)

        groupQuery.finished.connect(function(){

            if (groupQuery.errorType !== EnginioReply.NoError) {
                console.log(groupQuery.errorString)
            }
            else if (groupQuery.data.results.length === 0 ){
                console.log("Usergroup 'allUsers' not found, check required backend configuration from Social Todos example documentation.")
            }
            else if (groupQuery.errorType === EnginioReply.NoError) {
                var addUserToGroupData = {
                    "id": groupQuery.data.results[0].id,
                    "member" : {
                        "id": userId,
                        "objectType": "users"
                    }
                }
                var addUserToGroup = client.create(addUserToGroupData, Enginio.UsergroupMembersOperation)
                addUserToGroup.finished.connect(function(){
                    if (addUserToGroup.errorType === EnginioReply.NoError) {
                        //final user setup
                        usersListModel.load()
                        var profilePicName=""
                        if(profilePicPath!=="default")
                        {
                            profilePicName =profilePicPath.split("/")[profilePicPath.split("/").length-1]
                            uploadFile(profilePicPath,"profilepic",username)

                        }


                        usersListModel.append({username:username,completedHunts:[],avatarSrc:profilePicName,points:0})
                        socket.getSocketUri(username)
                        // reloadModels()
                    }
                })
            }
        })
    }






    /*
     * uploadFile
     *
     * creates an object in the database. object must be a json format
     *
     * @param var object, string objectType : object created under an objectType collection
     *
     *
     */
    function uploadFile(fileUrl,type,info)
    {
        var splitUrl = fileUrl.split("/")
        var fileName = splitUrl[splitUrl.length - 1]
        var fileObject = {}
        if(type==="profilepic")
        {
            fileObject = {
                objectType : "objects.images",
                name: fileName,
                view:0,
                type:"profilepic",
                username:info
            }
        }
        else if(type==="challengepic")
        {
            //console.log(info.huntName)
            fileObject = {
                objectType : "objects.images",
                name: fileName,
                view:0,
                type:"challengepic",
                huntName:info.huntname,
                challengeName:info.challengeName,
                location: info.location,
                username:info.username
            }
        }
        var reply = client.create(fileObject)
        reply.finished.connect(function(){
            if(!reply.isError)
            {
                var id = reply.data.id
                var uploadData = {
                    file:{
                        fileName:fileName
                    },
                    targetFileProperty: {
                        objectType: "objects.images",
                        id:id,
                        propertyName: "file"
                    },
                }
                var uploadReply = client.uploadFile(uploadData, fileUrl)
                uploadReply.finished.connect(function(){
                    if(uploadReply.isError)
                    {
                        console.log("Error")
                        console.log(uploadReply.errorString)
                    }
                    else
                    {
                        net.removeFile(fileUrl)
                    }
                })
            }
        })
    }


    /*
     * createObject
     *
     * creates an object in the database. object must be a json format
     *
     * @param var object, string objectType : object created under an objectType collection
     *
     *
     */
    function createObject(objectToCreate,objectType,callBack)
    {
        objectToCreate.objectType = "objects."+objectType
        var reply=client.create(objectToCreate)
        reply.finished.connect(function(){
            if(!reply.isError)
            {
                callBack(reply)
            }
        })

    }

    function loadProfilePic(){
        var queryReply = client.query({"objectType":"objects.images","query":{"type":"profilepic","username":username}})
        queryReply.finished.connect(function(){
            if(!queryReply.isError)
            {

                var data = queryReply.data.results[0]

                var downloadReply = client.downloadUrl({id:data.file.id})
                downloadReply.finished.connect(function() {
                    if(!downloadReply.isError)
                    {
                        var url = downloadReply.data.expiringUrl
                        //net.saveFile(url)
                        //userSpace.profile.profilePicture.picture.source = url
                    }
                    else
                    {
                        console.log(downloadReply.errorString)
                    }
                })
            }
            else
            {
                console.log(queryReply.errorString)
            }
        })
    }

    /*
     * updateObject
     *
     * updates an object in the database. object must be a json format
     *
     * @param var object, string objectType : object updated under an objectType collection
     *
     *
     */
    function updateObject(object,objectType)
    {
        var objectToUpdate = object
        objectToUpdate.objectType = "objects."+objectType
        var reply = client.update(objectToUpdate)
        reply.finished.connect(function(){
            if(!reply.isError)
            {
                if(objectType === "activeGames")
                {
                    userGamesListModel.load()
                }
            }
            else
            {
                console.log(reply.errorString)
            }
        })
    }

    /*
     * deleteObject
     *
     * deletes an object from the database. object must be a json format
     *
     * @param var object, string objectType : object deleted from objectType collection
     *
     *
     */
    function deleteObject(object,objectType)
    {
        var objectToDelete = object
        objectToDelete .objectType = "objects."+objectType
        var reply = client.create(objectToDelete)
        reply.finished.connect(function(){
            if(!reply.isError)
            {

            }
        })
    }

    function atomicUpdate(id,objectType,data,callback)
    {
        var xhr = new XMLHttpRequest();
        var url = "https://api.engin.io/v1/objects/"+objectType+"/"+id+"/atomic"
        xhr.onreadystatechange = function() {
            if ( xhr.readyState == xhr.DONE)
            {
                // console.log("Success " + xhr.responseText + " STATUS " + xhr.status)
                if ( xhr.status == 200)
                {
                    var jsonObject = JSON.parse(xhr.responseText); // Parse Json Response from http request
                    // console.log("Success " + jsonObject.balance)
                    callback(jsonObject.id)
                }
            }
        }
        xhr.open("PUT",url,true);

        xhr.setRequestHeader("Enginio-Backend-Id",client.backendId)
        xhr.send(JSON.stringify(data))
    }

    /*
     * getUserGroupMembers
     *
     * query database for members of user's group
     * search only valid is user belongs to a group
     *
     */
    function getUserGroupMembers()
    {
        //var groupInfo = User.getUserGroupInfo()
        var groupInfo = userGroup
        var reply= client.query({"id":groupInfo.id},Enginio.UsergroupMembersOperation)
        reply.finished.connect(function(){
            if(!reply.isError)
            {
                var data = reply.data
                //User.setUserGroupMembers(data.results)
                userGroup.members = data.results
            }
        })
    }
    //    function listUsers()
    //    {
    //        var reply = client.query({"query":"","objectType":"users"})
    //        reply.finished.connect(function(){
    //            var data = reply.data.results
    //            userSpace.listPlayers(data)
    //        })
    //    }
    /*
     * userUpdate
     *
     * update information about user
     *
     * @param var userInfo : json object that contains user new information
     */
    function userUpdate(type,update)
    {
        //if qt implements get for enginioModel, change this part to not query before update, but update by getting item 0 when usersListModel query only current user
        switch (type){
        case "completedHunts":
            var reply = client.query({"objectType":"objects.userMap","query":{"username":username}})

            reply.finished.connect(function(){
                if(!reply.isError)
                {
                    var data = reply.data.results[0]
                    data.completedHunts.push(update)
                    data.points = data.points + update.points
                    //                    myInfoModel.updateMyInfo("completedHunts",data.completedHunts)
                    //                    myInfoModel.updateMyInfo("points",data.points)
                    var updateReply =client.update(data)
                    updateReply.finished.connect(function(){
                        if(updateReply.isError)
                        {
                            console.log(updateReply.errorString)
                        }
                    })
                }
                else
                {
                    console.log(reply.errorString)
                }
            })

            break
        case "avatarSrc":
            myInfoModel.updateMyInfo("avatarSrc",update)
            break
        }

        //        var reply = client.query({"objectType":"objects.userMap","query":{"username":username}})

        //        reply.finished.connect(function(){
        //            if(!reply.isError)
        //            {
        //                var data = reply.data.results[0]
        //                switch (type){
        //                case "hunts":
        //                    data.completedHunts.push(update)
        //                    data.points = data.points + update.points

        //                    userPoints = data.points
        //                    break
        //                case "avatarSrc":
        //                    data.avatarSrc = update
        //                    break
        //                }
        //                var updateReply =client.update(data)
        //                updateReply.finished.connect(function(){
        //                    if(updateReply.isError)
        //                    {
        //                        console.log(updateReply.errorString)
        //                    }
        //                })

        //            }
        //            else
        //            {
        //                console.log(reply.errorString)
        //            }
        //        })


    }


    function getDb()
    {
        db=LocalStorage.openDatabaseSync(username, "1.0", "DB", 1000000,function(db){
            loadingStatus="gettingOnlineDb"
            var init=ObjectCreation.createObject("Init.qml",cloud,{db:db})
            init.initiated.connect(function(){
                console.log("initiated")
                db.changeVersion("", "1.0");
                reloadModels()
                noticeModel.load()
            })
        })

        if(loadingStatus==="init")
        {
            noticeModel.syncRemote()
            reloadModels()
        }
    }
}


