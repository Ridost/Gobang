import QtQuick 2.12
import QtQuick.Window 2.12
import "chessCreation.js" as MyScript
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.1
import com.TCPClient 1.0
import  "packetCreate.js" as Packet

Rectangle{
    property variant chessPosition : []     // -1: undefine ,0: white ,1: black
    id     : background
    width  : parent.width
    height : parent.height
    color  : "black"
    anchors.top : parent.top
    Component.onCompleted: {
        for(var i=0;i<15;i++){
           chessPosition.push([-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1])
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
        width   : parent.width
        height  : width
        color   : "#cd853f"
        anchors.verticalCenter  : parent.verticalCenter
        anchors.left            : parent.left

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
                    var str = Packet.packet("play","","",id,posX,posY)
                    console.log("Sent:" ,str)
                    tcp.sendMsg(str)
                    createChess(posX,posY)
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
        function win(posX,posY){
            var x_min = posX-4 >= 0 ? posX - 4 :  0;
            var x_max = posX+4 < 15 ? posX + 4 : 14;
            var y_min = posY-4 >= 0 ? posY - 4 :  0;
            var y_max = posY+4 < 15 ? posY + 4 : 14;
            var black_line = 0;
            var white_line = 0;
            //直
            for(var i = y_min ; i <= y_max ; i++){
                if(chessPosition[posX][i]===1)
                    black_line++;
                else
                    black_line = 0;
                if(chessPosition[posX][i]===0)
                    white_line++;
                else
                    white_line = 0;
                if(black_line===5 || white_line===5) return true;
            }
            //橫
            for(var i = x_min ; i <= x_max ; i++){
                if(chessPosition[i][posY]===1)
                    black_line++;
                else
                    black_line = 0;
                if(chessPosition[i][posY]===0)
                    white_line++;
                else
                    white_line = 0;
                if(black_line===5 || white_line===5) return true;
            }
            var temp  = (x_max-x_min) > (y_max-y_min) ?  (y_max-y_min) : (x_max-x_min);
            //左斜(\)
            for(var i = 0 ; i<=temp; i++){
                if(chessPosition[x_min+i][y_min+i]===1)
                    black_line++;
                else
                    black_line = 0;
                if(chessPosition[x_min+i][y_min+i]===0)
                    white_line++;
                else
                    white_line = 0;
                if(black_line===5 || white_line===5) return true;
            }
            //右斜(/)
            for(var i = 0 ; i<=temp; i++){
                if(chessPosition[x_min+i][y_min-i]===1)
                    black_line++;
                else
                    black_line = 0;
                if(chessPosition[x_min+i][y_min-i]===0)
                    white_line++;
                else
                    white_line = 0;
                if(black_line===5 || white_line===5) return true;
            }
            return false;
        }

        function forbidden(posX,posY){
            //首子必在天元(7,7)
            if(board_empty()){
                var str = Packet.packet("play","","",id,7,7)
                console.log("Sent:" ,str)
                tcp.sendMsg(str)
                createChess(7,7);
                return false;
            }
            //禁手(雙三、雙四、雙死四、六子)

            if(!check(posX,posY)){
                message.x = selectedframe.x
                message.y = selectedframe.y
                animation.running = true;
                return false;
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
            //cnt1-> 雙三 cnt2-> 活四 cnt3-> 六子
            var invalid_cnt1 = 0;
            var invalid_cnt2 = 0;
            var invalid_cnt3 = 0;

            var black = 0;

            var now = chessPosition[posX][posY];

            if(now!==-1) return true;
            chessPosition[posX][posY] = (currentColor=="#000000") ? 1 : 0;


            var x_min, x_max, y_min, y_max;
            //掃過棋盤每個位置 確認這手合法.

            //掃過4個方向( | - / \ )
//----------------------直向----------------------

        //================雙三判斷================
            for(var R = posY; R < posY+4 && R < 14; R++){
                black = 0;
                var L;
                for(L = R; L > R-4 && L > 0; L--){
                    if(chessPosition[posX][L]===1)
                        black++;
                    if(black===3)
                        break;
                }
                if(black===3){
                    if(chessPosition[posX][L-1]===-1 && (L-2===-1 || chessPosition[posX][L-2]!==1))
                        if(chessPosition[posX][R+1]===-1 && ( R+2===15 || chessPosition[posX][R+2]!==1))
                        {
                            invalid_cnt1++;
                            break;
                        }
                }
            }
        //===================================

        //================雙四================
            for(var R = posY; R < posY+5 && R < 14; R++){
                black = 0;
                var L;
                for(L = R; L > R-5 && L > 0; L--){
                    if(chessPosition[posX][L]===1)
                        black++;
                    if(black===4)
                        break;
                }
                if(black===4){
                    if(chessPosition[posX][L-1]===-1 && (L-2===-1 || chessPosition[posX][L-2]!==1))
                        if(chessPosition[posX][R+1]===-1 && ( R+2===15 || chessPosition[posX][R+2]!==1))
                        {
                            invalid_cnt2++;
                            break;
                        }
                }
            }

        //===================================

        //================六子================
        y_min = (posY - 5 > 0)  ? posY - 5 :  0;
        y_max = (posY + 5 < 15) ? posY + 5 : 14;
        black = 0;
        for(var i = y_min ; i<=y_max ; i++)
        {
            if(chessPosition[posX][i]===1)
                black++;
            if(black===6){
                chessPosition[posX][posY]=now;
                return false;
            }
            if(chessPosition[posX][i]!==1)
                black=0;
        }

        //===================================

//----------------------橫向----------------------
        //================雙三判斷================
            for(var R = posX; R < posX+4 && R < 14; R++){
                black = 0;
                var L;
                for(L = R; L > R-4 && L > 0; L--){
                    if(chessPosition[L][posY]===1)
                        black++;
                    if(black===3)
                        break;
                }
                if(black===3){
                    if(chessPosition[L-1][posY]===-1 && (L-2===-1 || chessPosition[L-2][posY]!==1))
                        if(chessPosition[R+1][posY]===-1 && (R+2===15 || chessPosition[R+2][posY]!==1)){
                            invalid_cnt1++;
                            break;
                        }
                }
            }

        //===================================

        //================雙四================
            for(var R = posX; R < posX+5 && R < 14; R++){
                black = 0;
                var L;
                for(L = R; L > R-5 && L > 0; L--){
                    if(chessPosition[L][posY]===1)
                        black++;
                    if(black===4)
                        break;
                }
                if(black===4){
                    if(chessPosition[L-1][posY]===-1 && (L-2===-1 || chessPosition[L-2][posY]!==1))
                        if(chessPosition[R+1][posY]===-1 && (R+2===15 || chessPosition[R+2][posY]!==1)){
                            invalid_cnt2++;
                            break;
                        }
                }
            }
        //===================================

        //================六子================
        x_min = (posX - 5 > 0)  ? posX - 5 :  0;
        x_max = (posX + 5 < 15) ? posX + 5 : 14;
        black = 0;
        for(var i = x_min ; i<=x_max ; i++)
        {
            if(chessPosition[i][posY]===1)
                black++;
            if(black===6){
                console.log("six problem!");
                chessPosition[posX][posY]=now;
                return false;
            }
            if(chessPosition[i][posY]!==1)
                black=0;
        }

        //===================================


//----------------------左斜(\)----------------------
        //================雙三判斷================
            for(var R = 0; R < 4 && posX+R < 14 && posY+R < 14; R++){
                black = 0;
                var L;
                for(L = 0; L < 4 && posX-L > 0 && posY-L > 0; L++){
                    if(chessPosition[posX+R-L][posY+R-L]===1)
                        black++;
                    if(black===3)
                        break;
                }
                if(black===3){
                    if(chessPosition[posX+R-L-1][posY+R-L-1]===-1 && ((posX+R-L-2===-1) || (posY+R-L-2===-1) || chessPosition[posX+R-L-2][posY+R-L-2]!==1))
                        if(chessPosition[posX+R+1][posY+R+1]===-1 && ((posX+R+2===15) || (posY+R+2===15) || chessPosition[posX+R+2][posY+R+2]!==1)){
                            invalid_cnt1++;
                            break;
                        }
                }
            }

        //===================================

        //================雙四================
            for(var R = 0; R < 5 && posX+R < 14 && posY+R < 14; R++){
                black = 0;
                var L;
                for(L = 0; L < 5 && posX-L > 0 && posY-L > 0; L++){
                    if(chessPosition[posX+R-L][posY+R-L]===1)
                        black++;
                    if(black===4)
                        break;
                }
                if(black===4){
                    if(chessPosition[posX+R-L-1][posY+R-L-1]===-1 && ((posX+R-L-2===-1) || (posY+R-L-2===-1) || chessPosition[posX+R-L-2][posY+R-L-2]!==1))
                        if(chessPosition[posX+R+1][posY+R+1]===-1 && ((posX+R+2===15) || (posY+R+2===15) || chessPosition[posX+R+2][posY+R+2]!==1)){
                            invalid_cnt2++;
                            break;
                        }
                }
            }
        //===================================

        //================六子================
        x_min = (posX - 5 > 0)  ? posX - 5 :  0;
        x_max = (posX + 5 < 15) ? posX + 5 : 14;
        black = 0;
        for(var i = x_min ; i<=x_max ; i++)
        {
            if(chessPosition[i][posY]===1)
                black++;
            if(black===6){
                chessPosition[posX][posY]=now;
                return false;
            }
            if(chessPosition[i][posY]!==1)
                black=0;
        }

        //===================================

//----------------------右斜(/)----------------------
        //================雙三判斷================
            for(var R = 0; R < 4 && posX+R < 14 && posY-R > 0; R++){
                black = 0;
                var L;
                for(L = 0; L < 4 && posX-L > 0 && posY+L < 14; L++){
                    if(chessPosition[posX+R-L][posY-R+L]===1)
                        black++;
                    if(black===3)
                        break;
                }
                if(black===3){
                    if(chessPosition[posX+R-L-1][posY-R+L+1]===-1 && ((posX+R-L-2===-1) || (posY-R+L+2===15) || chessPosition[posX+R-L-2][posY-R+L+2]!==1))
                        if(chessPosition[posX+R+1][posY-R-1]===-1 && ((posX+R+2===15) || (posY-R-2===-1) || chessPosition[posX+R+2][posY-R-2]!==1)){
                            invalid_cnt1++;
                            break;
                        }
                }
            }

        //===================================

        //================雙四================
            for(var R = 0; R < 5 && posX+R < 14 && posY-R > 0; R++){
                black = 0;
                var L;
                for(L = 0; L < 5 && posX-L > 0 && posY+L < 14; L++){
                    if(chessPosition[posX+R-L][posY-R+L]===1)
                        black++;
                    if(black===4)
                        break;
                }
                if(black===4){
                    if(chessPosition[posX+R-L-1][posY-R+L+1]===-1 && ((posX+R-L-2===-1) || (posY-R+L+2===15) || chessPosition[posX+R-L-2][posY-R+L+2]!==1))
                        if(chessPosition[posX+R+1][posY-R-1]===-1 && ((posX+R+2===15) || (posY-R-2===-1) || chessPosition[posX+R+2][posY-R-2]!==1)){
                            invalid_cnt2++;
                            break;
                        }
                }
            }
        //===================================

        //================六子================
        x_min = (posX - 5 > 0)  ? posX - 5 :  0;
        x_max = (posX + 5 < 15) ? posX + 5 : 14;
        black = 0;
        for(var i = x_min ; i<=x_max ; i++)
        {
            if(chessPosition[i][posY]===1)
                black++;
            if(black===6){
                chessPosition[posX][posY]=now;
                return false;
            }
            if(chessPosition[i][posY]!==1)
                black=0;
        }

        //===================================

//--------------------------------------------------

            chessPosition[posX][posY]=now;
            //invalid_cnt judge in here.
            if(invalid_cnt1 >= 2){
                return false;
            }
            if(invalid_cnt2 >1){
                return false;
            }
            return true;
        }
        //end of check()
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

}

