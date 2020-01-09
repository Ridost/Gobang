import QtQuick 2.0

Rectangle {
    color   : "gray"
    opacity : 0.7
    Text{
        id      : username
        width   : parent.width * 0.7
        height  : parent.height * 0.5
        font.bold       : true
        font.pointSize  : 100
        fontSizeMode    : Text.Fit
        text            : ""
        horizontalAlignment : Text.AlignHCenter
        verticalAlignment   : Text.AlignVCenter
        anchors.top         : parent.top
        anchors.horizontalCenter: parent.horizontalCenter
    }
    function setUserName(name){
        username.text = name
    }
}
