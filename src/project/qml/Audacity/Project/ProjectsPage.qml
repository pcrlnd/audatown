/*
 * SPDX-License-Identifier: GPL-3.0-only
 * MuseScore-CLA-applies
 *
 * MuseScore
 * Music Composition & Notation
 *
 * Copyright (C) 2021 MuseScore BVBA and others
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
import QtQuick 2.15
import QtQuick.Layouts 1.3

import Muse.Ui 1.0
import Muse.UiComponents
import Audacity.Project 1.0

import "internal/ProjectsPage"

FocusScope {
    id: root

    QtObject {
        id: prv

        readonly property int sideMargin: 46
    }

    NavigationSection {
        id: navSec
        name: "RecentProjects"
        enabled: root.enabled && root.visible
        order: 3
        onActiveChanged: {
            if (navSec.active) {
                root.forceActiveFocus()
            }
        }
    }

    ProjectsPageModel {
        id: projectsPageModel
    }

    Rectangle {
        id: background

        anchors.fill: parent

        color: ui.theme.backgroundTertiaryColor
    }

    RowLayout {
        id: topLayout

        anchors.top: parent.top
        anchors.topMargin: prv.sideMargin
        anchors.left: parent.left
        anchors.leftMargin: prv.sideMargin
        anchors.right: parent.right
        anchors.rightMargin: prv.sideMargin

        spacing: 12

        NavigationPanel {
            id: navSearchPanel
            name: "HomeProjectsSearch"
            enabled: topLayout.enabled && topLayout.visible
            section: navSec
            order: 1
            accessible.name: qsTrc("project", "Projects")
        }

        StyledTextLabel {
            id: pageTitle
            Layout.fillWidth: true

            text: qsTrc("project", "Projects")
            font: ui.theme.titleBoldFont
            horizontalAlignment: Text.AlignLeft
        }

        SearchField {
            id: searchField

            Layout.preferredWidth: 220

            navigation.name: "Projects Search"
            navigation.panel: navSearchPanel
            navigation.order: 1
            accessible.name: qsTrc("project", "Search recent projects")
        }
    }

    ColumnLayout {
        id: controlsRow

        anchors.top: topLayout.bottom
        anchors.topMargin: prv.sideMargin
        anchors.left: parent.left
        anchors.leftMargin: prv.sideMargin
        anchors.right: parent.right
        anchors.rightMargin: prv.sideMargin

        spacing: 12

        RowLayout {
            id: viewControlsRow

            Layout.fillWidth: true
            spacing: 12

            Item {
                Layout.fillWidth: true
            }

            NavigationPanel {
                id: viewButtonsNavPanel
                name: "ViewButtons"
                enabled: viewControlsRow.enabled && viewControlsRow.visible
                section: navSec
                order: 3
                direction: NavigationPanel.Horizontal
                accessible.name: qsTrc("project", "View buttons")
            }

            RadioButtonGroup {
                id: viewTypeRadioButtons

                property int navigationOrderStart: 1

                implicitHeight: ui.theme.defaultButtonSize

                model: [
                    {
                        "icon": IconCode.GRID,
                        "title": qsTrc("project", "Grid view"),
                        "value": ProjectsPageModel.Grid
                    },
                    {
                        "icon": IconCode.LIST,
                        "title": qsTrc("project", "List view"),
                        "value": ProjectsPageModel.List
                    }
                ]

                delegate: FlatRadioButton {
                    implicitWidth: ui.theme.defaultButtonSize
                    implicitHeight: ui.theme.defaultButtonSize

                    checked: projectsPageModel.viewType === modelData.value

                    iconCode: modelData.icon
                    transparent: true
                    checkedColor: ui.theme.buttonColor

                    navigation.name: "ViewType_" + modelData.title
                    navigation.panel: viewButtonsNavPanel
                    navigation.order: viewTypeRadioButtons.navigationOrderStart + model.index
                    navigation.accessible.name: modelData.title

                    onToggled: {
                        projectsPageModel.viewType = modelData.value
                    }
                }
            }
        }
    }

    Loader {
        id: contentLoader

        anchors.top: controlsRow.bottom
        anchors.topMargin: 24
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: buttonsPanel.top

        sourceComponent: newAndRecentComp
    }

    Component {
        id: newAndRecentComp

        RecentProjectsView {
            anchors.fill: parent

            viewType: projectsPageModel.viewType
            searchText: searchField.searchText

            backgroundColor: background.color
            sideMargin: prv.sideMargin

            navigationSection: navSec
            navigationOrder: 4

            onCreateNewProjectRequested: {
                projectsPageModel.createNewProject()
            }

            onOpenProjectRequested: function (projectPath, displayName) {
                Qt.callLater(projectsPageModel.openProject, projectPath, displayName)
            }
        }
    }

    Rectangle {
        id: buttonsPanel

        anchors.bottom: parent.bottom

        height: 48
        width: parent.width

        color: ui.theme.backgroundTertiaryColor

        SeparatorLine {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
        }

        NavigationPanel {
            id: navBottomPanel
            name: "RecentProjectsBottom"
            section: navSec
            direction: NavigationPanel.Horizontal
            order: 7

            //: accessibility name for the panel at the bottom of the "Projects" page
            accessible.name: qsTrc("project", "Projects actions")
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: prv.sideMargin
            anchors.verticalCenter: parent.verticalCenter

            spacing: 22

            FlatButton {
                navigation.name: "NewProject"
                navigation.panel: navBottomPanel
                navigation.column: 2

                text: qsTrc("project", "New")

                onClicked: {
                    projectsPageModel.createNewProject()
                }
            }

            FlatButton {
                navigation.name: "Open other Project"
                navigation.panel: navBottomPanel
                navigation.column: 3

                text: qsTrc("project", "Open other…")

                onClicked: {
                    Qt.callLater(projectsPageModel.openOther)
                }
            }
        }
    }
}
