#ifndef APPCORE_H
#define APPCORE_H

#include <QQmlApplicationEngine>
#include <QObject>
#include <QQmlEngine>

class Appcore : public QObject
{
    Q_OBJECT
public:
    explicit Appcore(QObject *parent = nullptr);

    void init();

    Q_INVOKABLE QVariant getCurrentPath();
    Q_INVOKABLE void downloadRandomImage(int number);
    Q_INVOKABLE void deleteImages();

signals:
    void imageCreated();

private:
    static Appcore *instance;
    QQmlApplicationEngine m_engine;

    QByteArray downloadRandomImageData();
    void createImage(const QByteArray &data, int number);
};

#endif // APPCORE_H
