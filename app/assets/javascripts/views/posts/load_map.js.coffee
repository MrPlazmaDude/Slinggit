## Module
class Map extends Backbone.View
	initialize: (options)->
		geocoder = new google.maps.Geocoder();

		myOptions =
				center: new google.maps.LatLng(39.65857056750545, -105.06980895996094)
				zoom: 8
				mapTypeId: google.maps.MapTypeId.ROADMAP

		map = new google.maps.Map(document.getElementById("map_canvas"), myOptions)

		places = new google.maps.places.PlacesService(map)

		geocoder.geocode 'address': @options.location , (results, status)=>
			if status == google.maps.GeocoderStatus.OK
				#console.log "ok"
				map.setCenter results[0].geometry.location
				marker = new google.maps.Marker
					map: map
					position: results[0].geometry.location

			else if status is google.maps.GeocoderStatus.ZERO_RESULTS
				#console.log "0"
				sw = new google.maps.LatLng(-33.8902, 151.1759);
				ne = new google.maps.LatLng(-33.8474, 151.2631);
				mapBounds = new google.maps.LatLngBounds(sw,ne);
				
				place = 
					bounds: mapBounds
					keyword: "nomabi"

				places.search place, (results, status)=>
					if status == google.maps.places.PlacesServiceStatus.OK
						#console.log "ok"
						map.setCenter results[0].geometry.location
						marker = new google.maps.Marker
							map: map
							position: results[0].geometry.location

					else
						#console.log status


			else
				## put some catch all code here to display something like slinggit home office
				#console.log status

##
window.getPostMap = (location)->
	return new Map( location:location )