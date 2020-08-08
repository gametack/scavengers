#include "network.h"
#include <QFileInfo>
#include <QDebug>

network::network(QObject *parent) : QObject(parent)
{

}

network::~network()
{

}



void network::saveInfo(QString user,QString password)//locally save user info
{
    QFile f("info.do");
    f.open(QIODevice::WriteOnly);
    f.write(user.toLatin1()+"\n"+password.toLatin1());
    f.close();
}

QVariant network::loadInfo()
{
    QFile f("info.do");

    if(f.open(QIODevice::ReadOnly))
    {
//         QFileInfo asd(f);
//         qDebug()<<asd.absoluteFilePath();
        QList<QByteArray> info = f.readAll().split('\n');
        f.close();
        if(info.length()>1)
        {
            QJsonObject obj;
            obj["username"] = QString(info.at(0));
            obj["password"] = QString(info.at(1));
            return QVariant(obj);
        }
        else
        {
            return "false";
        }
    }
    else
    {
        return "false";
    }
    return "false";
}

QVariant network::saveFile(QString filePath)
{
    QFile f(filePath);
    f.open(QIODevice::ReadWrite);
    QByteArray x = f.readAll();
    return x;
}

void network::removeFile(QString filePath)
{
    QFile f(filePath);
    if(!f.open(QIODevice::ReadOnly))
    {

    }
    else
    {
        bool sd=f.remove();
        QString asd = f.errorString();
        int i=0;
    }
    f.close();

}

QVariant network::getHeatmap()
{
    QFile f("heatmap.txt");
    f.open(QIODevice::ReadOnly);
    QByteArray x = f.readAll();
    QStringList sd = QString(x).split("\n");
    QJsonArray asd = QJsonArray::fromStringList(sd);
    return QVariant(asd);
}


