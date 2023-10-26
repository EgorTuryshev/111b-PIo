import QtQuick
import QtQuick.Window
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs

ApplicationWindow
{
    id: window
    width: 800
    height: 600
    visible: true
    title: "RisoVat"

    Material.accent: "#3E5197"

    /*-------------------------------------------------------------------------*/
    property int brushSize: 5;  //Вот это свойство вам надо менять по заданию
    /*-------------------------------------------------------------------------*/

    property color textColor: "#5A5A5A";
    property color selectedColor: "black";
    property int number: 0;

    onClosing:
    {
        appcore.deleteImages();
    }

    Connections
    {
        target: appcore
        function onImageCreated()
        {
            canvas.clear();
            canvas.unloadImage(canvas.imagePath);
            canvas.loadImage(canvas.imagePath);
        }
    }

    Shortcut
    {
        sequence: "Ctrl+Z"
        onActivated: canvas.undo()
    }

    Dialog
    {
        id: dialog
        anchors.centerIn: parent
        title: "Добавление цвета"
        standardButtons: Dialog.Ok | Dialog.Cancel

        RowLayout
        {
            Text
            {
                text: "HEX-код цвета:"
                font.pixelSize: 16
                color: window.textColor;
            }
            TextField
            {
                id: hex

                implicitHeight: 30
                topPadding: 0
                bottomPadding: 0
                Layout.leftMargin: 10
                color: window.textColor;
            }
        }

        onAccepted:
        {
            colors.model.append( { "color": hex.text } );
        }
    }

    FileDialog
    {
        id: fileDialog
        fileMode: FileDialog.SaveFile
        nameFilters: ["JPEG (*.jpg)"]
        acceptLabel: "Сохранить..."
        onAccepted:
        {
            var filePath = selectedFile.toString().substring(8);
            canvas.save(filePath);
        }
    }

    menuBar: MenuBar
    {
        Menu
        {
            title: "Файл"
            Action
            {
                text: "Новый"

                onTriggered:
                {
                    canvas.isImage = false;
                    canvas.width = window.width;
                    canvas.height = window.height;
                    canvas.clear();
                    canvas.requestPaint();
                }
            }
            Action
            {
                text: "Случайное"

                onTriggered:
                {
                    window.number++;
                    canvas.isImage = true;
                    appcore.downloadRandomImage(number);
                    canvas.width = 640;
                    canvas.height = 480;
                }
            }
            Action
            {
                text: "Сохранить"

                onTriggered:
                {
                    fileDialog.open();
                }
            }
            Action
            {
                text: "Закрыть"

                onTriggered:
                {
                    window.close();
                }
            }
        }

        delegate: MenuBarItem
        {
            id: menuBarItem

            contentItem: Text
            {
                text: menuBarItem.text
                font.pixelSize: 16
                opacity: enabled ? 1.0 : 0.3
                color: window.textColor
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle
            {
                implicitWidth: 40
                implicitHeight: 40
                opacity: enabled ? 1 : 0.3
                color: menuBarItem.highlighted ? "#E1E1E1" : "transparent"
            }
        }

        background: Rectangle
        {
            implicitWidth: 40
            implicitHeight: 40
            color: "#EEEEEE"
        }
    }

    Item
    {
        id: panels
        z: 1
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.bottomMargin: 10
        clip: false

        NumberAnimation
        {
            id: color_slideLeftToRight
            target: colorPanel
            property: "x"
            duration: 200
            to: 0
            easing.type: Easing.InOutQuad
        }

        NumberAnimation
        {
            id: color_slideRightToLeft
            target: colorPanel
            property: "x"
            duration: 200
            to: -55
            easing.type: Easing.InOutQuad
        }

        Timer
        {
            id: colorTimer
            interval: 3000
            running: false
            repeat: false

            onTriggered:
            {
                if (!colorHitBox.containsMouse) color_slideRightToLeft.start();
                else { colorTimer.restart(); }
            }
        }

        Panel
        {
            id: colorPanel
            width: 60
            height: 190
            x: -55
            anchors.verticalCenter: parent.verticalCenter

            MouseArea
            {
                id: colorHitBox
                anchors.fill: parent
                hoverEnabled: true
                onEntered:
                {
                    color_slideLeftToRight.start();
                }
                onExited:
                {
                    colorTimer.restart();
                }
            }

            ColumnLayout
            {
                anchors.centerIn: parent
                width: parent.width
                height: parent.height - 20

                ListView
                {
                    id: colors

                    width: parent.width;
                    height: parent.height - 30;
                    spacing: 5
                    clip: true
                    interactive: true

                    ScrollBar.vertical: ScrollBar
                    {
                        active: true
                        width: 5
                    }

                    model: ListModel
                    {
                        ListElement { color: "#D9D9D9" }
                        ListElement { color: "#5A5A5A" }
                        ListElement { color: "#AF6565" }
                        ListElement { color: "#67AB72" }
                        ListElement { color: "#5868A3" }
                    }

                    delegate: Rectangle
                    {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 30
                        height: 30
                        radius: 5
                        color: model.color

                        MouseArea
                        {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked:
                            {
                                window.selectedColor = parent.color;
                            }
                        }
                    }
                }

                ImageButton
                {
                    sourceSize.width: 30
                    sourceSize.height: 30
                    Layout.alignment: Qt.AlignHCenter
                    source: "qrc:/plus.svg";

                    onClickedFun: function fun()
                    {
                        dialog.visible = true;
                    }
                }
            }
        }

        Panel
        {
            width: 115
            height: 50
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom

            ListView
            {
                id: tools
                anchors.centerIn: parent;
                width: parent.width - 20;
                height: parent.height - 20;
                orientation: Qt.Horizontal
                spacing: 10
                clip: true
                interactive: false

                model: ListModel
                {
                    ListElement { source: "qrc:/pencil.svg"; tool: "pencil" }
                    ListElement { source: "qrc:/eraser.svg"; tool: "eraser" }
                    ListElement { source: "qrc:/line.svg"; tool: "line" }
                }

                delegate: ImageButton
                {
                    sourceSize.width: 25
                    sourceSize.height: 25
                    anchors.verticalCenter: parent.verticalCenter
                    source: model.source;

                    onClickedFun: function fun()
                    {
                        canvas.tool = model.tool;
                    }
                }
            }
        }
    }

    /*Код после этого комментария МОДИФИЦИРОВАТЬ НЕ СТОИТ*/

    Canvas
    {
        id: canvas
        z: 0
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        property bool isImage: false
        property string imagePath: "file:/" + appcore.getCurrentPath() + "/img" + window.number + ".jpg"
        property var lines: []
        property var currentLine: ({ points: [], color: "", width: "" })
        property var history: []
        property string tool: "pencil"

        function clear()
        {
            canvas.lines = [];
            canvas.history = [];
            canvas.currentLine = ({ points: [], color: "", width: "" });
        }

        function undo()
        {
            if (history.length > 0) {
                var lastAction = history.pop();
                if (JSON.stringify(lastAction.line) === JSON.stringify(currentLine)) {
                    currentLine = { points: [], color: "", width: "" };
                }
                for (var i = 0; i < lines.length; i++) {
                    if (JSON.stringify(lines[i]) === JSON.stringify(lastAction.line)) {
                        lines.splice(i, 1);
                        break;
                    }
                }
                currentLine = { points: [], color: window.selectedColor, width: window.selectedWidth };
                requestPaint();
            }
        }

        onImageLoaded:
        {
            requestPaint();
        }

        onPaint:
        {
            var ctx = getContext("2d");

            ctx.fillStyle = "white";
            ctx.fillRect(0, 0, canvas.width, canvas.height);
            if (isImage)
            {
                if (isImageLoaded(canvas.imagePath))
                {
                    ctx.drawImage(imagePath, 0, 0);
                }
            }

            for (var i in lines)
            {
                var line = lines[i];
                ctx.beginPath();
                ctx.strokeStyle = line.color;
                ctx.lineWidth = line.width;
                for (var j in line.points)
                {
                    var point = line.points[j];
                    if (j === 0)
                        ctx.moveTo(point.x, point.y);
                    else
                        ctx.lineTo(point.x, point.y);
                }
                ctx.stroke();
            }

            if (currentLine.points.length > 0)
            {
                ctx.beginPath();
                ctx.strokeStyle = currentLine.color;
                ctx.lineWidth = currentLine.width;
                for (i in currentLine.points)
                {
                    point = currentLine.points[i];
                    if (i === 0)
                        ctx.moveTo(point.x, point.y);
                    else
                        ctx.lineTo(point.x, point.y);
                }
                ctx.stroke();
            }
        }

        MouseArea
        {
            anchors.fill: parent
            onPressed:
            {
                canvas.currentLine.points = [];
                if (canvas.tool === "eraser")
                {
                    canvas.currentLine.color = "#FFFFFF";
                }
                else
                {
                    canvas.currentLine.color = window.selectedColor;
                }

                canvas.currentLine.width = window.brushSize;
                canvas.currentLine.points.push(Qt.point(mouse.x, mouse.y));
                canvas.requestPaint();
            }

            onPositionChanged:
            {
                if (pressed)
                {
                    if (canvas.tool != "line")
                    {
                        canvas.currentLine.points.push(Qt.point(mouse.x, mouse.y));
                        canvas.requestPaint();
                    }
                }
            }

            onReleased:
            {
                if (canvas.tool === "line") canvas.currentLine.points.push(Qt.point(mouse.x, mouse.y));
                if (canvas.currentLine.points.length > 0)
                {
                    canvas.lines.push(JSON.parse(JSON.stringify(canvas.currentLine)));
                    canvas.history.push({tool: canvas.tool, line: JSON.parse(JSON.stringify(canvas.currentLine))});
                }

                canvas.requestPaint();
            }
        }
    }
}
