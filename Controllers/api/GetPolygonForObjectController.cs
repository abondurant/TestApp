using System;
using System.Data.SqlClient;
using System.Threading;
using System.Web.Http;
using TestApp.Models;
using System.Collections.Generic;
using System;
using Dapper;
using System.Data;
using System.Web.Mvc;
using TestApp.Models;

namespace TestApp.Controllers.api
{
    public class GetPolygonForObjectController : ApiController
    {
        public GeoMappingCollection Get(Guid id)
        {
            string filter = null;
            Guid dispatchLocationID = id;
            string sort = null;
            int pageNumber = 1;
            int pageSize = 10000;
            GeoMappingCollection recs = new GeoMappingCollection();

            //RecordManagementRequest request = new RecordManagementRequest(pageNumber, pageSize, sort, filter);

            string language = Thread.CurrentThread.CurrentCulture.TwoLetterISOLanguageName;
            UserAccount user = UserAccount.GetByPrinciple(User);
            if (user != null)
            {
                try
                {
                    using (SqlConnection conn = new SqlConnection(System.Configuration.ConfigurationManager.AppSettings["CONN_STRING"]))
                    {
                        conn.Open();

                        DynamicParameters args = new DynamicParameters();
                        args.Add("@IDN", id.ToString());

                        var results = conn.Query<GeoMapping>("dbo.report_Generic_List_Coordinates_ForGeoMapping", args, commandType: CommandType.StoredProcedure);

                        conn.Close();


                        foreach (GeoMapping rec in results)
                        {
                            if (rec.latitude != 0)
                                recs.Add(rec);

                        }
                    }
                }
                catch (Exception ex)
                {

                }
            }

            return recs;
        }
        public GeoMapping Post(GeoMapping dispatchLocationData)
        {
            var  results = new GeoMapping();
            try
            {
                UserAccount user = UserAccount.GetByPrinciple(User);
                if (user != null)
                {
                     GeoMappingCollection.Save(user.ID, dispatchLocationData);
                }
            }
            catch (Exception e)
            {

            }

            return results;
        }
        [System.Web.Http.HttpPut]
        public GeoMappingCollection Put(Guid ID)
        {
            var results = new GeoMappingCollection();
            try
            {
                UserAccount user = UserAccount.GetByPrinciple(User);
                if (user != null)
                {
                    GeoMappingCollection.Delete(ID, user.ID);
                }
                else
                {
                    throw new Exception("User Not Authenticated");
                }
            }
            catch (Exception e)
            {

            }

            return results;
        }
    }

}
