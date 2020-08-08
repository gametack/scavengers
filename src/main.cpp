
#include <QtGui/QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QScreen>
#include <QDebug>
#include "network.h"

#ifdef Q_OS_ANDROID
#include <QtAndroidExtras>
#endif

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("AdventurUs");
    app.setOrganizationName("AdventurUs");
    app.setOrganizationDomain("AdventurUs.org");





    QScreen *screen = qApp->primaryScreen();
    int dpi = screen->physicalDotsPerInch() * screen->devicePixelRatio();
    bool isMobile = false;

#if defined(Q_OS_IOS)
    // iOS integration of scaling (retina, non-retina, 4K) does itself.
    dpi = screen->physicalDotsPerInch();
    isMobile = true;
#elif defined(Q_OS_ANDROID)
    // https://bugreports.qt-project.org/browse/QTBUG-35701
    // recalculate dpi for Android

    QAndroidJniEnvironment env;
    QAndroidJniObject activity = QtAndroid::androidActivity();
    QAndroidJniObject resources = activity.callObjectMethod("getResources", "()Landroid/content/res/Resources;");
    if (env->ExceptionCheck()) {
        env->ExceptionDescribe();
        env->ExceptionClear();

        return EXIT_FAILURE;
    }

    QAndroidJniObject displayMetrics = resources.callObjectMethod("getDisplayMetrics", "()Landroid/util/DisplayMetrics;");
    if (env->ExceptionCheck()) {
        env->ExceptionDescribe();
        env->ExceptionClear();

        return EXIT_FAILURE;
    }
    dpi = displayMetrics.getField<int>("densityDpi");
    isMobile = true;
#else
    // standard dpi
    //dpi = screen->logicalDotsPerInch() * screen->devicePixelRatio();
dpi=160.f;
#endif

    // now calculate the dp ratio
    qreal dp = dpi / 160.f;

    QQmlApplicationEngine engine;
    network *n = new network();
    //qDebug()<<engine.offlineStoragePath();
    engine.rootContext()->setContextProperty("net", n);
    engine.rootContext()->setContextProperty("dp", dp);
    engine.rootContext()->setContextProperty("isMobile", isMobile);
    engine.load(QUrl("qrc:/qml/main.qml"));

    return app.exec();
}
