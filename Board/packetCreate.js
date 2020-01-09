
function packet(type,account,password,id,x,y){
    var packet = {
        "type"     : type,
        "username" : account,
        "password" : password,
        "id"       : id,
        "x"        : x,
        "y"        : y
    }
    return JSON.stringify(packet)
}
