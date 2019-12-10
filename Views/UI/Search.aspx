<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Material.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="Head" runat="server">

    <%--<script src="<% = ResolveUrl("~/Content/materialize.css") %>"></script>--%>
   <%-- <script src="<% = ResolveUrl("~/Scripts/materialize.js") %>"></script>--%>
    <script type="text/javascript" src="/Scripts/materialize.js"></script>
     <link type="text/css" rel="stylesheet" href="/Content/materialize.css"  media="screen,projection"/>

</asp:Content>




<asp:Content ID="Content3" ContentPlaceHolderID="HeaderTitle" runat="server">
    Dispatch Search
</asp:Content>


<asp:Content ID="Content4" ContentPlaceHolderID="NavigationButtons" runat="server">

<%--    <a id="menu-option-app-main" href="#" data-activates="nav-servers" class="waves-effect waves-light">
	    <i id="main-config" title="Application Menu" class="mdi-action-list"></i>
    </a>--%>


        <a id="lnkSeeMap" name="lnkSeeMap" href="javascript:void(0);" class="waves-effect waves-light" onclick="seeMap();" title="See Map"><i class="medium material-icons">map</i>

    </a>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
        <style>
        .rowA {
            background-color: lightblue;
        }
        </style>

    <%-- <ul class="collapsible" data-collapsible="accordion">

        <li>
            <div class="collapsible-header"><i class="material-icons">search</i>Search Criteria</div>

            <div class="collapsible-body">
         <style>

            .collapsible-body {
                overflow: visible;
            }
            .docDropSpan_dragover {
                background-color: red;
            }

         </style>

                <div class="row">
                    <div class="col s3">
                        <div class="input-field">
                            <input name="acinput" id="customer" type="text" class="validate" data-filterfield="customerName" data-filterdatatype="string" data-filtergroup="QuoteSearch" data-filterfuzzy="BOTH" />
                            <label for="customer"><span data-lang="30">Customer</span></label>
                        </div>
                    </div>
                    <div class="col s3">
                        <div class="input-field">
                            <input name="acinput" id="entity" type="text" class="validate"  />
                            <label for="entity">Entity</label>
                        </div>
                    </div>
                    <div class="col s3">
                        <div class="input-field">
                            <input name="acinput" id="dispatchLocation" type="text" class="validate"  />
                            <label for="dispatchLocation">Dispatch Location</label>
                        </div>
                    </div>
                </div>
            </div>
        </li>
    </ul>
    --%>
     <div id="report"></div>


  <%--  <div id="placeHolder"></div>--%>

    <script>



        function getLocationInfo() {
            var _self = this;
            var filter = null;

            $.ajax({
                type: "GET",
                url: "<% = ResolveUrl("~/api/Location") %>"
                , dataType: "json"

            }).success(function (data, status, jqxhr) {
                if (data != null)
                    if (data.length != null) {
                        var s = '<div class="row striped">';
                        s += '<div class="col s2">Customer</div>';
                        s += '<div class="col s2">Address</div>';
                        s += '<div class="col s2">City</div>';
                        s += '<div class="col s2">Region</div>';
                        s += '<div class="col s2">PostalCode</div>';
                        //s += '<div class="col s2">Country</div>';
                        s += '<div class="col s2">Dispatch Loc</div>';
                        s += '</div>';

                        var sClass = "rowA";
                        if (data.length > 0) {
                            $.each(data, function (index, rec) {
                                if (sClass == "rowA")
                                    sClass = "";
                                else
                                    sClass = "rowA";
                                s += '<div class="row ' + sClass + '">';
                                s += '<div class="col s2 "><a class="lnkcustomer" href="javascript:void(0);" customerid="' + rec.CustomerID + '">' + rec.CustomerName + '</a></div>';
                                s += '<div class="col s2">' + rec.Address1 + '</div>';
                                s += '<div class="col s2">' + rec.City + '</div>';
                                s += '<div class="col s2">' + rec.Region + '</div>';
                                s += '<div class="col s2">' + rec.PostalCode + '</div>';
                                //s += '<div class="col s2">' + rec.Country + '</div>';
                                 s += '<div class="col s2">' + rec.DispatchLocationForAddress + '</div>';
                                s += '</div>';
    
                            });

                        }
                        $("#report").html(s);

                        $(".lnkcustomer").click(function () {
                            openAddress(this);
                        });
                    }
                    }).error(function (jqxhr, status, error) {
                        //_self.fetchError(jqxhr, status, error);
                    }).complete(function (jqxhr, status) {

                    });
        
 }
        function openAddress(el) {
            var id = $(el).attr("customerid");
            alert(id);
        }

        function seeMap() {
             var url = "<% = ResolveUrl("~/") %>" + "UI/Mapping"
            window.open(url);
        }

        $(document).ready(function () {
            $('.sidenav').sidenav();
            getLocationInfo()

        });


</script>
</asp:Content>