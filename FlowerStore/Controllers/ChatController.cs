using FlowerStore.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace FlowerStore.Controllers
{
    public class ChatController : Controller
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
        public ActionResult Index()
        {
            if (CheckRole("Admin"))
            {

            }
            else
            {
                return RedirectToAction("Index", "Home");
            }
            User user = Session["User"] as User;
            IEnumerable<User> listUser = db.Users.ToList();
            List<Message> messages = new List<Message>();
            foreach (User item in listUser)
            {
                Message message = db.Messages.Where(x => x.FromUserID == item.ID && x.FromUserID != user.ID).ToList().LastOrDefault();
                if (message != null)
                {
                    messages.Add(message);
                }
            }
            return View(messages);
        }
        public ActionResult Chating(int WithUserID, int MessageID = 0)
        {
            if (CheckRole("Admin"))
            {

            }
            else
            {
                return RedirectToAction("Index", "Home");
            }
            IEnumerable<Message> listMessage;
            if (MessageID != 0)
            {
                //Update Sent
                Message message = db.Messages.Find(MessageID);
                if (!message.Send.Value)
                {
                    message.Send = true;
                    db.SaveChanges();
                }

                listMessage = db.Messages.Where(x => x.FromUserID == WithUserID || x.ToUserID == WithUserID).OrderBy(x => x.CreatedDate).ToList();

                ViewBag.UserFullName = db.Users.Find(WithUserID).Name;
                return View(listMessage);

            }
            ViewBag.UserFullName = db.Users.Find(WithUserID).Name;
            return View();
        }

        // GET: Message
        [AllowAnonymous]
        [HttpGet]
        public JsonResult GetAllMessageChating(int UserID)
        {
            try
            {
                IEnumerable<Message> listMessage1 = db.Messages.Where(x => x.FromUserID == UserID || x.ToUserID == UserID).OrderBy(x => x.CreatedDate).ToList();
                var listMessage = listMessage1.Select(x =>
                new
                {
                    ID = x.ID,
                    FromUserID = x.FromUserID,
                    Content = x.Content,
                    CreatedDate = x.CreatedDate.Value,
                    FromUserName = x.User.Name,
                    FromAvatarUser = x.User.Avatar
                });
                return Json(listMessage, JsonRequestBehavior.AllowGet);
            }
            catch (Exception)
            {
                return Json(null, JsonRequestBehavior.AllowGet);
            }
        }
        [AllowAnonymous]
        [HttpGet]
        public JsonResult GetLastMessageClient(int UserID)
        {
            try
            {
                Message message = db.Messages.Where(x => x.FromUserID == UserID).OrderBy(x => x.CreatedDate).ToList().LastOrDefault();
                return Json(new
                {
                    FromUserID = message.FromUserID,
                    Content = message.Content,
                    CreatedDate = message.CreatedDate.Value,
                    FromUserName = message.User.Name,
                    FromAvatarUser = message.User.Avatar
                }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception)
            {
                return Json(null, JsonRequestBehavior.AllowGet);
            }
        }
        [AllowAnonymous]
        [HttpPost]
        public JsonResult Send(int FromUserID, int ToUserID, string Content, string Side)
        {
            if (Side == "Client")
            {
                Message message1 = db.Messages.ToList().LastOrDefault();
                if (message1 != null && !message1.Send.Value)
                {
                    message1.Send = true;
                    db.SaveChanges();
                }
                Message message = new Message();
                message.Send = false;
                message.FromUserID = FromUserID;
                message.ToUserID = ToUserID;
                message.Content = Content;
                message.CreatedDate = DateTime.Now;

                db.Messages.Add(message);
                db.SaveChanges();
                return Json(new
                {
                    status = true
                }, JsonRequestBehavior.AllowGet);
            }
            else
            {
                Message message = new Message();

                message.FromUserID = FromUserID;
                message.ToUserID = ToUserID;
                message.Content = Content;
                message.CreatedDate = DateTime.Now;
                message.Send = true;

                db.Messages.Add(message);
                db.SaveChanges();
                return Json(new
                {
                    status = true
                }, JsonRequestBehavior.AllowGet);
            }
        }
        [AllowAnonymous]
        public JsonResult GetNotiMessage()
        {
            User user = Session["User"] as User;
            try
            {
                var listMessage = db.Messages.Where(x => x.Send == false && x.FromUserID != user.ID).ToList().Select(x => new { ID = x.ID, FromUserID = x.FromUserID, FromUserAvatar = x.User.Avatar, FromUserName = x.User.Name, CreatedDate = (DateTime.Now - x.CreatedDate.Value).Minutes }); ;
                return Json(listMessage, JsonRequestBehavior.AllowGet);
            }
            catch (Exception)
            {
                return Json(null, JsonRequestBehavior.AllowGet);
            }
        }
    }
}