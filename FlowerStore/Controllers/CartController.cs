using FlowerStore.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Web;
using System.Web.Mvc;

namespace FlowerStore.Controllers
{
    public class CartController : Controller
    {
        ShoppingEntities db = new ShoppingEntities();
        [HttpPost]
        public JsonResult AddItem(int ProductID)
        {
            Product product = db.Products.SingleOrDefault(x => x.ID == ProductID);
            if (Session["Cart"] == null)
            {
                Session["Cart"] = new List<ItemCart>();
            }
            List<ItemCart> itemCarts = Session["Cart"] as List<ItemCart>;
            // Kiểm tra sản phẩm đã tồn tại trong giỏ hàng chưa
            ItemCart check = itemCarts.FirstOrDefault(x => x.ProductID == ProductID);
            // Kiểm tra số lượng tồn
            if (itemCarts.Count > 0 && check!= null && product.Quantity <= check.Quantity)
            {
                return Json(new { status = false }, JsonRequestBehavior.AllowGet);
            }
            // Nếu tồn tại thì + số lượng lên 1
            if (check != null)
            {
                for (int i = 0; i < itemCarts.Count; i++)
                {
                    if (itemCarts[i].ProductID == ProductID)
                    {
                        itemCarts[i].Quantity += 1;
                    }
                }
            }
            else // Nếu chưa thì thêm mới sản phẩm vào giỏ hàng
            {
                itemCarts.Add(new ItemCart() { ProductID = product.ID, ProductName = product.Name, ProductPrice = product.Price.Value, ProductImage = product.Image1, Quantity = 1 });
            }
            Session["Cart"] = itemCarts;
            return Json(new { status = true }, JsonRequestBehavior.AllowGet);
        }
        [HttpGet]
        public JsonResult GetTotalCart()
        {
            List<ItemCart> itemCarts = Session["Cart"] as List<ItemCart>;
            return Json(new { TotalPrice = itemCarts.Sum(x => x.ProductPrice * x.Quantity).ToString("#,##"), TotalQuantity = itemCarts.Sum(x => x.Quantity) }, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public JsonResult UpdateQuantity(int ProductID, int Quantity)
        {
            List<ItemCart> itemCarts = Session["Cart"] as List<ItemCart>;
            if (Quantity > 0)
            {
                // Kiểm tra số lượng tồn
                Product product = db.Products.SingleOrDefault(x => x.ID == ProductID);
                if (itemCarts.Count > 0 && product.Quantity <= Quantity)
                {
                    return Json(new { update = false }, JsonRequestBehavior.AllowGet);
                }
            }

            for (int i = 0; i < itemCarts.Count; i++)
            {
                if (itemCarts[i].ProductID == ProductID)
                {
                    if (Quantity > 0)
                    {
                        itemCarts[i].Quantity = Quantity;
                        break;
                    }
                    else
                    {
                        itemCarts.RemoveAt(i);
                        break;
                    }
                }
            }
            Session["Cart"] = itemCarts;
            if (Quantity > 0)
            {
                return Json(new { update = true }, JsonRequestBehavior.AllowGet);
            }
            return Json(new { remove = true }, JsonRequestBehavior.AllowGet);
        }
        [HttpGet]
        public JsonResult GetSubTotal(int ProductID = 1)
        {
            List<ItemCart> itemCarts = Session["Cart"] as List<ItemCart>;
            return Json(new { SubTotal = itemCarts.Where(x => x.ProductID == ProductID).Sum(x => x.ProductPrice * x.Quantity).ToString("#,##") }, JsonRequestBehavior.AllowGet);
        }
        [HttpGet]
        public JsonResult GetTotal()
        {
            List<ItemCart> itemCarts = Session["Cart"] as List<ItemCart>;
            return Json(new { Total = itemCarts.Sum(x => x.ProductPrice * x.Quantity).ToString("#,##") }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult Checkout()
        {
            return View();
        }
        [HttpPost]
        public ActionResult AddOrder(string payment = "")
        {
            Models.User user = Session["User"] as Models.User;
            //Add order
            Models.Order order = new Models.Order();
            order.DateOrder = DateTime.Now;
            order.DateShip = DateTime.Now.AddDays(3);
            order.Status = "Processing";
            order.UserID = user.ID;
            order.IsPaid = false;
            db.Orders.Add(order);
            db.SaveChanges();
            int o = db.Orders.OrderByDescending(p => p.ID).FirstOrDefault().ID;
            Session["OrderId"] = o;
            //Add order detail
            List<ItemCart> listCart = Session["Cart"] as List<ItemCart>;
            foreach (ItemCart item in listCart)
            {
                OrderDetail orderDetail = new OrderDetail();
                orderDetail.OrderID = order.ID;
                orderDetail.ProductID = item.ProductID;
                orderDetail.Quantity = item.Quantity;
                orderDetail.ProductPrice = item.ProductPrice;
                orderDetail.ProductName = item.ProductName;
                orderDetail.ProductImage = item.ProductImage;
                db.OrderDetails.Add(orderDetail);
            }
            db.SaveChanges();
            // Payment
            if (payment == "paypal")
            {
                return RedirectToAction("PaymentWithPaypal", "Payment");
            }
            else if (payment == "momo")
            {
                return RedirectToAction("PaymentWithMomo", "Payment");
            }
            SentMail("Đặt hàng thành công", user.Email, "khuongip564gb@gmail.com", "woegwcwettmoumww", "<p style=\"font-size:20px\">Cảm ơn bạn đã đặt hàng<br/>Mã đơn hàng của bạn là: " + order.ID);

            Session.Remove("Cart");
            Session.Remove("OrderID");
            return RedirectToAction("Message", new { mess = "Đặt hàng thành công" });
        }
        public void SentMail(string Title, string ToEmail, string FromEmail, string Password, string Content)
        {
            MailMessage mail = new MailMessage();
            mail.To.Add(ToEmail);
            mail.From = new MailAddress(ToEmail);
            mail.Subject = Title;
            mail.Body = Content;
            mail.IsBodyHtml = true;
            SmtpClient smtp = new SmtpClient();
            smtp.Host = "smtp.gmail.com";
            smtp.Port = 587;
            smtp.UseDefaultCredentials = false;
            smtp.Credentials = new NetworkCredential(FromEmail, Password);
            smtp.EnableSsl = true;
            smtp.Send(mail);
        }
        public ActionResult Message(string mess)
        {
            ViewBag.Message = mess;
            return View();
        }
    }
}