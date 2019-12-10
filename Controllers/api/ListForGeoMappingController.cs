using System.Web;
using System.Data.SqlClient;
using System.Threading;
using System.Web.Http;
using TestApp.Models;
using System.Collections.Generic;
using System;
using Dapper;
using System.Data;
using System.Web.Mvc;

namespace TestApp.Controllers.api
{
    public class ListForGeoMappingController : ApiController
    {
        public GeoMappingCollection Get()
        {
            //string filter = null;
            string sort = null;
            int pageNumber = 1;
            int pageSize = 1000;
            GeoMappingCollection recs = new GeoMappingCollection();

            string language = Thread.CurrentThread.CurrentCulture.TwoLetterISOLanguageName;
            UserAccount user = UserAccount.GetByPrinciple(User);
            if (user != null)
            {

                using (SqlConnection conn = new SqlConnection(System.Configuration.ConfigurationManager.AppSettings["CONN_STRING"]))
                {

                    var report = conn.Query<GeoMapping>("dbo.report_Generic_ListForGeoMapping", null, commandType: CommandType.StoredProcedure);

                    foreach (GeoMapping rec in report)
                    {
                        if (rec.latitude != 0)
                            recs.Add(rec);

                    }
                }
            }

            return recs;
        }

     
    }
}