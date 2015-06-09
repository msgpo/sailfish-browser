/****************************************************************************
**
** Copyright (C) 2014 Jolla Ltd.
** Contact: Raine Makelainen <raine.makelainen@jolla.com>
**
****************************************************************************/

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

import QtQuick 2.1
import Sailfish.Silica 1.0

BackgroundItem {
    id: root

    property bool activeTab: activeTabIndex === index
    // Expose ListView for all items
    property Item view: ListView.view
    property bool destroying

    // In direction so that we can break this binding when closing a tab
    implicitWidth: width
    implicitHeight: height

    enabled: !destroying

    layer.effect: PressEffect {}
    layer.enabled: _showPress

    // Background item that is also a placeholder for a tab not having
    // thumbnail image.
    contentItem.width: root.implicitWidth
    contentItem.height: root.implicitHeight

    onClicked: view.activateTab(index)

    // contentItem is hidden so this cannot be children of the contentItem.
    // So, making them as siblings of the contentItem.
    data: [
        Image {
            id: image

            source: thumbnailPath
            cache: false
            asynchronous: true
        },

        Rectangle {
            anchors.fill: parent

            gradient: Gradient {
                GradientStop { position: 0.4; color: "transparent" }
                GradientStop { position: 1.0; color: Theme.rgba(Theme.highlightDimmerColor, 1.0) }
            }
        },
        IconButton {
            id: close

            anchors {
                left: parent.left
                bottom: parent.bottom
            }
            highlighted: down || activeTab
            icon.source: "image://theme/icon-m-tab-close"
            onClicked: {
                // Break binding, so that texture size would not change when
                // closing tab (animating height).
                root.implicitHeight = root.height
                root.implicitWidth = root.width

                destroying = true
                // Break binding to prevent texture source to change.
                if (activeTab) {
                    activeTab = true
                }
                activeTabIndex = -1
                removeTimer.running = true
            }
        },
        Timer {
            id: removeTimer
            interval: 16
            onTriggered: view.closeTab(index)
        },
        Label {
            anchors {
                left: close.right
                right: parent.right
                rightMargin: Theme.paddingMedium
                verticalCenter: close.verticalCenter
            }

            font.pixelSize: Theme.fontSizeLarge
            text: title
            truncationMode: TruncationMode.Fade
            color: down || activeTab ? Theme.highlightColor : Theme.primaryColor
        }
    ]
}
