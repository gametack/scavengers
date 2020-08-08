TEMPLATE = app

QT += qml quick location svg
#QT += androidextras

#ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android-sources
#OTHER_FILES += \
#    android-sources/src/org/qtproject/example/notification/NotificationClient.java \
#    android-sources/AndroidManifest.xml
SOURCES += main.cpp\
    network.cpp

HEADERS += network.h\


OTHER_FILES += qml/* \
               qml/dynamic/* \
               qml/dynamic/userspace/*\
               qml/dynamic/creategame/*\
               qml/helpers/*\
               qml/images/*\
               qml/svg/*

# Avoid auto screen rotation
DEFINES += ORIENTATIONLOCK

RESOURCES += qml.qrc

folder_01.source = qml/
folder_01.target = qml
DEPLOYMENTFOLDERS = folder_01

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

DISTFILES += \
    qml/Init.qml



