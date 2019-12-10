using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace TestApp.Controllers.UI
{
    public class UIController : Controller
    {
        // GET: UI
        public ActionResult Search()
        {
            return View();
        }

        // GET: UI
        public ActionResult Mapping()
        {
            return View();
        }
    }
}