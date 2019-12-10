using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using System.Web.Security;
using TestApp.Models;

namespace TestApp.Controllers
{
    [Authorize]
    public class AccountController : Controller
    {
        //
        // GET: /Account/Login

        [AllowAnonymous]
        public ActionResult Login()
        {
            return View();
        }

        //
        // POST: /Account/Login

        [AllowAnonymous]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Login(LoginModel model, string returnUrl)
        {
            if (ModelState.IsValid)
            {
                //if (Membership.ValidateUser(model.UserName, model.Password))
                //{
                UserAccount user = UserAccount.GetByUsername(model.UserName);
                //check pwd, yes, this should be encrypted
                if (user.passwordText == model.Password)
                {

                    FormsAuthentication.SetAuthCookie(user.ID.ToString(), model.RememberMe);
                    if ((Url.IsLocalUrl(returnUrl)) && (returnUrl != @"/"))
                    {
                        return Redirect(returnUrl);
                    }
                    else
                    {
                        return RedirectToAction("~/UI/Search");
                    }
                }
                }
                else
                {
                    ModelState.AddModelError("", "The user name or password provided is incorrect.");
                }
            //}

            // If we got this far, something failed, redisplay form
            return View(model);
        }

        //
        // GET: /Account/LogOff

        public ActionResult LogOff()
        {
            FormsAuthentication.SignOut();

            return RedirectToAction("About", "Home");
        }
    }
}