#include "appcore.h"
#include "qqmlcontext"

#include <QEventLoop>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QtConcurrent/QtConcurrent>
#include <QFile>
#include <QDir>

Appcore *Appcore::instance = nullptr;

Appcore::Appcore(QObject *parent) : QObject{parent}
{
    Appcore::instance = this;
}

void Appcore::init()
{
    m_engine.rootContext()->setContextProperty("appcore", instance);
    m_engine.addImportPath(":/");
    m_engine.loadFromModule("RisoVat", "Main");
}

QVariant Appcore::getCurrentPath()
{
    return QDir::currentPath();
}

void Appcore::downloadRandomImage(int number)
{
    auto future = QtConcurrent::run( [this, number] {
        createImage(this->downloadRandomImageData(), number);
    } );
}

void Appcore::deleteImages()
{
    QDir dir(this->getCurrentPath().toString());
    QStringList filters;
    filters << "*.jpg";
    dir.setNameFilters(filters);
    QFileInfoList fileList = dir.entryInfoList();
    for (int i = 0; i < fileList.size(); ++i)
    {
        QFileInfo fileInfo = fileList.at(i);
        QFile file(fileInfo.absoluteFilePath());
        file.remove();
    }
}

QByteArray Appcore::downloadRandomImageData()
{
    QString category = "nature";
    QString url = "https://api.api-ninjas.com/v1/randomimage?category=" + category;

    QNetworkAccessManager manager;
    QNetworkRequest request(url);
    request.setRawHeader("X-Api-Key", "+kM6hEC+KZKhqljn3V+qWw==WRupNbHIIiuJyD1a");
    request.setRawHeader("Accept", "image/jpg");

    QScopedPointer<QNetworkReply> reply(manager.get(request));
    QEventLoop loop;
    QObject::connect(reply.data(), SIGNAL(finished()), &loop, SLOT(quit()));
    loop.exec();

    return reply->readAll();
}

void Appcore::createImage(const QByteArray &data, int number)
{
    if (data.isEmpty())
    {
        return;
    }

    QFile file("img" + QString::number(number) + ".jpg");
    if (file.open(QIODevice::WriteOnly))
    {
        file.write(data);
        file.close();
    }

    emit imageCreated();
}
