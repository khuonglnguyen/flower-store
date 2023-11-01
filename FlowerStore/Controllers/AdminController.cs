using FlowerStore.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace FlowerStore.Controllers
{
    public class AdminController : Controller
    {
        ShoppingEntities db = new ShoppingEntities();
        // GET: Admin
        public ActionResult Index()
        {
            if (CheckRole("Admin"))
            {

            }
            else
            {
                return RedirectToAction("Index", "Home");
            }
            ViewBag.TotalOrder = db.Orders.Count(x => x.Status == "Complete");
            ViewBag.TotalMoney = db.Orders.Where(x => x.Status == "Complete").ToList().Sum(x => x.OrderDetails.Sum(n => n.ProductPrice * n.Quantity));
            ViewBag.TotalClient = db.Users.Count(x => x.UserType.Name == "Client");
            ViewBag.TotalProduct = db.Products.Count(x => x.IsActive == true);
            return View();
        }
        public bool CheckRole(string type)
        {
            Models.User user = Session["User"] as Models.User;
            if (user != null && user.UserType.Name == type)
            {
                return true;
            }
            return false;
        }
    }
}