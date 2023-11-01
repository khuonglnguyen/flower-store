using FlowerStore.Models;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using OfficeOpenXml;

namespace FlowerStore.Controllers
{
    public class StatisticController : Controller
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
        // GET: Statistic
        public ActionResult Index(DateTime from, DateTime to)
        {
            if (CheckRole("Admin"))
            {

            }
            else
            {
                return RedirectToAction("Index", "Admin");
            }
            List<OrderDetail> orderDetails = db.OrderDetails.Where(x => DbFunctions.TruncateTime(x.Order.DateOrder) >= from.Date && DbFunctions.TruncateTime(x.Order.DateOrder) <= to.Date).ToList();

            List<int> OrderIDs = new List<int>();
            foreach (var item in orderDetails)
            {
                OrderIDs.Add(item.OrderID.Value);
            }
            List<Order> orders = new List<Order>();
            if (OrderIDs.Count() > 0)
            {
                orders = db.Orders.Where(x => x.Status == "Complete" && OrderIDs.Contains(x.ID)).ToList();
            }
            ViewBag.from = from;
            ViewBag.to = to;
            return View(orders);
        }
        [HttpGet]
        public void DownloadExcelStatisticOrder(DateTime from, DateTime to)
        {
            User user = Session["User"] as User;
            List<OrderDetail> orderDetails = db.OrderDetails.Where(x => DbFunctions.TruncateTime(x.Order.DateOrder) >= from.Date && DbFunctions.TruncateTime(x.Order.DateOrder) <= to.Date).ToList();

            List<int> OrderIDs = new List<int>();
            foreach (var item in orderDetails)
            {
                OrderIDs.Add(item.OrderID.Value);
            }
            List<Order> orders = new List<Order>();
            if (OrderIDs.Count() > 0)
            {
                orders = db.Orders.Where(x => x.Status == "Complete" && OrderIDs.Contains(x.ID)).ToList();
            }

            ExcelPackage pck = new ExcelPackage();
            ExcelWorksheet ws = pck.Workbook.Worksheets.Add("Report");

            ws.Cells["A2"].Value = "Người lập";
            ws.Cells["B2"].Value = user.Name;

            ws.Cells["A3"].Value = "Ngày lập";
            ws.Cells["B3"].Value = DateTime.Now.ToShortDateString();

            ws.Cells["A6"].Value = "Mã HĐ";
            ws.Cells["B6"].Value = "Tên Khách Hàng";
            ws.Cells["C6"].Value = "Ngày Đặt";
            ws.Cells["D6"].Value = "Ngày Giao";
            ws.Cells["E6"].Value = "Tình Trạng";
            ws.Cells["F6"].Value = "Thành Tiền";

            int rowStart = 7;
            foreach (var item in orders)
            {
                ws.Cells[string.Format("A{0}", rowStart)].Value = item.ID;
                ws.Cells[string.Format("B{0}", rowStart)].Value = item.User.Name;
                ws.Cells[string.Format("C{0}", rowStart)].Value = item.DateOrder.Value.ToString("dd/MM/yyyy");
                ws.Cells[string.Format("D{0}", rowStart)].Value = item.DateShip.Value.ToString("dd/MM/yyyy");
                ws.Cells[string.Format("E{0}", rowStart)].Value = "Hoàn thành";
                ws.Cells[string.Format("F{0}", rowStart)].Value = item.OrderDetails.Sum(x => x.ProductPrice * x.Quantity);
                rowStart++;
            }

            ws.Cells["A:AZ"].AutoFitColumns();
            Response.Clear();
            Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
            Response.AddHeader("content-disposition", "attachment: filename=" + "Đơn đặt hàng.xlsx");
            Response.BinaryWrite(pck.GetAsByteArray());
            Response.End();
        }
    }
}