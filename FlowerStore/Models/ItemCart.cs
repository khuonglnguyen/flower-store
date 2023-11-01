using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace FlowerStore.Models
{
    public class ItemCart
    {
        public int ProductID { get; set; }
        public int Quantity { get; set; }
        public string ProductName { get; set; }
        public int ProductPrice { get; set; }
        public string ProductImage { get; set; }
    }
}