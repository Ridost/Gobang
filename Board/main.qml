import QtQuick 2.12
import QtQuick.Window 2.12
import "chessCreation.js" as MyScript
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.1
import com.TCPClient 1.0
import "packetCreate.js" as Packet

Window {
    property var id
    property var username
    property var myColor
    property color currentColor : "black"
    property var myname
    property var othername

    id : main
    width   : 1280
    height  : 960
    visible : true
    color   : "green"

    Timer{
        id          : reconnect
        repeat      : false
        interval    : 3000
        onTriggered : tcp.createTCPConnect()
    }
    Timer{
        id          : pair
        repeat      : false
        interval    : 3000
        onTriggered : {
            console.log("pairing")
            var str = Packet.packet("pairing",username,"",id)
            tcp.sendMsg(str)
        }
    }
    Timer{
        id          : game
        repeat      : false
        interval    : 1000
        onTriggered : {
            console.log("game")
            var str = Packet.packet("idle",username,"",id)
            tcp.sendMsg(str)
        }
    }
    Timer{
        id          : waiting
        repeat      : false
        interval    : 1000
        onTriggered : {
            console.log("waiting")
            var str = Packet.packet("idle",username,"",id)
            tcp.sendMsg(str)
        }
    }
    Timer{
        id          : exiting
        repeat      : false
        interval    : 3000
        onTriggered: {
            pageloader.source = "Lobby.qml"
        }
    }
    TCP{
        id : tcp
        Component.onCompleted: {
            tcp.createTCPConnect()
        }
        onConnectFailed: {
            busy.running = true;
            reconnect.start()
        }
        onConnectSuccess: busy.running = false
        onShowMsg: {
            console.log(msg)
            var obj = JSON.parse(msg)
            var type = obj['type'];
            switch(type){
                case "OK":
                    id = obj['id'];
                    console.log(id);
                    pageloader.source = "Lobby.qml"
                    break;
                case "pairing":
                    busy.running = true
                    pair.start()
                    break;
                case "unpairing":
                    busy.running = false
                    pair.stop()
                    break;
                case "start":
                    busy.running = false
                    pageloader.source = "ChessBoard.qml"
                    if( obj['table']['player1'] === username)   {
                        player1.setUserName(username)
                        player2.setUserName(obj['table']['player2'])
                        myname = username
                        othername = obj['table']['player2']
                        myColor = "black"
                    }
                    else {
                        player1.setUserName(username)
                        player2.setUserName(obj['table']['player1'])
                        myname = username
                        othername = obj['table']['player1']
                        myColor = "white"
                    }
                    game.start()
                    break;
                case "playing":
                    console.log(obj['table']['turn'],currentColor)
                    if(obj['table']['turn'] === "white" && currentColor == "#000000"){
                        var posX = obj['table']['lastx']
                        var posY = obj['table']['lasty']
                        pageloader.item.createChess(posX,posY)
                        if( pageloader.item.win(posX,posY) ) {
                            var str = Packet.packet("gameover","","",id,posX,posY)
                            tcp.sendMsg(str)
                            pageloader.item.overgame()
                        }
                        currentColor = "white"
                    }else if(obj['table']['turn'] === "black" && currentColor == "#ffffff"){
                        var posX = obj['table']['lastx']
                        var posY = obj['table']['lasty']
                        pageloader.item.createChess(posX,posY)
                        if( pageloader.item.win(posX,posY) ) {
                            var str = Packet.packet("gameover","","",id,posX,posY)
                            tcp.sendMsg(str)
                            pageloader.item.overgame()
                        }
                        currentColor = "black"
                    }
                    if(obj['table']['turn'] !== myColor){
                        pageloader.item.setMouse(false)
                        player1.opacity = 0.9
                        player2.opacity = 0.4
                        waiting.start()
                    }else {
                        player1.opacity = 0.4
                        player2.opacity = 0.9
                        pageloader.item.setMouse(true)
                    }
                    break;
                case "gameover":
                    pageloader.item.overgame()
                    exiting.start()
                    break;
                default:
                    break;

            }
        }
    }
    BusyIndicator{
        id    : busy
        z     : 1
        width : parent.width /10
        height: parent.height/10
        anchors.centerIn: parent
        running         : false
    }
    Loader  {
        id    : pageloader
        width : parent.width * 0.7
        height: parent.height

        anchors.top : parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        source : "Login.qml"
    }
    PlayerCard{
        id    : player1
        width : parent.width * 0.15
        height: parent.height
        anchors.top : parent.top
        anchors.left: parent.left
    }


    PlayerCard{
        id    : player2
        width : parent.width * 0.15
        height: parent.height

        anchors.top  : parent.top
        anchors.right: parent.right
    }
}
