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
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import '../code/utils.js' as Utils

Item {
	id: root

	//! dataengine
	PlasmaCore.DataSource {
		id: playbarEngine
		engine: 'playbar'
		connectedSources: 'Provider'

		readonly property bool showStop: hasSource( 'ShowStop' ) ? data[connectedSources[0]]['ShowStop'] : true
		readonly property bool controlsOnBar: hasSource( 'ControlsOnBar' ) ? data[connectedSources[0]]['ControlsOnBar'] : true
		readonly property int  buttonsAppearance: hasSource( 'ButtonsAppearance' ) ? data[connectedSources[0]]['ButtonsAppearance'] : 0
		readonly property int  backgroundHint: hasSource( 'BackgroundHint' ) ? data[connectedSources[0]]['BackgroundHint'] : 1

		function startOperation( name ) {
			if ( !playbarEngine.valid ) return
			var service = playbarEngine.serviceForSource( 'Provider' )
			var job = service.operationDescription( name )
			service.startOperationCall( job )
		}

		function setSource( name ) {
			if ( !playbarEngine.valid ) return
			var service = playbarEngine.serviceForSource( 'Provider' )
			var job = service.operationDescription( 'SetSourceMpris2' )
			job['source'] = name
			service.startOperationCall( job )
		}

		function hasSource( key ) {
			return data[connectedSources[0]] != undefined
			&& data[connectedSources[0]][key] != undefined
		}
	}
	//! dataengine
	Mpris2 { id: mpris2 }

	property bool vertical: plasmoid.formFactor === PlasmaCore.Types.Vertical

	Plasmoid.compactRepresentation: CompactApplet { id: compact }
	Plasmoid.fullRepresentation: DefaultLayout { id: full }

// 	NOTE: This is necessary ?
	Plasmoid.preferredRepresentation: plasmoid.formFactor === PlasmaCore.Types.Planar ?
		  Plasmoid.fullRepresentation
		: Plasmoid.compactRepresentation

	Plasmoid.icon: internal.icon
//	Plasmoid.title: mpris2.identity
	Plasmoid.toolTipMainText: internal.title
	Plasmoid.toolTipSubText: internal.subText
	Plasmoid.backgroundHints: playbarEngine.backgroundHint
	Plasmoid.toolTipTextFormat: Text.StyledText

// 	Connections {
// 		target: Plasmoid
// 		onFormFactorChanged:  debug( 'FormFactor', Plasmoid.formFactor )
// 	}

	function debug( str, msg ) { console.debug( 'PlayBar2 ' + str + ': ' + msg ) }


	//! Context menu actions

	function action_raise() {
		mpris2.startOperation( 'Raise' )
	}

	function action_quit() {
		mpris2.startOperation( 'Quit' )
	}

	function action_nextSource() {
		mpris2.nextSource()
	}

	function action_configure() {
		playbarEngine.startOperation( 'ShowSettings' )
	}


	Component.onCompleted: {
		// debug( 'Theme', theme.themeName )
		Plasmoid.formFactorChanged()
		//NOTE: Init Utils
		Utils.Plasmoid = Plasmoid
		Utils.i18n = i18n
		Plasmoid.removeAction( 'configure' )
		Plasmoid.setAction( 'configure', i18n( 'Configure PlayBar' ) , 'configure', 'alt+d, s' )
	}

	QtObject {
		id: internal

		property string icon:
			mpris2.artUrl != '' ? Qt.resolvedUrl( mpris2.artUrl ) : 'media-playback-start'
		property string title:
			mpris2.title != '' ? mpris2.title : 'PlayBar'
		property string artist:
			mpris2.artist != '' ? i18n( '<b>By</b> %1 ', mpris2.artist ) : ''
		property string album:
			mpris2.album != ''? i18n( '<b>On</b> %1', mpris2.album ) : ''
		property string subText:
			( title === 'PlayBar' & artist === '' & album === '' ) ?
				i18n( 'Client MPRIS2, allows you to control your favorite media player' )
				: artist + album
	}
}






