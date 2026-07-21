import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

ColumnLayout {
    id: root

    required property var deviceDetails

    spacing: Tokens.spacing.extraSmall

    StyledText {
        text: "Dirección IP"
    }

    StyledText {
        text: root.deviceDetails?.ipAddress || "No disponible"
        color: Colours.palette.m3outline
        font: Tokens.font.body.small
    }

    StyledText {
        Layout.topMargin: Tokens.spacing.medium
        text: "Máscara de subred"
    }

    StyledText {
        text: root.deviceDetails?.subnet || "No disponible"
        color: Colours.palette.m3outline
        font: Tokens.font.body.small
    }

    StyledText {
        Layout.topMargin: Tokens.spacing.medium
        text: "Puerta de enlace"
    }

    StyledText {
        text: root.deviceDetails?.gateway || "No disponible"
        color: Colours.palette.m3outline
        font: Tokens.font.body.small
    }

    StyledText {
        Layout.topMargin: Tokens.spacing.medium
        text: "Servidores DNS"
    }

    StyledText {
        text: (root.deviceDetails && root.deviceDetails.dns && root.deviceDetails.dns.length > 0) ? root.deviceDetails.dns.join(", ") : "No disponible"
        color: Colours.palette.m3outline
        font: Tokens.font.body.small
        wrapMode: Text.Wrap
        Layout.maximumWidth: parent.width
    }
}
