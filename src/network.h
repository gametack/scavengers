#ifndef NETWORK_H
#define NETWORK_H

#include <QFile>
#include <QJsonObject>
#include <QJsonArray>
#include <QVariant>
class network : public QObject
{
    Q_OBJECT
public:
    explicit network(QObject *parent = 0);
    ~network();


    Q_INVOKABLE void saveInfo(QString user, QString password);//locally save user info
    Q_INVOKABLE  QVariant loadInfo();
    Q_INVOKABLE  void removeFile(QString filePath);
    Q_INVOKABLE QVariant getHeatmap();


    Q_INVOKABLE QVariant saveFile(QString filePath);
};

#endif // NETWORK_H
