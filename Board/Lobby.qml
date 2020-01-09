import QtQuick 2.0
import QtQuick.Controls 2.12
import com.TCPClient 1.0
import "packetCreate.js" as Packet

Rectangle{
    id     : background
    width  : parent.width
    height : parent.height
    color  : "white"
    anchors.top : parent.top

    Column {
        id     : lobbyPage
        width  : parent.width
        height : parent.height
        anchors.top       : parent.top
        spacing           : parent.height / 16

        Rectangle{
            id    : title
            width : parent.width
            height: parent.height * 0.2
            color : "lightsteelblue"
            Text{
                text  : "Lobby"
                width : parent.width
                height: parent.height
                fontSizeMode    : Text.Fit
                font.pointSize  : 100
                anchors.centerIn   : parent
                verticalAlignment  : Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Button{
            id  : start
            text: "Start"
            font.bold: true
            font.pointSize: 15
            width    : lobbyPage.width  * 0.8
            height   : lobbyPage.height * 0.05

            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                if(start.text == "Start"){
                    var str = Packet.packet("pairing",username,"",id)
                    tcp.sendMsg(str)
                    start.text = "Pairing"
                }
                else if(start.text == "Pairing"){
                    var str = Packet.packet("unpairing",username,"",id)
                    tcp.sendMsg(str)
                    start.text = "Start"
                }
            }
        }
        Button{
            id  : exit
            text: "Exit"
            font.bold: true
            font.pointSize: 15
            width    : lobbyPage.width  * 0.8
            height   : lobbyPage.height * 0.05

            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                Qt.quit()
            }
        }
    }
}
