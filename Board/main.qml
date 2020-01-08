import QtQuick 2.12
import QtQuick.Window 2.12

Window {
    visible: true
    width: 1280
    height: 960
    Rectangle{
        id: chessBoard
        height: parent.height*0.9
        width: height
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: parent.height*0.05

        color: "#cd853f"

        Column{
            anchors.verticalCenter: chessBoard.verticalCenter
            anchors.left: chessBoard.left
            anchors.leftMargin: chessBoard.width/16
            Repeater{
                model:14
                Row{
                     Repeater{
                        model:14
                        Rectangle{
                            height: chessBoard.height/16
                            width: chessBoard.width/16
                            color: "#cd853f"
                            border.width: 1
                        }
                     }
                }
            }
        }
    }
}
