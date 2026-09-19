#include "OtaManager.h"

namespace AetherDrive {

OtaManager::OtaManager(QObject* parent)
    : QObject(parent)
    , m_progressTimer(new QTimer(this))
{
    connect(m_progressTimer, &QTimer::timeout, this, &OtaManager::handleProgressStep);
}

void OtaManager::checkForUpdates() {
    m_state = State::UpdateAvailable;
    m_statusText = "New firmware ready: v2.4.0 (Autonomous Highway Assist & UI Refresh)";
    emit statusChanged();
    emit updateAvailableChanged();
}

void OtaManager::startUpdate() {
    if (isUpdating()) return;

    m_state = State::Downloading;
    m_progress = 0;
    m_statusText = "Downloading firmware package (248 MB)...";
    emit statusChanged();
    emit progressChanged();
    emit updatingStateChanged();
    emit updateAvailableChanged();

    m_progressTimer->start(120); // updates every 120ms
}

void OtaManager::cancelUpdate() {
    m_progressTimer->stop();
    m_state = State::UpdateAvailable;
    m_progress = 0;
    m_statusText = "Update canceled.";
    emit statusChanged();
    emit progressChanged();
    emit updatingStateChanged();
    emit updateAvailableChanged();
}

void OtaManager::handleProgressStep() {
    m_progress += 4;

    if (m_progress < 60) {
        m_state = State::Downloading;
        m_statusText = QString("Downloading firmware... %1%").arg(m_progress);
    } else if (m_progress < 85) {
        m_state = State::Verifying;
        m_statusText = QString("Verifying cryptographic signature... %1%").arg(m_progress);
    } else if (m_progress < 100) {
        m_state = State::Installing;
        m_statusText = QString("Flashing SDV ECUs and rebooting subsystems... %1%").arg(m_progress);
    } else {
        m_progress = 100;
        m_progressTimer->stop();
        m_state = State::Success;
        m_currentVersion = m_targetVersion;
        m_statusText = "System successfully updated to v2.4.0!";
        emit updateCompleted();
    }

    emit progressChanged();
    emit statusChanged();
    emit updatingStateChanged();
}

} // namespace AetherDrive
