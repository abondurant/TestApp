$.widget("custom.DispatchLocationMapping", {

    // Reference to available Stock Google Map Icons
    // https://www.google.com/fusiontables/DataSource?docid=1BDnT5U1Spyaes0Nj3DXciJKa_tuu7CzNRXWdVA#map:id=3

    options: {
        url: '~~~DEFAULT_URL~~~',
        whseUrl: '',
        geographyPolygonUrl: null,
        apiKey: 'AIzaSyBCCD4XdV3XjvVCJ1j-4wcARLVUq2hRNA4',
        filter: null,
        labelField: null,
        latitudeField: null,
        longitudeField: null,
        markerIconField: null,
        infoWindowField: null,
        fieldMapping: null,
        onComplete: null,
        pathToDataArray: null,
        showPolygon: null,
        callbackCreateRequest: null,
        callbackDataRetrieved: null,
        callbackMapRendered: null,
        callbackBuildMarker: null,
        callbackBuildMarkerIcon: null,
        callbackBuildInfoWindow: null,
        myPolygonArray: new Array(),
        dataSet: null,
        zindex: 10,
        map: null,
        mapOptions: {
            zoom: 3
        },
        minZoom: null,
        maxZoom: null,
        markers: new Array(),
        markerAnimation: null,
        paging: {
            PageNumber: 1,
            PageSize: 5000,
            TotalPages: 0,
            PageRecords: 0,
            TotalRecords: 0
        },
        dispatchLocationData: null,
        warehouseRadius: 0.0,
        warehouseMarkers: new Array(),
        warehouseCircles: new Array(),
        overlay: null
    },
    _create: function () {
        var _self = this;

        if (_self.options.markerAnimation == null)
            _self.options.markerAnimation = google.maps.Animation.DROP;

        _self.options.map = new google.maps.Map(_self.element[0], _self.options.mapOptions);



        _self.buildFormFunction();

    },
    _continue: function () {
    },
    show: function (displayOptions) {
        var _self = this;
    },
    fetch: function () {
        var _self = this;

        if (_self.options.callbackCreateRequest != null) {
            var request = _self.options.callbackCreateRequest(_self.options.paging);
            //request = '';
            var filter = _self.options.filter;
            filter = '';
            $.ajax({
                type: request.type,
                url: request.url
                , dataType: "json",
                data: {
                    "filter": filter
                }
            }).success(function (data, status, jqxhr) {
                _self.fetchSuccess(data, status, jqxhr);
            }).error(function (jqxhr, status, error) {
                _self.fetchError(jqxhr, status, error);
            }).complete(function (jqxhr, status) {
            });
        }

        _self.initAutocomplete();



        _self.options.map.addListener('rightclick', function (e) {

            var point = null;

            _self.contextMenu(_self.options, e, point);


            _self.addMenuItem("Show or Hide Polygon", 0, 'plow');
            _self.addMenuItem("Move Up Level", 0, 'plow');


        });

    },
    buildFormFunction: function () {
 
    },
    fetchSuccess: function (data, status, jqxhr) {
        var _self = this;

        if (typeof (_self.options.callbackDataRetrieved) == 'function') {
            data = _self.options.callbackDataRetrieved(data, status, jqxhr);
        }

        _self.options.paging = data.Paging;

        var dataArrayStart = null;
        if (_self.options.pathToDataArray != null) {
            dataArrayStart = _self.getJsonElement(data, _self.options.pathToDataArray);
        } else {
            dataArrayStart = data;
        }

        _self.options.dataSet = dataArrayStart;
        _self.display();
    },
    fetchError: function (jqxhr, status, error) {
        alert("MAP ERROR: " + error);
    },
    getMap: function () {
        var _self = this;

        return _self.options.map;

    },
    getValue: function (rowIndex, path) {
        var _self = this;
        var value = _self.getJsonElement(_self.options.dataSet[rowIndex], path);

        if (value == null)
            value = '';
        return value;
    },
    getJsonElement: function (object, path) {
        // REF: http://stackoverflow.com/questions/6491463/accessing-nested-javascript-objects-with-string-key
        var o = object;
        var s = path;

        s = s.replace(/\[(\w+)\]/g, '.$1'); // convert indexes to properties
        s = s.replace(/^\./, '');           // strip a leading dot
        var a = s.split('.');
        for (var i = 0, n = a.length; i < n; ++i) {
            var k = a[i];
            if (k in o) {
                o = o[k];
            } else {
                return;
            }
        }
        return o;
    },
    clear: function () {
        var _self = this;
        _self.clearMarkers();
    },
    clearMarkers: function () {
        var _self = this;

        for (var idx = _self.options.markers.length; idx > 0; idx--) {
            var marker = _self.options.markers.pop();
            marker.setMap(null);
        }
    },
    display: function () {

    },
    autoBounds: function () {
        var _self = this;
        var bounds = new google.maps.LatLngBounds();

        for (var idx = 0; idx < _self.options.markers.length; idx++) {
            bounds.extend(_self.options.markers[idx].position);
        }

        _self.options.map.fitBounds(bounds);

        _self.options.map.setCenter(bounds.getCenter());

        if (_self.options.minZoom != null)
            if (_self.options.map.getZoom() < _self.options.minZoom)
                _self.options.map.setZoom(_self.options.minZoom);

        if (_self.options.maxZoom != null)
            if (_self.options.map.getZoom() > _self.options.maxZoom)
                _self.options.map.setZoom(_self.options.maxZoom);

        _self.options.overlay = new google.maps.OverlayView();
        _self.options.overlay.draw = function () { };
        _self.options.overlay.setMap(_self.options.map);

    },

    initAutocomplete: function () {

        var _self = this

        var input = document.getElementById('pac-input');

        if (input == null) {
            var div = document.createElement('div');
            div.className = 'row';

            div.innerHTML =
                '<input id="pac-input" class="controls" type="text" placeholder="Search Box"/>';

            document.getElementById('report').appendChild(div);


            input = document.getElementById('pac-input');
        }
        var searchBox = new google.maps.places.SearchBox(input);
        _self.options.map.controls[google.maps.ControlPosition.TOP_LEFT].push(input);

        // Bias the SearchBox results towards current map's viewport.
        _self.options.map.addListener('bounds_changed', function () {
            searchBox.setBounds(_self.options.map.getBounds());
        });

        searchBox.addListener('places_changed', function () {
            var places = searchBox.getPlaces();

            if (places.length == 0) {
                return;
            }


            markers = [];

            // For each place, get the icon, name and location.
            var bounds = new google.maps.LatLngBounds();
            places.forEach(function (place) {
                if (!place.geometry) {
                    console.log("Returned place contains no geometry");
                    return;
                }
                var icon = {
                    url: place.icon,
                    size: new google.maps.Size(71, 71),
                    origin: new google.maps.Point(0, 0),
                    anchor: new google.maps.Point(17, 34),
                    scaledSize: new google.maps.Size(25, 25)
                };

                // Create a marker for each place.
                markers.push(new google.maps.Marker({
                    map: _self.options.map,
                    icon: icon,
                    title: place.name,
                    position: place.geometry.location
                }));

                if (place.geometry.viewport) {
                    // Only geocodes have viewport.
                    bounds.union(place.geometry.viewport);
                } else {
                    bounds.extend(place.geometry.location);
                }
            });
            _self.options.map.fitBounds(bounds);
        });

    },
    createMarker: function (latitude, longitude, label, markerIcon, infoWindowHtml, objectID, defaultRadius) {
        var _self = this;

        var coordinate = new google.maps.LatLng(latitude, longitude);

        var marker = null;

        if (markerIcon != null) {
            var icon = {
                url: markerIcon,
                scaledSize: {
                    height: 25,
                    width: 25
                }
            }

            marker = new google.maps.Marker({
                position: coordinate,
                title: label,
                animation: _self.options.markerAnimation,
                icon: icon,
                objectID: objectID,
                defaultRadius: defaultRadius
            });
        } else {
            marker = new google.maps.Marker({
                position: coordinate,
                title: label,
                animation: _self.options.markerAnimation,
                objectID: objectID
            });
        }



        google.maps.event.addListener(marker, 'rightclick', function (e) {
            var info = document.getElementById('report_GeoMapping');
            var point = null;
            var proj = _self.options.overlay.getProjection();
            var pos = marker.getPosition();
            var p = proj.fromLatLngToContainerPixel(pos);

            e.pixel.x = p.x;
            e.pixel.y = p.y;

            _self.contextMenu(_self.options, e, point);

            _self.addMenuItem("Create Polygon", 0, marker);
            _self.addMenuItem("Remove Polygon", 0, marker);
            //_self.addMenuItem("Save Polygon", 0, marker);
        });

        //});



        if (infoWindowHtml != null) {
            var infoWindow = new google.maps.InfoWindow({
                content: infoWindowHtml
            });

            /* This needs to be modified,  don't think the context is correct right now */
            google.maps.event.addListener(marker, 'click', function () {
                infoWindow.open(_self.options.map, marker);
            });

            google.maps.event.addListener(marker, 'dblclick', function () {

                _self.GenerateNewPolygon(latitude, longitude, objectID, defaultRadius, label)
            });


        }



        return marker;
    },
    plot: function (marker) {
        var _self = this;

        marker.setMap(_self.options.map);
        _self.options.markers.push(marker);

    },
    zoom: function () {
        var _self = this;
    },
    showWarehouses: function () {
        var _self = this;

        if (_self.options.dispatchLocationData == null) {
            _self.dispatchLocationFetch();
        } else if (_self.options.warehouseMarkers.length == 0) {
            _self.plotWarehouses();
        }
        //_self.addPolygonToMap();
    },
    clearWarehouses: function () {
        var _self = this;

        for (var idx = _self.options.warehouseMarkers.length; idx > 0; idx--) {
            var marker = _self.options.warehouseMarkers.pop();
            marker.setMap(null);
        }

        for (var idx = _self.options.warehouseCircles.length; idx > 0; idx--) {
            var marker = _self.options.warehouseCircles.pop();
            marker.setMap(null);
        }
    },
    dispatchLocationFetch: function () {
        var _self = this;
        var filter = _self.options.filter;
        filter = " ";

        $.ajax({
            type: "GET",
            url: _self.options.whseUrl
            ,dataType: "json"
            //,data: {
            //    "filter": filter
            //}
        }).success(function (data, status, jqxhr) {
            if (data != null)
                if (data.length != null)
                    if (data.length > 0) {
                        _self.options.dispatchLocationData = data;
                        _self.plotWarehouses();
                        //_self.addPolygonToMap();
                    }
        }).error(function (jqxhr, status, error) {
            _self.fetchError(jqxhr, status, error);
        }).complete(function (jqxhr, status) {

        });

    },
    plotWarehouses: function () {
        var _self = this;

        var Dispatchicon = "https://maps.google.com/mapfiles/kml/shapes/factory.png";
        var Apartmenticon = "https://maps.google.com/mapfiles/kml/shapes/dollar.png";
        var Businessicon = "http://maps.google.com/mapfiles/kml/shapes/mechanic.png";
        var Houseicon = "http://maps.google.com/mapfiles/kml/shapes/grocery.png";

        for (var idx = 0; idx < _self.options.dispatchLocationData.length; idx++) {
            var whse = _self.options.dispatchLocationData[idx];

            var latitude = whse.latitude;
            var longitude = whse.longitude;
            var GeogIDN = whse.GeoIDN;

            if ((latitude != 0) || (longitude != 0)) {
                var title = whse.objectType + ' / ' + whse.description;

                var infoWindow = whse.objectType + ' / ' + whse.description + '<br/>';
                if (whse.address1 != null)
                    infoWindow += whse.address1 + "<br/>";
                if (whse.address2 != null)
                    infoWindow += whse.address2 + "<br/>";
                if (whse.city != null)
                    infoWindow += whse.city
                if (whse.state != null)
                    infoWindow += ", " + whse.Region
                if (whse.PostalCode != null)
                    infoWindow += "  " + whse.PostalCode
                if (whse.country != null)
                    infoWindow += "<br/>" + whse.country;

                if (whse.objectType == "House") {
                    icon = Houseicon;
                }

                if (whse.objectType == "Apartment") {
                    icon = Apartmenticon;
                }

                if (whse.objectType == "Business") {
                    icon = Businessicon;
                }

                if (whse.objectType == "Dispatch_Location") {
                    icon = Dispatchicon;
                }
                var marker = _self.plot(_self.createMarker(latitude, longitude, title, icon, infoWindow, whse.objectID, whse.defaultRadius));
                //marker.setMap(_self.options.map);
                //_self.options.warehouseMarkers.push(marker);

                if (whse.Polygon != null) {
                    $.ajax({

                        type: "GET",
                        url: _self.options.geographyPolygonUrl + "/" + whse.GeoIDN,
                        dataType: "json"
                        //, async: false
                    }).success(function (data, status, jqxhr) {
                        if (data != null)
                            if (data.length != null)
                                if (data.length > 0) {
                                    _self.options.dispatchLocationData = data;
                                    if (_self.options.showPolygon == true) {
                                        _self.addPolygon(data);
                                    };
                                    //_self.addPolygonToMap();
                                }
                    }).error(function (jqxhr, status, error) {
                        _self.fetchError(jqxhr, status, error);
                    }).complete(function (jqxhr, status) {
                    });
                }

            }
            _self.autoBounds();
        }

    },


    GenerateNewPolygon: function (latitude, longitude, objectID, defaultRadius, label) {
        var _self = this;
        var center = new google.maps.LatLng(latitude, longitude);
        var polygonPoints = null;
        var polygon = [];

        polygonPoints = _self.generateGeoJSONCircle(center, defaultRadius, 8)

        var whse = objectID;

        //        var point = [idx];
        var whseID = label;
        var warehouse = objectID;
        var GeoIDN = _self.CreateGuid();


        var polygonColor = null;
        var newPolygon = null;


        polygonColor = '#4dd2ff'


        myPolygon = new google.maps.Polygon({
            paths: polygonPoints[0],
            draggable: true, // turn off if it gets annoying
            editable: true,
            strokeColor: "#004d66",
            strokeOpacity: 0.8,
            strokeWeight: 2,
            fillColor: polygonColor,
            fillOpacity: 0.35,
            whse: whseID,
            warehouse: warehouse,
            GeoIDN: GeoIDN
        });

        // }



        //_self.options.myPolygonArray.push(myPolygon);

        myPolygon.setMap(_self.options.map);
        //google.maps.event.addListener(myPolygon, "dragend", _self.getPolygonCoords(myPolygon));

        $.proxy(myPolygon.addListener("mouseover", function () {
            //alert(myPolygon.warehouse);
            //_self.getPolygonCoords(this)
        }), this);

        $.proxy(myPolygon.addListener("click", function () {
            //alert();
            _self.getPolygonCoords(this)
        }), this);

        $.proxy(myPolygon.addListener("rightclick", function () {
            //alert(myPolygon.warehouse);
            _self.getPolygonCoords(this)
        }), this);

        window.setTimeout(function () {

        });

        _self.getPolygonCoords(myPolygon);

        return myPolygon
        //}
    },

    generateGeoJSONCircle: function (center, radius, numSides) {

        var points = [];
        radius = radius * 1609.34
        degreeStep = (360 / numSides) * -1;

        for (var i = 0; i < numSides; i++) {
            var gpos = google.maps.geometry.spherical.computeOffset(center, radius, degreeStep * i);
            new google.maps.LatLng(gpos.lat(), gpos.lng())
            //points.push(gpos.lng(), gpos.lat());



            points.push(new google.maps.LatLng(gpos.lat(), gpos.lng()));

        };

        // Duplicate the last point to close the geojson ring
        points.push(points[0]);



        return [points]

    },


    addPolygon: function (data) {
        var _self = this;
        var polygon = [];
        var whseID = null;
        var warehouse = null;
        var GeoIDN = null;
        //var polygonArray = [];
        var polygonCenter = new google.maps.LatLng(data[0].polygonCenterLat, data[0].polygonCenterLong);

        if (data.length != 0) {
            for (var idx = 0; idx < data.length; idx++) {
                var whse = data[idx];

                var point = [idx];
                whseID = data[idx].shortDesc;
                warehouse = data[idx].whseID;
                GeoIDN = data[idx].GeoIDN;
                // new google.maps.LatLng(data[idx].latitude, data[idx].longitude)

                polygon.push(new google.maps.LatLng(data[idx].latitude, data[idx].longitude));



                var polygonColor = null;
                var newPolygon = null;


                if (data[idx].objectType == 'Dispatch_Location') {
                    polygonColor = '#FF0000'
                }


                if (polygonColor == null) {
                    polygonColor = '#ffff00'
                }

                myPolygon = new google.maps.Polygon({
                    paths: polygon,
                    draggable: true, // turn off if it gets annoying
                    editable: true,
                    strokeColor: polygonColor,
                    strokeOpacity: 0.8,
                    strokeWeight: 2,
                    fillColor: polygonColor,
                    fillOpacity: 0.35,
                    whse: whseID,
                    warehouse: warehouse,
                    GeoIDN: GeoIDN,
                    polygonCenter: polygonCenter
                });

            }

            var infoWindowPolygon = whse.objectType + ' / ' + whse.shortDesc + '<br/>';
            infoWindowPolygon += whse.description;

            var infowindow = new google.maps.InfoWindow({
                size: new google.maps.Size(150, 50)
            });

            //_self.options.myPolygonArray.push(myPolygon);

            myPolygon.setMap(_self.options.map);
            //google.maps.event.addListener(myPolygon, "dragend", _self.getPolygonCoords(myPolygon));

            $.proxy(myPolygon.addListener("mouseover", function () {
                //alert(myPolygon.warehouse);
                //_self.getPolygonCoords(this)
            }), this);

            $.proxy(myPolygon.addListener("click", function (e) {
                infowindow.setContent(infoWindowPolygon);
                infowindow.setPosition(e.latLng);
                infowindow.open(_self.options.map);
            }), this);

            $.proxy(myPolygon.addListener("rightclick", function () {
                //alert(myPolygon.warehouse);
                _self.getPolygonCoords(this)
            }), this);

            //google.maps.event.addListener(myPolygon, 'rightclick', function (e) {
            //    var info = document.getElementById('report_GeoMapping');
            //    var point = null;
            //    var proj = _self.options.overlay.getProjection();
            //    var pos = myPolygon.polygonCenter;
            //    var p = proj.fromLatLngToContainerPixel(pos);



            //    _self.contextMenu(_self.options, e, p);

            //    _self.addMenuItem("Delete Polygon", 0, 'plow');
            //    //_self.addMenuMarkerItem("Create Polygon", coordinate, _self.GenerateNewPolygon(latitude, longitude, objectID));
            //});

            window.setTimeout(function () {
                //google.maps.event.addListener(myPolygon, "dragend", _self.getPolygonCoords(myPolygon));
                //google.maps.event.addListener(myPolygon.getPath, "click", alert());
                ////google.maps.event.addListener(myPolygon.getPath(), "bounds_changed", _self.getPolygonCoords(myPolygon));
                ////google.maps.event.addListener(myPolygon.getPath(), "remove_at", _self.getPolygonCoords(myPolygon));
                //google.maps.event.addListener(myPolygon.getPath(), "set_at", _self.getPolygonCoords(myPolygon));

                //google.maps.event.addListener(myPolygon.getPath(), "click", _self.getPolygonCoords(myPolygon));
                //google.maps.event.addListener(myPolygon.getPath(), "bounds_changed", _self.getPolygonCoords(myPolygon));
            });

            return myPolygon
        }
    },

    DeletePolygon: function (objectID) {
        var _self = this;
        var data = objectID;

        $.ajax({
            type: "PUT",
            url: _self.options.geographyPolygonUrl + "/" + data,
            //data: jsonString,
            contentType: "application/json",
            dataType: "json"
        }).success(function (data, status, jqxhr) {
            if (data != null) {
                if (data != null) {
                    if (typeof data.Status != 'undefined') {
                        switch (data.Status) {
                            case 0:
                                // Save Successful
                                $("#mappingHeader").geoMappingFilter('filterMap');
                            case 1:
                                // Exception Occured
                                if (data.Exception != null)
                                    if (data.Exception.Message != null)
                                        Materialize.toast('ERROR: ' + data.Exception.Message, 2000);
                        }
                    }
                }
            }
        }).error(function (jqxhr, status, error) {
            if (jqxhr != null)
                if (jqxhr.responseJSON != null)
                    if (jqxhr.responseJSON.ExceptionMessage != null) {
                        alert("ERROR 20: " + jqxhr.responseJSON.ExceptionMessage);
                        return;
                    }
            alert("ERROR 21: " + error);
        }).complete(function (jqxhr, status) {
        });
    },
    //addPolygonToMap: function () {
    //    var _self = this
    //    var polygonInsertArray = []
    //    polygonInsertArray = _self.options.myPolygonArray

    //    if (polygonInsertArray.length != 0) {
    //        for (var idx = 0; idx < polygonInsertArray.length; idx++) {
    //            var newPolygon = polygonInsertArray[idx];


    //            newPolygon.setMap(_self.options.map);

    //            //google.maps.event.addListener(newPolygon, "dragend", _self.getPolygonCoords(newPolygon));
    //            //google.maps.event.addListener(newPolygon.getPath(), "insert_at", _self.getPolygonCoords(newPolygon));
    //            //google.maps.event.addListener(newPolygon.getPath(), "remove_at", _self.getPolygonCoords(newPolygon));
    //            //google.maps.event.addListener(newPolygon.getPath(), "set_at", _self.getPolygonCoords(newPolygon));
    //        }


    //    }

    //},
    getPolygonCoords: function (newPolygon) {
        var _self = this

        var len = newPolygon.getPath().getLength();
        var htmlStr = "";
        var vertices = "";
        var whse = newPolygon.whse;
        var warehouse = newPolygon.warehouse;
        var GeoIDN = newPolygon.GeoIDN;
        //var centerLat = newPolygon.polygonCenter.lat();
        //var centerLong = newPolygon.polygonCenter.lng();

        for (var i = 0; i < len; i++) {
            //htmlStr += newPolygon.getPath().getAt(i).toUrlValue(5) + " ; ";
            var vertices = newPolygon.getPath().getAt(i);

            htmlStr += vertices.lng() + " " + vertices.lat() + ","
            //Use this one instead if you want to get rid of the wrap > new google.maps.LatLng(),
            //htmlStr += "" + myPolygon.getPath().getAt(i).toUrlValue(5);
        }
        var dispatchLocationData = {
            "description": whse,
            "DispatchLocationID": warehouse,
            "Polygon": htmlStr,
            "GeoIDN": GeoIDN

        }
        var jsonstring = JSON.stringify(dispatchLocationData);

        $.ajax({
            type: "POST",
            url: _self.options.geographyPolygonUrl,
            dataType: "json",
            contentType: "application/json",
            data: jsonstring
            //, async: false
        }).success(function (data, status, jqxhr) {
            if (data != null)
                if (status == "success") {
                    Materialize.toast(whse + ": Saved Sucessfully", 5000)

                }
        }).error(function (jqxhr, status, error) {
            _self.fetchError(jqxhr, status, error);
            Materialize.toast(whse + ": Not Saved; Try Again", 5000)
        }).complete(function (jqxhr, status) {

        });


    },

    getNewPolygonCoords: function () {
        var _self = this;

        //google.maps.event.addListener(myPolygon, "dragend", _self.getPolygonCoords(myPolygon));
        //google.maps.event.addListener(myPolygon.getPath(), "click", _self.getPolygonCoords(myPolygon));
        //google.maps.event.addListener(myPolygon.getPath(), "bounds_changed", _self.getPolygonCoords(myPolygon));
        //google.maps.event.addListener(myPolygon.getPath(), "remove_at", _self.getPolygonCoords(myPolygon));
        google.maps.event.addListener(myPolygon.getPath(), "set_at", _self.getPolygonCoords(myPolygon));

        //google.maps.event.addListener(myPolygon.getPath(), "click", _self.getPolygonCoords(myPolygon));
        //google.maps.event.addListener(myPolygon.getPath(), "bounds_changed", _self.getPolygonCoords(myPolygon));

    },


    contextMenu: function (opts, e, point) {
        // A way to access 'this' object from inside functions
        var self = this;
        var g = google.maps;

        if ($(self.theMenu).length) {
            $(self.theMenu).remove();
        }

        if (opts.map !== undefined) {
            // Put the map onto the object
            this.theMap = opts.map;

            // Keep track of where you clicked, for the callback functions.
            this.clickedLatLng = null;

            // Create the context menu element
            this.theMenu = $(document.createElement('div'))
                .attr('class', 'contextMenu')

                // .. disable the browser context menu on our context menu
                .bind('contextmenu', function () { return false; })

                // .. append a ul list element
                .append($(document.createElement('ul')))

                // .. then append it to the map object
                .appendTo(this.theMap.getDiv());

            if (point != null) {
                xpoint = point.x,
                    ypoint = point.y
            }
            else {
                xpoint = e.pixel.x,
                    ypoint = e.pixel.y
            }
            // Display and position the menu
            //g.event.addListener(this.theMap, 'rightclick', function (e) {
            // Shorthand some stuff
            var mapDiv = $(self.theMap.getDiv()),
                menu = self.theMenu,
                //x = e.pixel.x,
                //y = e.pixel.y;
                x = xpoint,
                y = ypoint;
            // Hide the context menu if its open
            menu.hide();

            // Save the clicked location
            self.clickedLatLng = e.latLng;

            // Adjust the menu if clicked to close to the edge of the map
            if (x > mapDiv.width() - menu.width())
                x -= menu.width();

            if (y > mapDiv.height() - menu.height())
                y -= menu.height();

            // Set the location and fade in the context menu
            menu.css({ top: y, left: x }).fadeIn(200);
            //});

            // Hide context menu on several events
            $.each('click dragstart zoom_changed maptypeid_changed center_changed'.split(' '), function (i, name) {
                g.event.addListener(self.theMap, name, function () { $(self.theMenu).remove(); });
            });
        }


    },


    addMenuItem: function (name, loc, callback) {
        // If no loc was provided
        //this.MenuMarker.hide();
        if (typeof loc === 'function') {
            callback = loc;
            loc = undefined;
        }

        // A way to access 'this' object from inside functions
        var _self = this,

            // The name turned into camelCase for use in the li id, and anchor href
            idName = name,

            // The li element
            li = $(document.createElement('li'))
                .attr('id', idName);

        // the anchor element
        $(document.createElement('a'))
            .attr('href', '#' + idName).html(name)
            .appendTo(li)

            // Add some nice hover effects
            .hover(function () {
                $(this).parent().toggleClass('hover');
            })

            // Set the click event
            .click(function () {

                // fade out the menu
                _self.theMenu.remove();

                if (idName == "Create Polygon") {
                    _self.GenerateNewPolygon(callback.position.lat(), callback.position.lng(), callback.objectID, callback.defaultRadius)
                }
                if (idName == "Remove Polygon") {
                    _self.DeletePolygon(callback.objectID)
                }
                if (idName == "Save Polygon") {
                    _self.DeletePolygon(callback.objectID)
                }
                // call the callback function - 'this' would refer back to the jQuery object of the item element
                //callback.call(this, _self.options.Map, _self.clickedLatLng);

                // make sure the click doesnt take us anywhere
                return false;
            });

        // If `loc` is a number put it at that location
        if (typeof loc === 'number' && loc < this.theMenu.find('li').length)
            this.theMenu.find('li').eq(loc).before(li);

        // .. else appened it to the end of the menu
        else
            this.theMenu.find('ul').append(li);

        // Return the whole list item
        return li;

    },
    CreateGuid: function () {
        function _p8(s) {
            var p = (Math.random().toString(16) + "000000000").substr(2, 8);
            return s ? "-" + p.substr(0, 4) + "-" + p.substr(4, 4) : p;
        }
        return _p8() + _p8(true) + _p8(true) + _p8();
    }

    //}
    //plotWarehouseRadius: function () {
    //    var _self = this;

    //    if (_self.options.warehouseCircles.length == 0) {
    //        for (var idx = 0; idx < _self.options.warehouseMarkers.length; idx++) {
    //            var marker = _self.options.warehouseMarkers[idx];
    //            if (_self.options.warehouseRadius != null)
    //                if (_self.options.warehouseRadius > 0) {
    //                    var radiusOptions = {
    //                        strokeColor: '#888888',
    //                        strokeOpacity: 0.8,
    //                        strokeWeight: 1,
    //                        fillColor: '#EEEEEE',
    //                        fillOpacity: 0.35,
    //                        map: _self.options.map,
    //                        center: marker.position,
    //                        radius: _self.options.warehouseRadius
    //                    }

    //                    var plotCircle = new google.maps.Circle(radiusOptions);
    //                    _self.options.warehouseCircles.push(plotCircle);
    //                }
    //        }
    //    }
    //},
    //plotWarehouseDistanceTiers: function () {
    //    var _self = this;

    //    var distanceTiers = [
    //        { radius: 241402, color: '#FF0000', opacity: 0.05 },
    //        { radius: 159325, color: '#FFFF00', opacity: 0.08 },
    //        { radius: 80467, color: '#00FF00', opacity: 0.10 }
    //    ];

    //    if (_self.options.warehouseCircles.length == 0) {
    //        for (var tierIdx = 0; tierIdx < distanceTiers.length; tierIdx++) {
    //            for (var idx = 0; idx < _self.options.warehouseMarkers.length; idx++) {
    //                var marker = _self.options.warehouseMarkers[idx];

    //                var radiusOptions = {
    //                    strokeColor: '#888888',
    //                    strokeOpacity: 0.8,
    //                    strokeWeight: 1,
    //                    fillColor: distanceTiers[tierIdx].color,
    //                    fillOpacity: distanceTiers[tierIdx].opacity,
    //                    map: _self.options.map,
    //                    center: marker.position,
    //                    radius: distanceTiers[tierIdx].radius
    //                }

    //                var plotCircle = new google.maps.Circle(radiusOptions);
    //                _self.options.warehouseCircles.push(plotCircle);
    //            }
    //        }
    //    }
    //}
    //,
});