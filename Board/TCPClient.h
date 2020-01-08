#ifndef TCPCLIENT_H
#define TCPCLIENT_H
#include <QObject>
#include <QTcpSocket>

class TCPClient : public QObject
{
    Q_OBJECT
public:
    TCPClient();
    ~TCPClient();
    Q_INVOKABLE void setIP(const QString ip);
    QString getIP(){ return m_ip;}
    Q_INVOKABLE void setPort(const int port);
    int getPort(){ return m_port;}

    void onConnected();
    void getMsg();

public slots:
    void createTCPConnect();
    void sendMsg(const QString msg);

signals:
    void showMsg(const QString &msg);
private:
    QTcpSocket *m_tcpsocket;
    QString m_ip;
    int m_port;
};
#endif // TCPCLIENT_H
