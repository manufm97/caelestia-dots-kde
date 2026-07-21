import QtQuick
import QtQuick.Layouts
import qs.modules.dashboard
import qs.modules.nexus.common

PageBase {
    title: "Wallhaven"
    isSubPage: true
    scrollable: false

    WallhavenTab {
        anchors.fill: parent
    }
}
