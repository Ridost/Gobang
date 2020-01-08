#include "TCPClient.h"
#include <QDebug>


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
    m_tcpsocket->deleteLater();
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
        return;
    }
}

void TCPClient::sendMsg(const QString msg)
{
    m_tcpsocket->write(msg.toUtf8());
    m_tcpsocket->flush();
    m_tcpsocket->close();
}


