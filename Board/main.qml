import QtQuick 2.12
import QtQuick.Window 2.12
import "chessCreation.js" as MyScript
import QtQuick.Controls 2.0
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
        onClicked: {
            tcp.createTCPConnect()
            tcp.sendMsg("123")
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
            var color = chessPosition[posX][posY] = (currentColor=="#000000") ? 1 : 0;
            console.log(color);
            if(color){
                if(!check(posX,posY)){
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

        function check(posX,posY){
            //cnt1-> 活三 cnt2-> 活四 cnt3-> 死四 cnt4->六子
            var invalid_cnt1 = 0;
            var invalid_cnt2 = 0;
            var invalid_cnt3 = 0;
            var invalid_cnt4 = 0;
            for(var way = 0;way<4;way++){
                switch (way){

                    case 0: //直
                        var prev_state = chessPosition[posX][0];
                        var black_line = 0;
                        var now = chessPosition[posX][posY];
                        chessPosition[posX][posY] = 1;


                        for(var i = 1; i < 14; i++){
                            if(chessPosition[posX][i] === 1){
                                black_line++;
                                console.log("黑子數:",black_line);
                            } //黑子連續個數

                            if(chessPosition[posX][i] === 0){
                                black_line = 0;
                            }

                            prev_state = chessPosition[posX][i];

                            if(black_line === 3) invalid_cnt1++;
                            if(black_line === 4) invalid_cnt2++;
                            if(black_line === 6) invalid_cnt4++;
                        }

                        chessPosition[posX][posY] = now;
                        break;

                    case 1: // 橫
                        break;

                    case 2: // 斜(\)
                        break;
                    case 3: // 斜(/)
                        break;
                }
            }
            //invalid_cnt judge in here.
            if(invalid_cnt4) console.log("有六子");
            if(invalid_cnt1) console.log("有活三");
            return true;
        }
    }
}
