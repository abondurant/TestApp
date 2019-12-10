<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Material.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="Head" runat="server">

     <%--<script src="https://maps.googleapis.com/maps/api/js?client=gme-systemsmaintenance&sensor=false&libraries=geometry&libraries=places"></script>--%>
     <%--<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBCCD4XdV3XjvVCJ1j-4wcARLVUq2hRNA4&sensor=false&libraries=geometry&libraries=places"></script>--%>
    <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBCCD4XdV3XjvVCJ1j-4wcARLVUq2hRNA4&sensor=false&libraries=geometry&libraries=places"></script>
    <%--<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBCCD4XdV3XjvVCJ1j-4wcARLVUq2hRNA4&libraries=geometry"></script>--%>
     <%--<script src="https://maps.googleapis.com/maps/api/places?key=AIzaSyBCCD4XdV3XjvVCJ1j-4wcARLVUq2hRNA4&sensor=false"></script>--%>
    <script src="<% = ResolveUrl("~/Content/materialize.css") %>"></script>
    <script src="<% = ResolveUrl("~/Scripts/materialize.js") %>"></script>
    <script src="<% = ResolveUrl("~/Scripts/DispatchLocationMapping.js") %>"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeaderMenu" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="HeaderTitle" runat="server">
    Polygon Geo Mapping

</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="NavigationButtons" runat="server">


    
        <a id="lnkSeeList" name="lnkSeeList" href="javascript:void(0);" class="waves-effect waves-light" onclick="seeList();" title="See List"><i class="medium material-icons">menu</i>

    </a>

</asp:Content>

<asp:Content ID="Content5" ContentPlaceHolderID="MainContent" runat="server">


    <style>
                .hidden {
            display:none;
        }


    </style>

    


    <div id="report" class="col s12">

                    <div id="report_GeoMapping" class="col s12">
                     </div>
                

   
                
     </div>

    <style>

        .pac-card {
        margin: 10px 10px 0 0;
        border-radius: 2px 0 0 2px;
        box-sizing: border-box;
        -moz-box-sizing: border-box;
        outline: none;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.3);
        background-color: #fff;
        font-family: Roboto;
      }

      #pac-container {
        padding-bottom: 12px;
        margin-right: 12px;
      }

      .pac-controls {
        display: inline-block;
        padding: 5px 11px;
      }

      .pac-controls label {
        font-family: Roboto;
        font-size: 13px;
        font-weight: 300;
      }

      #pac-input {
        background-color: #fff;
        font-family: Roboto;
        font-size: 15px;
        font-weight: 300;
        margin-left: 12px;
        padding: 0 11px 0 13px;
        text-overflow: ellipsis;
        width: 400px;
      }

      #pac-input:focus {
        border-color: #4d90fe;
      }

    .contextMenu {
	    position: absolute;
	    z-index: 1000;

	    display:none;

	    min-width: 120px;

	    background: #eee;
	    border:1px solid #777;

    }

    .contextMenu ul {

	    padding: 3px 0px;
	    margin: 0px;

	    border: solid 1px #fff;
    }

    .contextMenu li {
	    list-style: none;
	    padding: 0px 1px;
	    margin: 0px;
    }
    .contextMenu a {
	    display: block;
	    color: #000;
	    text-decoration: none;
	    line-height: 22px;
	    height: 22px;
	    padding: 1px 8px;
    }

    .contextMenu li.hover a {
	    padding: 0px 7px;
	    background-color: #DFE6F5;
	    border: 1px solid #A2C1FA;
	    border-radius:2px;
    }

        .contextMenu li.separator div {
            margin: 3px 0px;
            border-top: solid 1px #ccc;
            border-bottom: solid 1px #fff;
        }

 .contextMenuMarker {
	    position: absolute;
	    z-index: 1000;

	    display:none;

	    min-width: 120px;

	    background: #eee;
	    border:1px solid #777;

    }

    .contextMenuMarker ul {

	    padding: 3px 0px;
	    margin: 0px;

	    border: solid 1px #fff;
    }

    .contextMenuMarker li {
	    list-style: none;
	    padding: 0px 1px;
	    margin: 0px;
    }
    .contextMenuMarker a {
	    display: block;
	    color: #000;
	    text-decoration: none;
	    line-height: 22px;
	    height: 22px;
	    padding: 1px 8px;
    }

    .contextMenuMarker li.hover a {
	    padding: 0px 7px;
	    background-color: #DFE6F5;
	    border: 1px solid #A2C1FA;
	    border-radius:2px;
    }

    .contextMenuMarker li.separator div {
	    margin: 3px 0px;
	    border-top: solid 1px #ccc;
	    border-bottom: solid 1px #fff;
    }

    </style>
    <%--<div id="placeHolder"></div>--%>

    <script>
        var _sessionID = '<% = System.Web.HttpContext.Current.Session.SessionID %>';



        $(window).resize(function () {
            $("#report_GeoMapping").height($(window).height() - $('[data-role="header"]').height());
        });

        $("#report_GeoMapping").height($(window).height() - $('[data-role="header"]').height());

        $("#report_GeoMapping").DispatchLocationMapping({
            maxZoom: 15,
            scaledSize: {
                height: 45,
                width: 45
            },
            spiderfy: true
        });


        function showWhseGeoMapping() {


            try {
                $("#report_GeoMapping").DispatchLocationMapping({
                    "url": "<% = ResolveUrl("~/Scripts/materialize.js") %>",
                    "features": 15,
                    "labelField": "Dispatch Mapping",
                    "maxZoom": 15,
                    "latitudeField": "latitude",
                    "longitudeField": "longitude",
                    "callbackBuildInfoWindow": buildWindow(),
                    "showPolygon": true,
                    "mode": "edit",
                    "filter": "",
                    "baseURL": "<% = ResolveUrl("~/") %>",
                    "whseUrl":  "<% = ResolveUrl("~/api/ListForGeoMapping") %>",
                   // "userID": _userID,
                    "geographyPolygonUrl": "<% = ResolveUrl("~/api/GetPolygonForObject") %>",
                    "callbackCreateRequest": function (pagingData) {
                    var serviceRequest = {
                        url: "<% = ResolveUrl("~/api/ListForGeoMapping") %>",
                        type: "GET",
                        contentType: "json",
                        json: {
                            "filter": " "

                        }
                    }

                    return serviceRequest;
                },
                "callbackBuildInfoWindow": function (data) {
                    var infoWindow = "";
                    infoWindow = 'Build Your Own Service Area' + "<br/>";
                    infoWindow += data.whseID;

                    return infoWindow;
                },
                "callbackBuildMarkerIcon": function (data) {
                   
                        return "https://maps.google.com/mapfiles/kml/shapes/dollar.png";
                    
                }
                });

                window.setTimeout(function () {

                }, 3);



            }
            catch (exc) {
                alert('report_GeoMapping: ' + exc);
            }
        } 

   
        function buildWindow(whse) {

            var infoWindow = 'Build Your Own Dispatch Area';
            return infoWindow;
        }

        function savePolygon() {
            $("#report_GeoMapping").DispatchLocationMapping('getNewPolygonCoords');

        }

 



        $(document).ready(function () {
            showWhseGeoMapping();
            $("#report_GeoMapping").DispatchLocationMapping('fetch');
            $("#report_GeoMapping").DispatchLocationMapping("showWarehouses");
                        $('.sidenav').sidenav();
            //showMappingHeaderReport();
        });

        
        function seeList() {
             var url = "<% = ResolveUrl("~/") %>" + "UI/Search"
            window.open(url);
        }


        </script>
</asp:Content>
