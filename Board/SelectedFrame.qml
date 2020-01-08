import QtQuick 2.0


Item {
    property int border : 2
    Rectangle{
        color   : "red"
        width   : parent.width*0.25
        height  : parent.border
        anchors.top     : parent.top
        anchors.left    : parent.left
    }
    Rectangle{
        color   : "red"
        width   : parent.width*0.25
        height  : parent.border
        anchors.top     : parent.top
        anchors.right   : parent.right
    }
    Rectangle{
        color   : "red"
        width   : parent.border
        height  : parent.height*0.25
        anchors.top     : parent.top
        anchors.left    : parent.left
    }
    Rectangle{
        color   : "red"
        width   : parent.border
        height  : parent.height*0.25
        anchors.top     : parent.top
        anchors.right   : parent.right
    }

    Rectangle{
        color   : "red"
        width   : parent.border
        height  : parent.height*0.25
        anchors.left    : parent.left
        anchors.bottom  : parent.bottom
    }
    Rectangle{
        color   : "red"
        width   : parent.border
        height  : parent.height*0.25
        anchors.right   : parent.right
        anchors.bottom  : parent.bottom
    }
    Rectangle{
        color   : "red"
        width   : parent.width*0.25
        height  : parent.border
        anchors.left    : parent.left
        anchors.bottom  : parent.bottom
    }
    Rectangle{
        color   : "red"
        width   : parent.width*0.25
        height  : parent.border
        anchors.right   : parent.right
        anchors.bottom  : parent.bottom
    }
}
