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
    public class LocationController : ApiController
    {
        // GET: Location
        public LocationCollection Get()
        {
            LocationCollection recs = new LocationCollection();

            string language = Thread.CurrentThread.CurrentCulture.TwoLetterISOLanguageName;
            UserAccount user = UserAccount.GetByPrinciple(User);
            if (user != null)
            {

                using (SqlConnection conn = new SqlConnection(System.Configuration.ConfigurationManager.AppSettings["CONN_STRING"]))
                {
                    //DynamicParameters args = new DynamicParameters();
                    //args.Add("@UserID", user.UserID.ToString());

                    var report = conn.Query<Location>("dbo.report_Customer_List", null, commandType: CommandType.StoredProcedure);

                    foreach (Location rec in report)
                    {
                        
                            recs.Add(rec);

                    }
                }
            }

            return recs;
        }
    }
}