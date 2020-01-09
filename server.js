var net = require('net')
var mysql = require('mysql');
var con = mysql.createConnection({
    host: "localhost",
    user: "root",
    password: "password",
    database: "Gobang"
  });

var waiting_queue = []
var online_players = {}
var tableid = 0
var all_table = {}
/*
var table = {
    player1 : "",   //first (username)
    player2 : "",
    forfeit : "",
    turn : "",
    lastx : 0,
    lasty : 0,
    board : []
}
*/
//board init
var clean_board =[]
for(var i=0; i<15; i++){
    var arr=[]
    for(var c=0; c<15; c++)
        arr.push(c)
    clean_board.push(arr)
}
var server = net.createServer()

//sql connect
con.connect(function(err) {
    if (err) throw err;
});

server.listen(8888, ()=>{
    console.log("server start")
})

server.on('connection', (socket)=>{
    
    console.log("connection start")
    

    socket.on('data', (data)=>{

        
        var send_pack = {}

        var recv_pack = JSON.parse(data)
        //console.log(recv_pack)
        switch(recv_pack["type"]){

            case "register" : 
                register()
                break

            case "login" :
                login()
                break

            case "pairing" :
                pairing()
                break

            case "unpairing":
                unpairing()
                break

            case "idle" :
                idle()
                break
            
            case "play" :
                play()
                break

            case "wait" :
                wait()
                break

            case "forfeit" :
                forfeit()
                break
            
            case "gameover" :
                gameover()
                break;
        }

        function register () {
            var send_pack = {}
            // unique test
            var test = "SELECT username FROM User WHERE username='" + recv_pack["username"] + "'"
            con.query(test, function (err, dup_test, fields) {
                if (dup_test[0] == undefined){
                    send_pack.type = "FAIL"
                    socket.write(JSON.stringify(send_pack), ()=>{console.log("register fail")})
                    return 
                }
            });
            // OK
            var sql = "INSERT INTO User (Username, Password) VALUES ('" + recv_pack["username"] + "','" + recv_pack["password"] + "')";
            try {
                con.query(sql, (err, result)=>{
                    if (err) throw err
                    console.log("data inserted")
                    send_pack.type = "OK"
                    socket.write(JSON.stringify(send_pack), ()=>{console.log("register ok")})  
                });
            } catch (error) {
                console.log(error)
                send_pack.type = "FAIL"
                socket.write(JSON.stringify(send_pack), ()=>{console.log("register fail")})  
            }
        }
    
        function login () {
            var player = {}
            var send_pack = {}
            var sql = "SELECT id,username,password FROM User WHERE username='" + recv_pack["username"] + "' AND password='" + recv_pack["password"] + "'"
    
            try {
                con.query(sql, (err, result, fields)=>{
                    if (result[0] == undefined)  //query fail
                        send_pack.type = "FAIL"
                        
                    else if (recv_pack["username"] == result[0].username && recv_pack["password"] == result[0].password) {
                        player.name = result[0].username
                        player.state = "online"
                        online_players[result[0].id] = player

                        send_pack.type = "OK"
                        send_pack.id = result[0].id
                    }
                    else send_pack.type = "FAIL"

                    socket.write(JSON.stringify(send_pack), ()=>{ console.log( recv_pack["username"] + " login ok") })
                });
            } catch (error) {
                console.log("login failed")
                send_pack.type = "FAIL"
                socket.write(JSON.stringify(send_pack), ()=>{console.log("login fail")})
            }
            
        }

        function pairing (){
            var table = {}
            var id = recv_pack["id"]
            var states = online_players[id].state
            
            if(!isNaN(states)){
                send_pack.type = "start"
                send_pack.table = all_table[states]
                socket.write(JSON.stringify(send_pack), ()=>{console.log( online_players[id].name + " starting")})
            }
            else {
                if(states == "online"){
                    waiting_queue.push(id)
                    online_players[id].state = "waiting"
                }
                if( waiting_queue.length >= 2 ){
                    waiting_queue.splice(waiting_queue.indexOf(id),1)
                    table.player1 = online_players[id].name
                    var player2_id=waiting_queue.shift()
                    table.player2 = online_players[player2_id].name
                    table.turn = "black"
                    //for both win check
                    table.check = true
                    //init board
                    //table.board = clean_board
                    all_table[tableid] = table
                    //set player state
                    online_players[player2_id].state = tableid
                    online_players[id].state = tableid

                    send_pack.type = "start"
                    send_pack.table = all_table[tableid]
                    socket.write(JSON.stringify(send_pack), ()=>{console.log( online_players[id].name + " starting")})
                    
                    tableid += 1 
                }
                else {
                    send_pack.type = "pairing"
                    socket.write(JSON.stringify(send_pack), ()=>{console.log( online_players[id].name + " is pairing")})              
                }
            }
        }

        function unpairing(){
            if( waiting_queue.find(id=>id == recv_pack["id"]) != undefined ){
                waiting_queue.splice(waiting_queue.indexOf(recv_pack["id"]),1)
                online_players[recv_pack["id"]].state = "online"
            }
            send_pack.type = "unpairing"
            socket.write(JSON.stringify(send_pack), ()=>{console.log( recv_pack["username"]+ " unpairing success")})
        }
        //black = player1 .....
        function idle () {
            var id = recv_pack["id"]
            var tid =online_players[id].state
            send_pack.table = all_table[tid]
            send_pack.type = "playing"
            socket.write(JSON.stringify(send_pack), ()=>{/*console.log( online_players[id].name + " is idle")*/})
        }

        function play () {
            var id = recv_pack["id"]
            var tid = online_players[id].state
            all_table[tid].lastx=recv_pack.x
            all_table[tid].lasty=recv_pack.y
            //all_table[tid].board[recv_pack.x][recv_pack.y] = all_table[tid].turn == "BLACK" ? 1 : 0
            all_table[tid].turn = all_table[tid].turn == "black" ? "white" : "black"
            send_pack.table = all_table[tid]
            send_pack.type = "playing"
            socket.write(JSON.stringify(send_pack), ()=>{console.log( online_players[id].name + " is play")})
        }

        function forfeit () {
            var id = recv_pack["id"]
            var tid = online_players[id].state
            all_table[tid].forfeit = online_players[id].name
            send_pack.table = all_table[tid]
            send_pack.type = "forfeit"
            socket.write(JSON.stringify(send_pack), ()=>{console.log( online_players[id].name + " forfeit")})
        }

        function gameover () {
            var id = recv_pack["id"]
            var tid = online_players[id].state
            all_table[tid].check = !all_table[tid].check
            online_players[id].state = "online"
            if( all_table[tid] != undefined && all_table[tid].check)
                delete all_table[tid]
            send_pack.type = "gameover"
            socket.write(JSON.stringify(send_pack), ()=>{console.log( "Game over" )})
            console.log(waiting_queue.length)
        }
    })

    socket.on('end',function(){
        console.log("connection close")
    })

    
})