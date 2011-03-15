/****************************************************************************
**
** Copyright (C) 2011 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the Qt Components project on Qt Labs.
**
** No Commercial Usage
** This file contains pre-release code and may not be distributed.
** You may use this file in accordance with the terms and conditions contained
** in the Technology Preview License Agreement accompanying this package.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** If you have questions regarding the use of this file, please contact
** Nokia at qt-info@nokia.com.
**
****************************************************************************/

import Qt 4.7
import "." 1.0

ImplicitSizeItem {
    id: root

    property Item tools: null

    // The transition type. One of the following:
    //      set         an instantaneous change (default)
    //      push        follows page stack push animation
    //      pop         follows page stack pop animation
    //      replace     follows page stack replace animation
    property string transition: "set"

    // Sets the tools with a transition.
    function setTools(tools, transition) {
        stateGroup.state = tools ? "" : "Hidden"
        tools.height = root.height
        priv.transition = transition
        root.tools = tools
    }

    implicitWidth: style.current.preferredWidth
    implicitHeight: style.current.preferredHeight

    BorderImage {
        id: background
        anchors.fill: parent
        source: style.current.get("background")
        border { left: 20;  top: 20;  right: 20;  bottom: 20 }
    }

    Style {
        id: style
        styleClass: "ToolBar"
    }

    //Prevents mouse events from propagating to elements below the ToolBar
    MouseArea {
        anchors.fill: parent
    }

    Item {
        id: container
        anchors.fill: parent
    }

    onToolsChanged: {
        priv.performTransition(priv.transition || transition)
        priv.transition = undefined
    }

    Component {
        id: containerComponent

        Item {
            id: item

            anchors.fill: parent

            // The states correspond to the different possible positions of the item.
            state: "Hidden"

            // The tools held by this item.
            property Item tools: null
            // The owner of the tools.
            property Item owner: null

            states: [
                // Start state for pop entry, end state for push exit.
                State {
                    name: "Prev"
                    PropertyChanges { target: item; opacity: 0.0 }
                },
                // Start state for push entry, end state for pop exit.
                State {
                    name: "Next"
                    PropertyChanges { target: item; opacity: 0.0 }
                },
                // Start state for replace entry.
                State {
                    name: "Front"
                    PropertyChanges { target: item; opacity: 0.0 }
                },
                // End state for replace exit.
                State {
                    name: "Back"
                    PropertyChanges { target: item; opacity: 0.0 }
                },
                // Inactive state.
                State {
                    name: "Hidden"
                    PropertyChanges { target: item; visible: false }
                    StateChangeScript {
                        script: {
                            if (item.tools) {
                                // re-parent back to original owner
                                tools.visible = false
                                tools.parent = owner

                                // reset item
                                item.tools = item.owner = null
                            }
                        }
                    }
                }
            ]

            transitions: [
                // Pop entry and push exit transition.
                Transition {
                    from: "";  to: "Prev";  reversible: true
                    SequentialAnimation {
                        PropertyAnimation { properties: "opacity";  easing.type: Easing.InCubic;  duration: priv.transitionDuration / 2 }
                        PauseAnimation { duration: priv.transitionDuration / 2 }
                        ScriptAction { script: if (state == "Prev") state = "Hidden" }
                    }
                },
                // Push entry and pop exit transition.
                Transition {
                    from: "";  to: "Next";  reversible: true
                    SequentialAnimation {
                        PropertyAnimation { properties: "opacity";  easing.type: Easing.InCubic;  duration: priv.transitionDuration / 2 }
                        PauseAnimation { duration: priv.transitionDuration / 2 }
                        ScriptAction { script: if (state == "Next") state = "Hidden" }
                    }
                },
                Transition {
                    // Replace entry transition.
                    from: "Front";  to: ""
                    SequentialAnimation {
                        PropertyAnimation { properties: "opacity";  easing.type: Easing.InOutExpo;  duration: priv.transitionDuration }
                    }
                },
                Transition {
                    // Replace exit transition.
                    from: "";  to: "Back"
                    SequentialAnimation {
                        PropertyAnimation { properties: "opacity";  easing.type: Easing.InOutExpo;  duration: priv.transitionDuration }
                        ScriptAction { script: if (state == "Back") state = "Hidden"  }
                    }
                }
            ]
        }
    }

    QtObject {
        id: priv

        property Item currentComponent: null

        // Alternating components used for transitions.
        property Item compA: null
        property Item compB: null

        // The transition to perform next.
        property variant transition

        // Duration of transition animation (in ms)
        property int transitionDuration: 500

        // Performs a transition between tools in the toolbar.
        function performTransition(transition) {
            // lazily create components if they have not been created
            if (!priv.currentComponent) {
                priv.compA = containerComponent.createObject(container)
                priv.compB = containerComponent.createObject(container)
                priv.currentComponent = priv.compB
            }

            // no transition if the tools are unchanged
            if (priv.currentComponent.tools == tools)
                return

            // select component states based on the transition animation
            var transitions = {
                "set":      { "new": "",        "old": "Hidden" },
                "push":     { "new": "Next",    "old": "Prev" },
                "pop":      { "new": "Prev",    "old": "Next" },
                "replace":  { "new": "Front",   "old": "Back" }
            }

            var animation = transitions[transition]
            // initialize the free component
            var component = priv.currentComponent == priv.compA ? priv.compB : priv.compA
            component.state = "Hidden"
            if (tools) {
                component.tools = tools
                component.owner = tools.parent
                tools.parent = component
                tools.visible = true
                tools.layoutChildren()
            }

            // perform transition
            priv.currentComponent.state = animation["old"]
            if (tools) {
                component.state = animation["new"]
                component.state = ""
            }
            priv.currentComponent = component
        }
    }

    StateGroup {
        id: stateGroup
        states: [
            // Inactive state.
            State {
                name: "Hidden"
                PropertyChanges { target: root;  height: 0;  opacity: 0.0 }
            }
        ]

        transitions: [
            // Transition between active and inactive states.
            Transition {
                from: "";  to: "Hidden";  reversible: true
                SequentialAnimation {
                    PropertyAnimation { properties: "opacity";  easing.type: Easing.InOutExpo;  duration: priv.transitionDuration }
                    PropertyAnimation { properties: "height";  duration: 10 }
                }
            }
        ]
    }
}
