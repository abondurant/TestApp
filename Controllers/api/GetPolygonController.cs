using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Data.SqlTypes;
using System.Data;
using System.Data.SqlClient;
using System.Threading;
using System.Web.Http;
using System.Runtime.Serialization;
using System.Data.SqlTypes;
using TestApp.Models;
using Dapper;


namespace TestApp.Controllers.api
{
    //public class GetPolygonForObjectController : ApiController
    //{
    //    // 4326 is most common coordinate system used by GPS/Maps
    //    // 4326 format puts LONGITUDE first then LATITUDE
    //    private static int _coordinateSystem = 4326;


    //    public ListForGeoMappingController.GeoMappingCollection Get(Guid id)
    //    {
    //        string filter = null;
    //        Guid dispatchLocationID = id;
    //        string sort = null;
    //        int pageNumber = 1;
    //        int pageSize = 10000;
    //        ListForGeoMappingController.GeoMappingCollection recs = new ListForGeoMappingController.GeoMappingCollection();

    //        //RecordManagementRequest request = new RecordManagementRequest(pageNumber, pageSize, sort, filter);

    //        string language = Thread.CurrentThread.CurrentCulture.TwoLetterISOLanguageName;
    //        UserAccount user = UserAccount.GetByPrinciple(User);
    //        if (user != null)
    //        {
    //            try
    //            {
    //                using (SqlConnection conn = new SqlConnection(System.Configuration.ConfigurationManager.AppSettings["CONN_STRING"]))
    //                {
    //                    conn.Open();

    //                    DynamicParameters args = new DynamicParameters();
    //                    args.Add("@IDN", id.ToString());

    //                    var results = conn.Query<GeoMapping>("dbo.report_Generic_List_Coordinates_ForGeoMapping", args, commandType: CommandType.StoredProcedure);

    //                    conn.Close();


    //                    foreach (GeoMapping rec in results)
    //                    {
    //                        if (rec.latitude != 0)
    //                            recs.Add(rec);

    //                    }
    //                }
    //            }
    //            catch (Exception ex)
    //            {

    //            }
    //        }

    //        return recs;
    //    }

    //    public GeoMapping Post(GeoMapping Warehouse)
    //    {
    //        var results = new GeoMapping();

    //        try
    //        {
    //            UserAccount user = UserAccount.GetByPrinciple(User);
    //            if (user != null)
    //            {
    //                results = ListForGeoMappingController.GeoMappingCollection.Save(user.ID, Warehouse);
    //            }
    //        }
    //        catch (Exception e)
    //        {
  
    //        }

    //        return results;
    //    }
    //    [System.Web.Http.HttpPut]
    //    public GeoMapping Put(Guid ID)
    //    {
    //        var results = new GeoMapping();

    //        try
    //        {
    //            UserAccount user = UserAccount.GetByPrinciple(User);
    //            if (user != null)
    //            {
    //                ListForGeoMappingController.GeoMappingCollection.Delete(ID, user.ID);
    //            }
    //            else
    //            {
    //                throw new Exception("User Not Authenticated");
    //            }
    //        }
    //        catch (Exception e)
    //        {

    //        }

    //        return results;
    //    }
    //}
}
