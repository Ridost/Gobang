import QtQuick 2.0

Rectangle {
    id      : playerCard
    color   : "gray"
    opacity : 0.7
    Text{
        id      : username
        width   : parent.width * 0.7
        height  : parent.height * 0.5
        font.bold       : true
        font.pointSize  : 100
        fontSizeMode    : Text.Fit
        horizontalAlignment : Text.AlignHCenter
        verticalAlignment   : Text.AlignVCenter
        anchors.top         : parent.top
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
