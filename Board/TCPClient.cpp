#include "TCPClient.h"
#include <QDebug>
#include<QJsonObject>
#include<QJsonDocument>
#include<QString>

TCPClient::TCPClient()
{
    m_ip = "140.127.208.183";
    m_port = 8888;
    m_tcpsocket = new QTcpSocket();

    connect(m_tcpsocket,&QTcpSocket::connected,this,&TCPClient::onConnected,Qt::AutoConnection);
    connect(m_tcpsocket,&QTcpSocket::readyRead,this,&TCPClient::getMsg,Qt::AutoConnection);
}

TCPClient::~TCPClient()
{
    m_tcpsocket->close();
}

void TCPClient::setIP(const QString ip)
{
    m_ip = ip;
}

void TCPClient::setPort(const int port)
{
    m_port = port;
}

void TCPClient::onConnected()
{
    qDebug()<<"Already connect the host : "<< m_ip;
}

void TCPClient::getMsg()
{
    QByteArray buffer;
    buffer = m_tcpsocket->readAll();
    emit showMsg(buffer);
}

void TCPClient::createTCPConnect()
{
    m_tcpsocket->abort();
    m_tcpsocket->connectToHost(m_ip,m_port);

    if(!m_tcpsocket->waitForConnected(3000)){
        qDebug()<<"Connected failed";
        emit connectFailed();
    }else   emit connectSuccess();
}

void TCPClient::sendMsg(const QString msg)
{
    /*
    QJsonObject JsonMsg
    {
        {"Account", msg.split(',')[0]},
        {"Password",msg.split(',')[1]}
    };
    QJsonDocument Doc(JsonMsg);
    QByteArray ba = Doc.toJson();
    */
    m_tcpsocket->write(msg.toUtf8());
    m_tcpsocket->flush();
}


