using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Runtime.Serialization;
using System.Web.Mvc;
using Dapper;
using System.Data.SqlClient;
using System.Data;

namespace TestApp.Models
{
    #region table fields
    [DataContract]
    public class UserAccount
    {
     

        [DataMember]
        public string email { get; set; }

        [DataMember]
        public string FName { get; set; }
        [DataMember]
        public string Lname { get; set; }

        [DataMember]
        public bool Active { get; set; }

        [DataMember]
        public String passwordText { get; set; }

        [DataMember]
        public Guid UserID { get; set; }
        [DataMember]
        public Guid ID { get; set; }

        [DataMember]
        public bool superUser { get; set; }

        [DataMember]
        public DateTime lastLogin { get; set; }


        [DataMember]
        public Guid EntityID { get; set; }

        #endregion


        public static UserAccount GetByPrinciple(System.Security.Principal.IPrincipal principle)
        {
            UserAccount result = new UserAccount();

            if (principle != null)
                if (principle.Identity != null)
                    result = GetByUsername(principle.Identity.ToString());
        
                                  

            return result;
        }

        public static UserAccount GetByUsername(string UserEmail)
        {
            UserAccount result = new UserAccount();
            using (SqlConnection conn = new SqlConnection(System.Configuration.ConfigurationManager.AppSettings["CONN_STRING"]))
            {
                conn.Open();

                DynamicParameters args = new DynamicParameters();
                args.Add("@UserEmail", UserEmail);

                var results = conn.Query<UserAccount>("dbo.get_User", args, commandType: CommandType.StoredProcedure);

                //results = result;

                conn.Close();


                foreach (UserAccount rec in results)
                {
                    result = rec;

                }
            }

            return result;
        }


    }

}
    


