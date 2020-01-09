
var component;
var chess;
var chessList = [];

function createChess( position_X, position_Y , color) {
    component   = Qt.createComponent("Chess.qml")
    chess       = component.createObject(chessBoard)
    if(chess == null){
        console.log("Error Create Chess");
    }else{
        chess.x = Qt.binding( function(){ return chessBoard.width * (1+position_X)/16 - chessBoard.width /32})
        chess.y = Qt.binding( function(){ return chessBoard.height* (1+position_Y)/16 - chessBoard.height/32})
        chess.color = color
        chessList.push(chess);
    }
}

function deleteAllChess(){
    for(var i = 0 ;i<chessList.length;i++){
        chessList[i].destroy();
    }
    chessList = [];
}

