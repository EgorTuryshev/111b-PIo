#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "appcore.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    Appcore appcore;
    appcore.init();

    return app.exec();
}
