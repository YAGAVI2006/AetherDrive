#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QIcon>
#include <QDir>
#include <QDebug>

#include "VehicleTelemetryModel.h"
#include "ThemeController.h"
#include "OtaManager.h"
#include "MqttClient.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    app.setApplicationName("AetherDrive");
    app.setOrganizationName("AetherAutomotive");
    app.setApplicationVersion("1.0.0");

    // Modern Qt Quick Controls style
    QQuickStyle::setStyle("Basic");

    QQmlApplicationEngine engine;

    auto telemetryModel = std::make_unique<AetherDrive::VehicleTelemetryModel>();
    auto themeController = std::make_unique<AetherDrive::ThemeController>();
    auto otaManager = std::make_unique<AetherDrive::OtaManager>();
    auto mqttClient = std::make_unique<AetherDrive::MqttClient>();

    // Wire MQTT signals to Telemetry model
    QObject::connect(mqttClient.get(), &AetherDrive::MqttClient::connected, [&telemetryModel]() {
        telemetryModel->setConnected(true);
    });
    QObject::connect(mqttClient.get(), &AetherDrive::MqttClient::disconnected, [&telemetryModel]() {
        telemetryModel->setConnected(false);
    });
    QObject::connect(mqttClient.get(), &AetherDrive::MqttClient::telemetryReceived, 
                     telemetryModel.get(), &AetherDrive::VehicleTelemetryModel::updateTelemetryFromJson);
    QObject::connect(mqttClient.get(), &AetherDrive::MqttClient::alertReceived, 
                     telemetryModel.get(), &AetherDrive::VehicleTelemetryModel::updateAlert);

    // Expose backends to QML
    QQmlContext* rootContext = engine.rootContext();
    rootContext->setContextProperty("telemetryModel", telemetryModel.get());
    rootContext->setContextProperty("themeController", themeController.get());
    rootContext->setContextProperty("otaManager", otaManager.get());
    rootContext->setContextProperty("mqttClient", mqttClient.get());

    // Connect to MQTT Broker
    mqttClient->connectToBroker();

    // Load QML
    const QUrl url(QStringLiteral("qrc:/qml/Main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    // Fallback search paths for filesystem loading
    engine.addImportPath(app.applicationDirPath() + "/../qml");
    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        // Try direct file load
        engine.load(QUrl::fromLocalFile(QDir::currentPath() + "/hmi/qml/Main.qml"));
    }

    return app.exec();
}
