import QtQuick 2.0
import  QtQuick.Controls 2.12
import com.TCPClient 1.0
import "packetCreate.js" as Packet

Rectangle{
    id     : background
    width  : parent.width
    height : parent.height
    color  : "white"
    anchors.top : parent.top

    Column {
        id     : loginPage
        width  : parent.width
        height : parent.height
        anchors.top       : parent.top
        spacing           : parent.height / 16

        Rectangle{
            id    : title
            width : parent.width
            height: parent.height * 0.2
            color : "lightsteelblue"
            Text{
                text: "GoBang"
                width : parent.width
                height: parent.height
                font.pointSize: 100
                fontSizeMode: Text.Fit
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.centerIn: parent
            }
            anchors.horizontalCenter: parent.horizontalCenter
        }
        TextField{
            id    : account
            width : parent.width * 0.3
            height: parent.height * 0.05
            font.pointSize          : 12
            text                    : "a1055536"
            placeholderText         : "account"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        TextField{
            id    : password
            width : parent.width * 0.3
            height: parent.height * 0.05
            font.pointSize          : 12
            text                    : "ggininder"
            placeholderText         : "password"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Row{
            spacing: 20
            anchors.horizontalCenter: parent.horizontalCenter
            Button{
                id  : login
                text: "login"
                font.bold: true
                font.pointSize: 15
                width    : loginPage.width  * 0.1
                height   : loginPage.height * 0.05

                onClicked: {
                    username = account.text
                    var str = Packet.packet("login",account.text,password.text)
                    tcp.sendMsg(str)
                }
            }
            Button{
                id  : register
                text: "register"
                font.bold: true
                font.pointSize: 15
                width    : loginPage.width  * 0.1
                height   : loginPage.height * 0.05
                onClicked: {
                    var str = Packet.packet("register",account.text,password.text)
                    tcp.sendMsg(str)
                }
            }
        }

    }
}
