using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Runtime.Serialization;

namespace TestApp.Models
{

    [DataContract]
    public class GeoMapping
    {
        #region table fields
        //float
        [DataMember]
        public float latitude { get; set; }

        [DataMember]
        public float longitude { get; set; }
        [DataMember]
        public float polygonCenterLat { get; set; }

        [DataMember]
        public float polygonCenterLong { get; set; }
        //uniqueidentifier
        [DataMember]
        public Guid addressID { get; set; }

        [DataMember]
        public Guid DispatchLocationID { get; set; }


        [DataMember]
        public Guid objectID { get; set; }


        [DataMember]
        public Guid GeoIDN { get; set; }
        [DataMember]
        public string description { get; set; }

        //varchar
        [DataMember]
        public string address1 { get; set; }

        [DataMember]
        public string address2 { get; set; }

        [DataMember]
        public string city { get; set; }

        [DataMember]
        public string country { get; set; }

        [DataMember]
        public string Region { get; set; }

        [DataMember]
        public string PostalCode { get; set; }
        [DataMember]
        public string Polygon { get; set; }
        [DataMember]
        public string objectType { get; set; }

        [DataMember]
        public string DispatchLocationForAddress { get; set; }


        [DataMember]
        public decimal defaultRadius { get; set; }

        [DataMember]
        public string EntityName { get; set; }

        [DataMember]
        public Guid EntityID { get; set; }
        #endregion

    }

    public class GeoMappingPost
    {
        [DataMember]
        public string description { get; set; }

        [DataMember]
        public Guid DispatchLocationID { get; set; }

        [DataMember]
        public string Polygon { get; set; }


        [DataMember]
        public Guid GeoIDN { get; set; }
    }
}