
var component;
var chess;

function createChess( position_X, position_Y , color) {
    component   = Qt.createComponent("Chess.qml")
    chess       = component.createObject(chessBoard)
    if(chess == null){
        console.log("Error Create Chess");
    }else{
        chess.x = position_X
        chess.y = position_Y
        chess.color = color
    }
}
