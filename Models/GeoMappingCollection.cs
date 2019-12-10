using System;
using System.Collections.Generic;
using TestApp.Models;
using Dapper;
using System.Data;
using System.Web.Mvc;
using System.Data.SqlClient;
using System.Configuration;

namespace TestApp.Models
{
    public class GeoMappingCollection : List<GeoMapping>
    {
        public string Error = "";
        public static GeoMappingCollection Fill(Guid fkid, Guid zUserID
                                    )
        {
            GeoMappingCollection recs = new GeoMappingCollection();
            try
            {
                using (SqlConnection cn = new SqlConnection(System.Configuration.ConfigurationManager.AppSettings["CONN_STRING"]))
                {
                    cn.Open();

                    var results = cn.Query<GeoMapping>("select * from vw_GeoMapping order by objecttype, shortdesc",
                                                                    null,
                                                                    commandType: CommandType.Text
                                                  );


                    cn.Close();
                    //get data into objects
                    foreach (GeoMapping i in results)
                    {
                        recs.Add(i);
                    }
                }
            }
            catch (Exception ex)
            {

            }
            return recs;
        }

        public static GeoMapping Save(Guid userID, GeoMapping DispatchLocation)
        {
            var results = new GeoMapping();



            //results.Id = DispatchLocation.DispatchLocationID.ToString();


            try
            {
                using (SqlConnection conn = new SqlConnection(System.Configuration.ConfigurationManager.AppSettings["CONN_STRING"]))
                {
                    conn.Open();

                    //var args = StoredProcedureParameterAttribute.getParameters(Warehouse);
                    var args = new DynamicParameters();
                    args.Add("@userID", userID);
                    args.Add("@DispatchLocationID", DispatchLocation.DispatchLocationID.ToString());
                    args.Add("@PolygonID", DispatchLocation.GeoIDN.ToString());
                    args.Add("@polygon", DispatchLocation.Polygon.ToString());

                    conn.Execute("dbo.Update_GeoMapping_Coordinates", args, commandType: CommandType.StoredProcedure);

                    conn.Close();
                }
            }
            catch (Exception e)
            {
                //results.Status = SAVE_STATUS.ERROR;
                //results.Exception = new ExceptionData(e);
            }

            return results;
        }

        public static GeoMapping Delete(Guid objectID, Guid userID)
        {
            //SaveResults results = new SaveResults();
            var results = new GeoMapping();

            try
            {
                using (SqlConnection conn = new SqlConnection(System.Configuration.ConfigurationManager.AppSettings["CONN_STRING"]))
                {
                    var args = new DynamicParameters();

                    args.Add("@objectID", objectID);
                    args.Add("@userID", userID);
                    conn.Open();

                    conn.Execute("Geomapping_Delete_Polygon", args, null, null, CommandType.StoredProcedure);

                    conn.Close();
                }
            }
            catch (Exception e)
            {
                //results.Status = SAVE_STATUS.ERROR;
                //results.Exception = new ExceptionData(e);
            }

            return results;
        }

    }
}