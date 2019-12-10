<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Material.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="scriptsContent" ContentPlaceHolderID="Head" runat="server"></asp:Content>

<asp:Content ID="Title" ContentPlaceHolderID="HeaderTitle" runat="server">LOGIN</asp:Content>

<asp:Content ID="loginContent" ContentPlaceHolderID="MainContent" runat="server">
  
<form  method="post" onsubmit="/Account/Login">
    <%: Html.AntiForgeryToken() %>
    <div style="width: 800px; margin-left: auto; margin-right: auto; margin-top: 50px;">
        <div class="validation-summary-valid" data-valmsg-summary="true"><ul><li style="display:none"></li></ul></div>
        <ul>
            <li data-role="fieldcontain">
                <div class="input-field col s6">
                  <input id="UserName" name="UserName"  type="text" data-val="true" data-val-required="Username is required!"/>
                  <label for="UserName">Username</label>
                </div>             
            </li>
            <li data-role="fieldcontain">
                <div class="input-field col s6">
                  <input id="Password" name="Password"  type="password"  data-val="true" data-val-required="Password is required!"/>
                  <label for="Password">Password</label>
                </div>               
            </li>
            <br />
            <li data-role="fieldcontain">
                  <input type="checkbox" id="RememberMe" name="RememberMe" value="true" class="filled-in"  data-val="true" data-val-required="Remember Me is required!" />
                  <span>Remember Me?</span>


            </li>
            <br />

            <li data-role="fieldcontain">
                <button class="btn waves-effect waves-light" type="submit" name="action">Login
                    <i class="mdi-content-send right"></i>
                </button>
            </li>
        </ul>
    </div>
    
    <script>
        $(document).ready(function () {
            window.setTimeout(function () {
                $("[for='UserName']").addClass("active");
                $("[for='Password']").addClass("active");

                $("#Password").click();

                $("#master-menu-slide-out").hide();
                $("#lnkLogoff").hide();

            }, 250);

        });
    </script>
</form>
</asp:Content>