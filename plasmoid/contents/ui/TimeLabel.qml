/*
 *   Author: audoban <audoban@openmailbox.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.4
import org.kde.plasma.extras 2.0 as PlasmaExtras
import '../code/utils.js' as Utils

PlasmaExtras.Paragraph {
	id: time

	// units in hundredth of second
	property int topTime: mpris2.length
	// units in hundredth of second
	property int currentTime: mpris2.position

	property bool showPosition: true

	property bool showRemaining: true

	property bool labelSwitch: false

	property alias interactive: mouseArea.hoverEnabled

	property alias autoTimeUpdate: timer.running

	color: Utils.adjustAlpha( theme.textColor, 0.8 )

	enabled: mpris2.sourceActive & mpris2.length > 0

	function positionUpdate( negative ) {
		var min, sec

		if ( negative ) sec = Math.abs( ( topTime - currentTime ) /100 )
		else sec = currentTime/100

		min = Utils.truncate( sec/60 )
		sec = Utils.truncate( sec - min*60 )

		if ( negative ) text = '-' + min + ':'
		else text = min + ':'
		text += sec <= 9 ? '0' + sec : sec
	}

	function lengthUpdate() {
		var min
		var sec = topTime/100
		min = Utils.truncate( sec/60 )
		sec = Utils.truncate( sec - min*60 )
		time.text = min + ':' + ( sec <= 9 ? '0' + sec : sec )
	}

	Timer {
		id: timer

		property bool _switch: labelSwitch

		interval: 400
		repeat: true
		running: parent.visible
		onTriggered: {
			if ( showPosition & showRemaining )
				positionUpdate( _switch )
			else if ( _switch & showPosition )
				positionUpdate( false )
			else if ( _switch & showRemaining )
				positionUpdate( true )
			else
				lengthUpdate()
		}
	}

	MouseArea {
		id: mouseArea

		anchors.fill: parent
		acceptedButtons: Qt.LeftButton
		enabled: hoverEnabled

		onEntered: color = theme.viewHoverColor
		onExited: color = Utils.adjustAlpha( theme.textColor, 0.8 )
		onReleased: {
			if ( !exited || containsMouse ) {
				timer._switch = !timer._switch
				plasmoid.configuration.TimeLabelSwitch = timer._switch
				timer.triggered()
			}
		}
	}
}
