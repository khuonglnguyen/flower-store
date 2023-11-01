using FlowerStore.Models;
using DocumentFormat.OpenXml.Vml.Office;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace FlowerStore.Controllers
{
    public class ProductManageController : Controller
    {
        ShoppingEntities db = new ShoppingEntities();
        public bool CheckRole(string type)
        {
            Models.User user = Session["User"] as Models.User;
            if (user != null && user.UserType.Name == type)
            {
                return true;
            }
            return false;
        }
        // GET: ProductManage
        public ActionResult Index(string keyword = "")
        {
            if (CheckRole("Admin"))
            {

            }
            else
            {
                return RedirectToAction("Index", "Admin");
            }
            List<Product> products = new List<Product>();
            if (keyword != "")
            {
                products = db.Products.Where(x => x.Name.Contains(keyword)).ToList();
            }
            else
            {
                products = db.Products.Where(x => x.Name.Contains(keyword)).ToList();
            }
            return View(products);
        }
        public ActionResult ToggleActive(int ID)
        {
            Product product = db.Products.Find(ID);
            product.IsActive = !product.IsActive;
            db.SaveChanges();
            return RedirectToAction("Index");
        }
        public ActionResult Details(int ID)
        {
            if (CheckRole("Admin"))
            {

            }
            else
            {
                return RedirectToAction("Index", "Admin");
            }
            Product product = db.Products.Find(ID);
            ViewBag.CategoryList = db.Categories.ToList();
            return View(product);
        }
        [HttpPost]
        public ActionResult Edit(Product product, HttpPostedFileBase[] ImageUpload)
        {
            Product productUpdate = db.Products.Find(product.ID);
            productUpdate.Name = product.Name;
            productUpdate.Price = product.Price;
            productUpdate.Quantity = product.Quantity;
            productUpdate.CategoryID = product.CategoryID;
            productUpdate.Description = product.Description;

            for (int i = 0; i < ImageUpload.Length; i++)
            {
                //Check content image
                if (ImageUpload[i] != null && ImageUpload[i].ContentLength > 0)
                {
                    //Get file name
                    var fileName = Path.GetFileName(ImageUpload[i].FileName);
                    //Get path
                    var path = Path.Combine(Server.MapPath("~/Content/images"), fileName);
                    //Check exitst
                    if (!System.IO.File.Exists(path))
                    {
                        //Add image into folder
                        ImageUpload[i].SaveAs(path);
                    }
                }
            }

            if (ImageUpload[0] != null)
            {
                System.IO.File.Delete(Server.MapPath("~/Content/images/" + productUpdate.Image1));
                productUpdate.Image1 = ImageUpload[0].FileName;
            }
            if (ImageUpload[1] != null)
            {
                System.IO.File.Delete(Server.MapPath("~/Content/images/" + productUpdate.Image2));
                productUpdate.Image2 = ImageUpload[1].FileName;
            }
            if (ImageUpload[2] != null)
            {
                System.IO.File.Delete(Server.MapPath("~/Content/images/" + productUpdate.Image3));
                productUpdate.Image3 = ImageUpload[2].FileName;
            }
            db.SaveChanges();

            ViewBag.CategoryList = db.Categories.ToList();
            ViewBag.Message = "Cập nhật thành công";
            return View("Details", productUpdate);
        }
        public ActionResult Edit()
        {
            return RedirectToAction("Index");
        }
        public ActionResult Add()
        {
            if (CheckRole("Admin"))
            {

            }
            else
            {
                return RedirectToAction("Index", "Admin");
            }
            ViewBag.CategoryList = db.Categories.Where(x => x.IsActive == true).ToList();
            return View();
        }
        [HttpPost]
        public ActionResult Add(Product product, HttpPostedFileBase[] ImageUpload)
        {
            for (int i = 0; i < ImageUpload.Length; i++)
            {
                //Check content image
                if (ImageUpload[i] != null && ImageUpload[i].ContentLength > 0)
                {
                    //Get file name
                    var fileName = Path.GetFileName(ImageUpload[i].FileName);
                    //Get path
                    var path = Path.Combine(Server.MapPath("~/Content/images"), fileName);
                    //Check exitst
                    if (!System.IO.File.Exists(path))
                    {
                        //Add image into folder
                        ImageUpload[i].SaveAs(path);
                    }
                }
            }

            if (ImageUpload[0] != null)
            {
                product.Image1 = ImageUpload[0].FileName;
            }
            if (ImageUpload[1] != null)
            {
                product.Image2 = ImageUpload[1].FileName;
            }
            if (ImageUpload[2] != null)
            {
                product.Image3 = ImageUpload[2].FileName;
            }
            product.CreatedBy = (Session["User"] as Models.User).ID;
            product.ViewCount = 0;
            product.PurchasedCount = 0;
            product.IsActive = true;
            db.Products.Add(product);
            db.SaveChanges();

            ViewBag.CategoryList = db.Categories.Where(x => x.IsActive == true).ToList();
            ViewBag.Message = "Thêm thành công";
            return View("Details", product);
        }
    }
}