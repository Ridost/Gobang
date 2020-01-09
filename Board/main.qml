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
                    if( obj['table']['player1'] === username)   myColor = "black"
                    else myColor = "white"
                    game.start()
                    break;
                case "playing":
                    console.log(obj['table']['turn'],currentColor)
                    if(obj['table']['turn'] === "white" && currentColor == "#000000"){
                        var posX = obj['table']['lastx']
                        var posY = obj['table']['lasty']
                        pageloader.item.createChess(posX,posY)
                        currentColor = "white"
                        console.log("create1")
                    }else if(obj['table']['turn'] === "black" && currentColor == "#ffffff"){
                        var posX = obj['table']['lastx']
                        var posY = obj['table']['lasty']
                        console.log("create2")
                        pageloader.item.createChess(posX,posY)
                        currentColor = "black"
                    }
                    if(obj['table']['turn'] !== myColor){
                       // main.active = false
                        waiting.start()
                    }//else main.active = true
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
