import QtQuick 2.15
import QtQuick.Controls.Material 2.15

Image
{
    id: root
    property var onClickedFun
    property string toolTipText: ""

    MouseArea
    {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onClicked:
        {
            root.onClickedFun();
        }
    }

    ToolTip
    {
        visible: mouseArea.containsMouse && root.toolTipText != ""
        delay: 150
        y: -implicitHeight - 6
        text: toolTipText
    }
}
