using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

using System.Reflection;

namespace TestApp
{
    public static class THEME
    {
        /*
			Reference Color Pallets at:
		 * http://materializecss.com/color.html
		 */

        public static string APPLICATION_NAME = "Test Mapping App";

        public static string PRIMARY_COLOR = "4fc3f7";
        public static string ACCENT_COLOR_1 = "80d8ff";
        public static string ACCENT_COLOR_2 = "40c4ff";
        public static string ACCENT_COLOR_3 = "00b0ff";
        public static string ACCENT_COLOR_4 = "0091ea";
        public static string SLIDE_OUT_MENU_FILL = "light-blue";

        public static string GET_VERSION()
        {
            string myVersion = "";

            try
            {
                Assembly web = Assembly.Load("App_Code");
                AssemblyName webName = web.GetName();
                myVersion = webName.Version.ToString();
            }
            catch (Exception e1)
            {
                try
                {
                    Assembly web = Assembly.GetExecutingAssembly();
                    AssemblyName webName = web.GetName();

                    myVersion = webName.Version.ToString();
                }
                catch (Exception e2)
                {
                }
            }

            return myVersion;
        }
    }
}