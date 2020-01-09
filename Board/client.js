var net = require('net')
var arr = [10,20]
var test = {
    "uname" : "a123456",
    "pass" : "23456"
}
var client = net.connect(8888,function(){
    console.log("client connecting")
})
client.on('connect',function(){
    client.write(JSON.stringify(test),function(){console.log("send data")})
    console.log("on connect")
})
client.on('data',function(data){
    //client.read(JSON.parse(data),function(){console.log()})
    var d = JSON.parse(data)
    console.log("get data : "+ d["uname"])
    client.end()
})