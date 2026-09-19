#pragma once

#include <QObject>
#include <QColor>

namespace AetherDrive {

class ThemeController : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool isNightMode READ isNightMode WRITE setNightMode NOTIFY nightModeChanged)
    Q_PROPERTY(QColor backgroundColor READ backgroundColor NOTIFY themeColorsChanged)
    Q_PROPERTY(QColor cardColor READ cardColor NOTIFY themeColorsChanged)
    Q_PROPERTY(QColor primaryAccent READ primaryAccent CONSTANT)
    Q_PROPERTY(QColor secondaryText READ secondaryText NOTIFY themeColorsChanged)
    Q_PROPERTY(QColor primaryText READ primaryText NOTIFY themeColorsChanged)
    Q_PROPERTY(QColor warningColor READ warningColor CONSTANT)
    Q_PROPERTY(QColor dangerColor READ dangerColor CONSTANT)

public:
    explicit ThemeController(QObject* parent = nullptr);

    bool isNightMode() const { return m_isNightMode; }
    void setNightMode(bool night);

    QColor backgroundColor() const { return m_isNightMode ? QColor("#0A0D12") : QColor("#F8FAFC"); }
    QColor cardColor() const { return m_isNightMode ? QColor("#141820") : QColor("#FFFFFF"); }
    QColor primaryAccent() const { return QColor("#00B4D8"); }
    QColor primaryText() const { return m_isNightMode ? QColor("#F8FAFC") : QColor("#0F172A"); }
    QColor secondaryText() const { return m_isNightMode ? QColor("#94A3B8") : QColor("#64748B"); }
    QColor warningColor() const { return QColor("#FFB703"); }
    QColor dangerColor() const { return QColor("#EF233C"); }

signals:
    void nightModeChanged();
    void themeColorsChanged();

private:
    bool m_isNightMode{true};
};

} // namespace AetherDrive
