import QtQuick 2.0


Item {
    property var db
    property int  loadingProgress: 0

    signal initiated

    // property alias con:con
    onLoadingProgressChanged: {
        switch(loadingProgress)
        {
        case 40:
            initiated()
            break
        case 50:
            break
        case 75:
            break
        case 100:
            break
        }
    }

    function getInfo(){
        var reply=cloud.client.query({"objectType":"objects.userMap",query:{"username":cloud.username}})
        reply.finished.connect(function(){
            if(reply.isError)
            {
                console.log(reply.errorString)
            }
            var info=reply.data.results[0]
            db.transaction(
                        function(tx) {
                            tx.executeSql('INSERT INTO UserInfo(username, points, avatarSrc) VALUES(?, ?, ?)', [ info.username, info.points, info.avatarScr]);
                            loadingProgress+=10
                        }
                        )
        })
    }
    function getNotices(){
        var reply=cloud.client.query({"objectType":"objects.notice",query:{"players":cloud.username}})
        reply.finished.connect(function(){
            var results=reply.data.results
                db.transaction(
                            function(tx) {
                                for(var i=0;i<results.length;i++)
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
                                loadingProgress+=10
                            })
        })
    }

    function getMessages(){
        var reply=cloud.client.query({"objectType":"objects.messages",query:{"players":cloud.username}})
        reply.finished.connect(function(){
            var results=reply.data.results
                db.transaction(
                            function(tx) {
                                for(var i=0;i<results.length;i++)
                                {
                                    var messages=results[i].messages
                                    results[i].players.splice(results[i].players.indexOf(cloud.username),1)
                                    var ret=tx.executeSql('INSERT OR IGNORE INTO Notification(players , read,remote_id) VALUES(?, ?,?)', [ results[i].players.toString(), 1,results[i].id]);
                                    var ret1
                                    var msg
                                    for(var j=0;j<messages.length;j++)
                                    {
                                        msg=messages[j]
                                        //                    // Add (another) greeting row
                                        ret1=tx.executeSql('INSERT INTO Messages(message, player,createdAt,notification_id) VALUES(?,?,?,?)', [msg.message, msg.player,msg.createdAt,ret.insertId]);
                                    }
                                }
                                loadingProgress+=10
                            })

        })
    }

    function getActiveGames(){
        var reply=cloud.client.query({"objectType":"objects.activeGames", "query":{"players":cloud.username,},"sort":[{"sortBy":"updatedAt","direction":"desc"}]})
        reply.finished.connect(function(){
            var results=reply.data.results
                db.transaction(
                            function(tx) {
                                for(var i=0;i<results.length;i++)
                                {
                                    var game=results[i]
                                    var challenges=game.challenges
                                    var completedChallenges=game.completedChallenges
                                    var ret=tx.executeSql('INSERT OR IGNORE INTO Activegames(name ,players, points , progress , type, remote_id ) VALUES(?,?, ?, ?,?,?)', [game.name,game.players.toString(), game.points,game.progress,game.type,game.id]);

                                    //update completed challenges
                                    for(var j=0;j<completedChallenges.length;j++)
                                    {
                                        var challenge=completedChallenges[j]
                                        tx.executeSql('INSERT INTO CompletedChallenges(name, points, type, location, result,activegame_id) VALUES(?, ?, ?,?,?,?)', [challenge.name,challenge.points,challenge.type,JSON.stringify(challenge.location),challenge.result,ret.insertId]);
                                    }

                                    //update active challenges
                                    if(game.type==="scavanger hunt")
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
                                    else if (game.type==="tag")
                                    {

                                    }
                                    else if (game.type==="tour")
                                    {

                                    }
                            }
                            })
            loadingProgress+=10
        })
    }

    function makeDb(){
        db.transaction(
                    function(tx) {
                        tx.executeSql('CREATE TABLE IF NOT EXISTS UserInfo(username TEXT, points INTEGER, avatarSrc TEXT)');
                        tx.executeSql('CREATE TABLE IF NOT EXISTS Notice(notice_id INTEGER PRIMARY KEY ASC, message TEXT,players TEXT, type TEXT, read INTEGER,remote_id TEXT UNIQUE)');
                        tx.executeSql('CREATE TABLE IF NOT EXISTS Notification(notification_id INTEGER PRIMARY KEY ASC, players TEXT, read INTEGER,remote_id TEXT UNIQUE)');
                        tx.executeSql('CREATE TABLE IF NOT EXISTS Messages(message_id INTEGER PRIMARY KEY ASC, message TEXT, player TEXT, createdAt TEXT, notification_id INTEGER)');

                        tx.executeSql('CREATE TABLE IF NOT EXISTS Activegames(activegame_id INTEGER PRIMARY KEY ASC, name TEXT, players TEXT, points INTEGER, progress REAL, type TEXT, remote_id TEXT UNIQUE)');
                        tx.executeSql('CREATE TABLE IF NOT EXISTS Challenges(challenge_id INTEGER PRIMARY KEY ASC,name TEXT, type TEXT, clue TEXT, arrival TEXT, location TEXT, trivia TEXT,activegame_id INTEGER)');
                        tx.executeSql('CREATE TABLE IF NOT EXISTS CompletedChallenges(completedchallenge_id INTEGER PRIMARY KEY ASC,name TEXT, points INTEGER, type TEXT, location TEXT, result TEXT,activegame_id INTEGER)');


                        getInfo()
                        getMessages()
                        getNotices()
                        getActiveGames()
                    })
    }
    Component.onCompleted: makeDb()
}




