pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Config
import qs.components
import qs.services
import qs.modules.lock

Item {
    id: root

    required property Pam pam

    readonly property string msg: {
        if (pam.fprintState === "error")
            return "ERROR DH: %1".arg(pam.fprint.message);
        if (pam.state === "error")
            return "ERROR CT: %1".arg(pam.passwd.message);

        if (pam.lockMessage)
            return pam.lockMessage;

        if (pam.state === "max" && pam.fprintState === "max")
            return "Se alcanzó el máximo de intentos de contraseña y huella.";
        if (pam.state === "max") {
            if (pam.fprint.available)
                return "Máximo de intentos de contraseña. Usa la huella.";
            return "Máximo de intentos de contraseña.";
        }
        if (pam.fprintState === "max")
            return "Máximo de intentos de huella. Usa la contraseña.";

        if (pam.state === "fail") {
            if (pam.fprint.available)
                return "Contraseña incorrecta. Intenta de nuevo o usa huella.";
            return "Contraseña incorrecta. Intenta de nuevo.";
        }
        if (pam.fprintState === "fail")
            return "Huella no reconocida (%1/%2). Intenta de nuevo o usa contraseña.".arg(pam.fprint.tries).arg(Config.lock.maxFprintTries);

        return "";
    }

    readonly property string stateMsg: {
        if (Hypr.kbLayout !== Hypr.defaultKbLayout) {
            if (Hypr.capsLock && Hypr.numLock)
                return "BloqMayús y BloqNum activados.\nTeclado: %1".arg(Hypr.kbLayoutFull);
            if (Hypr.capsLock)
                return "BloqMayús activado. Teclado: %1".arg(Hypr.kbLayoutFull);
            if (Hypr.numLock)
                return "BloqNum activado. Teclado: %1".arg(Hypr.kbLayoutFull);
            return "Distribución del teclado: %1".arg(Hypr.kbLayoutFull);
        }

        if (Hypr.capsLock && Hypr.numLock)
            return "BloqMayús y BloqNum están activados.";
        if (Hypr.capsLock)
            return "BloqMayús está activado.";
        if (Hypr.numLock)
            return "BloqNum está activado.";

        return "";
    }

    property bool stateMsgShouldBeVisible

    onMsgChanged: {
        if (msg) {
            if (message.opacity > 0) {
                message.animate = true;
                message.text = msg;
                message.animate = false;

                exitAnim.stop();
                if (message.scale < 1)
                    appearAnim.restart();
                else
                    flashAnim.restart();
            } else {
                message.text = msg;
                exitAnim.stop();
                appearAnim.restart();
            }
        } else {
            appearAnim.stop();
            flashAnim.stop();
            exitAnim.start();
        }
    }

    onStateMsgChanged: {
        if (stateMsg) {
            if (stateMessage.opacity > 0) {
                stateMessage.animate = true;
                stateMessage.text = stateMsg;
                stateMessage.animate = false;
            } else {
                stateMessage.text = stateMsg;
            }
            stateMsgShouldBeVisible = true;
        } else {
            stateMsgShouldBeVisible = false;
        }
    }

    implicitHeight: Math.max(message.implicitHeight, stateMessage.implicitHeight)

    Behavior on implicitHeight {
        Anim {}
    }

    StyledText {
        id: stateMessage

        anchors.left: parent.left
        anchors.right: parent.right

        scale: root.stateMsgShouldBeVisible && !root.msg ? 1 : 0.7
        opacity: root.stateMsgShouldBeVisible && !root.msg ? 1 : 0
        color: Colours.palette.m3onSurfaceVariant

        font: Tokens.font.body.small
        horizontalAlignment: Qt.AlignHCenter
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        lineHeight: 1.2

        Behavior on scale {
            Anim {}
        }

        Behavior on opacity {
            Anim {
                type: Anim.DefaultEffects
            }
        }
    }

    StyledText {
        id: message

        anchors.left: parent.left
        anchors.right: parent.right

        scale: 0.7
        opacity: 0
        color: Colours.palette.m3error

        font: Tokens.font.body.small
        horizontalAlignment: Qt.AlignHCenter
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

        Connections {
            function onFlashMsg(): void {
                exitAnim.stop();
                if (message.scale < 1)
                    appearAnim.restart();
                else
                    flashAnim.restart();
            }

            target: root.pam
        }

        Anim {
            id: appearAnim

            type: Anim.DefaultEffects
            target: message
            properties: "scale,opacity"
            to: 1
            onFinished: flashAnim.restart()
        }

        SequentialAnimation {
            id: flashAnim

            loops: 2

            FlashAnim {
                to: 0.3
            }
            FlashAnim {
                to: 1
            }
        }

        ParallelAnimation {
            id: exitAnim

            Anim {
                target: message
                property: "scale"
                to: 0.7
                type: Anim.StandardLarge
            }
            Anim {
                target: message
                property: "opacity"
                to: 0
                type: Anim.StandardLarge
            }
        }
    }

    component FlashAnim: NumberAnimation {
        target: message
        property: "opacity"
        duration: Tokens.anim.durations.small
        easing.type: Easing.Linear
    }
}
