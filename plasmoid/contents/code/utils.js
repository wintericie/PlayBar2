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
.pragma library

var iconApplication
var Plasmoid
var i18n

function setActions( sourceActive, identity ) {
	var icon

	if ( sourceActive === '' ) return
	icon = sourceActive

	if ( sourceActive.match( 'vlc' ) )
		icon = 'vlc'

	switch ( sourceActive ) {
		case 'spotify':
			icon = 'spotify-client'
			break
		case 'clementine':
			icon = 'application-x-clementine'
			break
		case 'yarock':
			icon = 'application-x-yarock'
			break
	}
	iconApplication = icon
	print( iconApplication )

	Plasmoid.removeAction( 'configure' )
	Plasmoid.setAction( 'raise', i18n( 'Open %1', identity ) , icon )
	Plasmoid.setAction( 'quit', i18n( 'Quit' ) ,'window-close' )
	Plasmoid.setAction( 'nextSource', i18n( 'Next multimedia source' ) , 'go-next' )
	Plasmoid.setActionSeparator( 'sep1' )
	Plasmoid.setAction( 'configure', i18n( 'Configure PlayBar' ) , 'configure', 'alt+d, s' )

}

function removeActions() {
	Plasmoid.removeAction( 'raise' )
	Plasmoid.removeAction( 'quit' )
	Plasmoid.removeAction( 'nextSource' )
	Plasmoid.removeAction( 'sep1' )
}

//  Color manipulation utilities
//  Take it from Breeze project
function blendColors( clr0, clr1, p ) {
	return Qt.tint( clr0, adjustAlpha( clr1, p ) ) ;
}

function adjustAlpha( clr, a ) {
	return Qt.rgba( clr.r, clr.g, clr.b, a ) ;
}

// Hue: 0..1
// Saturation: 0..1
// Lightness: -1..1
// Return a { h, s, l } object
function rgbToHsl( clr ) {

	//The RGB values are divided by 255 to change the range from 0..255 to 0..1
	var R = clr.r
	var G = clr.g
	var B = clr.b

	var Cmax = Math.max( R, G, B )
	var Cmin = Math.min( R, G, B )

	var diff = Cmax - Cmin

	//Hue calculation
	var H
	if ( diff.toPrecision( 3 ) === 0.0 ) H = 0
	else {
		switch ( Cmax ) {
			case R:
				H = Math.mod( ( G - B ) / diff, 6 )
				break;
			case G:
				H = ( B - R ) / diff + 2
				break;
			case B:
				H = ( R - G ) / diff + 4
				break;
		}
		H /= 6
	}

	//Lightness calculation
	var L = ( Cmax + Cmin ) - 1

	//Saturation calculation
	var S = 0
	if ( diff.toPrecision( 3 ) != 0.0 ) {
		S = diff / ( ( L <= 0.0 ) ? ( Cmax + Cmin ) : ( 2 - Cmax - Cmin ) )
	}

	return { h: H, s: S, l: L }
}

function truncate( n ) {
	return n | 0
}


