using FlowerStore.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace FlowerStore.Controllers
{
    public class CategoryManageController : Controller
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
        public ActionResult Index(string keyword = "")
        {
            if (CheckRole("Admin"))
            {

            }
            else
            {
                return RedirectToAction("Index", "Admin");
            }
            List<Category> categories = new List<Category>();
            if (keyword != "")
            {
                categories = db.Categories.Where(x => x.Name.Contains(keyword)).ToList();
            }
            else
            {
                categories = db.Categories.Where(x => x.Name.Contains(keyword)).ToList();
            }
            return View(categories);
        }
        public ActionResult ToggleActive(int ID)
        {
            Category category = db.Categories.Find(ID);
            category.IsActive = !category.IsActive;
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
            Category category = db.Categories.Find(ID);
            return View(category);
        }
        [HttpPost]
        public ActionResult Edit(Category category)
        {
            Category categoryUpdate = db.Categories.Find(category.ID);
            categoryUpdate.Name = category.Name;
            db.SaveChanges();
            ViewBag.Message = "Cập nhật thành công";
            return View("Details", categoryUpdate);
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
            return View();
        }
        [HttpPost]
        public ActionResult Add(Category category)
        {
            category.IsActive = true;
            Category cate = db.Categories.Add(category);
            db.SaveChanges();
            ViewBag.Message = "Thêm thành công";
            return View("Details", cate);
        }
    }
}