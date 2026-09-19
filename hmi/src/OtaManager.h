#pragma once

#include <QObject>
#include <QString>
#include <QTimer>

namespace AetherDrive {

class OtaManager : public QObject {
    Q_OBJECT

    Q_PROPERTY(QString currentVersion READ currentVersion CONSTANT)
    Q_PROPERTY(QString targetVersion READ targetVersion CONSTANT)
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusChanged)
    Q_PROPERTY(int progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(bool isUpdateAvailable READ isUpdateAvailable NOTIFY updateAvailableChanged)
    Q_PROPERTY(bool isUpdating READ isUpdating NOTIFY updatingStateChanged)

public:
    enum class State {
        Idle,
        UpdateAvailable,
        Downloading,
        Verifying,
        Installing,
        Success
    };
    Q_ENUM(State)

    explicit OtaManager(QObject* parent = nullptr);

    QString currentVersion() const { return m_currentVersion; }
    QString targetVersion() const { return m_targetVersion; }
    QString statusText() const { return m_statusText; }
    int progress() const { return m_progress; }
    bool isUpdateAvailable() const { return m_state == State::UpdateAvailable; }
    bool isUpdating() const { return m_state == State::Downloading || m_state == State::Verifying || m_state == State::Installing; }

public slots:
    void checkForUpdates();
    void startUpdate();
    void cancelUpdate();

signals:
    void statusChanged();
    void progressChanged();
    void updateAvailableChanged();
    void updatingStateChanged();
    void updateCompleted();

private slots:
    void handleProgressStep();

private:
    State m_state{State::UpdateAvailable};
    QString m_currentVersion{"v2.3.4"};
    QString m_targetVersion{"v2.4.0"};
    QString m_statusText{"Software update available: v2.4.0"};
    int m_progress{0};
    QTimer* m_progressTimer;
};

} // namespace AetherDrive
