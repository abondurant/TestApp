using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Dapper;
using System.Data;
using System.Data.SqlClient;
using System.Runtime.Serialization;


namespace TestApp.Models
{
    [DataContract]
    public class Location
    {

        #region properties
        [DataMember]
        public Guid addressID { get; set; }
        [DataMember]
        public Guid CustomerID { get; set; }

        [DataMember]
        public Guid OwnerID { get; set; }
        [DataMember]
        public string Address1 { get; set; }
        [DataMember]
        public string Address2 { get; set; }
        [DataMember]
        public string City { get; set; }
        [DataMember]
        public string State { get; set; }
        [DataMember]
        public string Region { get; set; }
        [DataMember]
        public string Country { get; set; }
        [DataMember]
        public string PostalCode { get; set; }
        [DataMember]
        public double Longitude { get; set; }
        [DataMember]
        public double Latitude { get; set; }
        [DataMember]
        public string EntityName { get; set; }
        [DataMember]
        public string Dispatch_Location_Name { get; set; }
        [DataMember]
        public string CustomerName { get; set; }
        [DataMember]
        public string CustomerFirstName { get; set; }
        [DataMember]
        public string CustomerLastName { get; set; }
        [DataMember]
        public string DispatchLocationForAddress { get; set; }
        #endregion
    }
    public class LocationCollection : List<Location>
    {
        
    }
}