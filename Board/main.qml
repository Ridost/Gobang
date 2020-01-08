import QtQuick 2.12
import QtQuick.Window 2.12

Window {
    visible: true
    width   : 1280
    height  : 960

    Rectangle{
        id: chessBoard
        height  : parent.height*0.9
        width   : height
        color   : "#cd853f"
        anchors.verticalCenter  : parent.verticalCenter
        anchors.left            : parent.left
        anchors.leftMargin      : parent.height*0.05

        Column{
            anchors.verticalCenter  : chessBoard.verticalCenter
            anchors.left            : chessBoard.left
            anchors.leftMargin      : chessBoard.width/16
            Repeater{
                model:14
                Row{
                     Repeater{
                        model:14
                        Rectangle{
                            height      : chessBoard.height/16
                            width       : chessBoard.width/16
                            color       : "#cd853f"
                            border.width: 1
                        }
                     }
                }
            }
        }

        SelectedFrame{
            id: selectedframe
            border  : 2
            x       : chessBoard.width  *1.5/16
            y       : chessBoard.height *1.5/16
            height  : chessBoard.height/16
            width   : chessBoard.width/16

        }

        MouseArea{
            id:mouse
            hoverEnabled        : true
            anchors.fill        : parent
            onPositionChanged   : relocation()
            onClicked: {
                console.log("position: ",mouseX,",",mouseY)
            }
            function relocation(){
                var framewidth  = chessBoard.width /16
                var frameheight = chessBoard.height/16
                selectedframe.x = Math.floor(((mouse.mouseX - framewidth /2)   / framewidth   ))  * framewidth  + framewidth /2
                selectedframe.y = Math.floor(((mouse.mouseY - frameheight/2)   / frameheight  ))  * frameheight + frameheight/2
            }
        }
    }
}
