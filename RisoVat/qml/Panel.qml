import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    Rectangle
    {
        id: background
        width: parent.width
        height: parent.height
        color: "#EEEEEE"
        radius: 15
    }

    DropShadow
    {
        id: shadow
        anchors.fill: background
        horizontalOffset: 2
        verticalOffset: 2
        radius: 8.0
        color: "#407A7A7A"
        source: background
        samples: 17
        spread: 0
    }
}

