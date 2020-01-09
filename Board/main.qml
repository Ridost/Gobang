import QtQuick 2.12
import QtQuick.Window 2.12
import "chessCreation.js" as MyScript
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.1
import com.TCPClient 1.0

Window {
    property color currentColor: "black"
    property variant chessPosition : []     // -1: undefine ,0: white ,1: black
    visible : true
    width   : 1280
    height  : 960
    Component.onCompleted: {
        for(var i=0;i<15;i++){
           chessPosition.push([-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1])
        }
    }
    TCP{
        id:tcp
    }
    Button{
        text : "Connect"
        onClicked: {
            tcp.createTCPConnect()
            tcp.sendMsg("123")
        }
    }
    Button{
        anchors.left: chessBoard.right
        anchors.top : chessBoard.top
        text : "DeleteAllChess"
        onClicked: {
            MyScript.deleteAllChess()
            for(var i=0 ; i<15 ; i++){
                for(var j =0 ; j<15 ; j++)
                    chessPosition[i][j] = -1;
            }
            currentColor = "black"
        }
    }
    Rectangle{
        id  : message
        width: chessBoard.width/8
        height: chessBoard.height/36
        opacity: 0.7
        state: "Close"
        color: "coral"
        x : chessBoard.x + chessBoard.width/2
        y : chessBoard.y + chessBoard.height/2
        z : 0
        Text{
            text: "不能下這裡啦"
            font.bold: true
            font.pointSize: 10
            color: "black"
        }
        PropertyAnimation{
            id : animation
            target: message
            duration:  3000
            property: "z";
            from : 30;
            to   : 0;
        }
    }

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
            height  : chessBoard.height/16
            width   : chessBoard.width/16

        }
        MouseArea{
            id:mouse
            hoverEnabled        : true
            anchors.fill        : parent
            onPositionChanged   : relocation()
            onClicked           : {
                var posX = Math.round( (selectedframe.x+(chessBoard.width/32 )) / (chessBoard.width /16)) -1
                var posY = Math.round( (selectedframe.y+(chessBoard.height/32)) / (chessBoard.height/16)) -1
                if(chessBoard.forbidden(posX,posY)){
                    chessBoard.createChess(posX,posY)
                }
            }
            function relocation(){
                var mouse_x     = mouse.mouseX
                var mouse_y     = mouse.mouseY
                var framewidth  = chessBoard.width /16
                var frameheight = chessBoard.height/16

                if(mouse_x >= chessBoard.width*15/16)   mouse_x = chessBoard.width*15/16
                else if(mouse_x <= chessBoard.width/16) mouse_x = chessBoard.width/16

                if(mouse_y >= chessBoard.height*15/16)  mouse_y = chessBoard.height*15/16
                else if(mouse_y <= chessBoard.height/16)mouse_y = chessBoard.height/16

                selectedframe.x = Math.floor(((mouse_x - framewidth /2)   / framewidth   ))  * framewidth  + framewidth /2
                selectedframe.y = Math.floor(((mouse_y - frameheight/2)   / frameheight  ))  * frameheight + frameheight/2

            }
        }

        function createChess(posX,posY){
            if(chessPosition[posX][posY]===-1 ){
                chessPosition[posX][posY] = (currentColor=="#000000") ? 1 : 0
                MyScript.createChess(posX, posY, currentColor)
                currentColor = (currentColor=="#000000") ? "white" : "black"
            }else{
                console.log("There has been a chess")
            }
        }

        function forbidden(posX,posY){
            //首子必在天元(7,7)
            if(board_empty()){
                createChess(7,7);
                return false;
            }
            //禁手(雙三、雙四、雙死四、六子)
            for(var i = 0; i<4 ; i++){
                if(!check(i,posX,posY)){
                    message.x = selectedframe.x
                    message.y = selectedframe.y
                    animation.running = true;
                    return false;
                }
            }

            return true;
        }

        function board_empty(){
            for(var i=0 ; i<15 ; i++){
                for(var j =0 ; j<15 ; j++)
                    if(chessPosition[i][j]!==-1)
                        return false;
            }
            return true;
        }
        function check(way,posX,posY){
            switch (way){
            case 0: //雙三
                //直
                var invalid_cnt = 0;
                var prev_state = chessPosition[posX][0];
                for(var i = 1; i < 14; i++){
                    if(chessPosition[posX][i]===1 && prev_state > 0 ){
                        prev_state++;

                    }
                    else if(prev_state===-1 &&　chessPosition[posX][i]){
                        prev_state = 1;
                    }
                    else if(chessPosition[posX][i]!==1){
                        prev_state = chessPosition[posX][i];
                    }
                    if(prev_state === 3) invalid_cnt++;
                }
                if(invalid_cnt===1){
                    console.log("INVAILD MTFK!");
                    return false;
                }
                return true;
                break;
            case 1: //雙四
                return true;
                break;
            case 2: //雙死四
                return true;
                break;
            case 3: //六子
                return true;
                break;
            }
        }
    }
}
